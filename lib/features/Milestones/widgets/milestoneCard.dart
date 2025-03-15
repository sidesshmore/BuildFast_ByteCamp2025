import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class MilestoneCard extends StatefulWidget {
  final Map<String, dynamic> milestone;
  final Function() onDataChanged;

  const MilestoneCard({
    Key? key,
    required this.milestone,
    required this.onDataChanged,
  }) : super(key: key);

  @override
  State<MilestoneCard> createState() => _MilestoneCardState();
}

class _MilestoneCardState extends State<MilestoneCard> {
  bool _hasVoted = false;
  bool _isLoadingVote = false;
  bool _isCheckingVoteStatus = true;
  int _totalDonors = 0;
  double _votePercentage = 0.0;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadVoteStatus();
  }

  Future<void> _loadVoteStatus() async {
    setState(() {
      _isCheckingVoteStatus = true;
    });

    try {
      // Get current user ID
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      _userId = prefs.getString('userId') ?? prefs.getString('user_id');

      if (_userId == null) {
        log('User ID not found in preferences');
        return;
      }

      // Check if the user has already voted
      final supabase = Supabase.instance.client;
      final milestoneId = widget.milestone['id'];
      final campaignId = widget.milestone['campaign_id'];

      // Check if user has already voted
      final votes = await supabase
          .from('milestone_votes')
          .select()
          .eq('milestone_id', milestoneId)
          .eq('user_id', _userId!);

      _hasVoted = votes != null && votes.isNotEmpty;

      // Get total donor count for the campaign
      final response = await http.get(
        Uri.parse(
            'http://10.0.8.31:3000/ledger/transactions/unique/$campaignId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null && data is List) {
          _totalDonors = data.length;
        }
      }

// Add these log statements to debug the issue
      log('Vote count: ${widget.milestone['votecount']}');
      log('Total donors: $_totalDonors');

// Calculate vote percentage if we have donors
      if (_totalDonors > 0) {
        final voteCount = widget.milestone['votecount'] ?? 0;
        _votePercentage = (voteCount / _totalDonors) * 100;
        log('Vote percentage calculated: $_votePercentage');
      } else {
        _votePercentage = 0.0;
        log('No donors or total donors is 0');
      }
    } catch (e) {
      log('Error loading vote status: ${e.toString()}');
    } finally {
      setState(() {
        _isCheckingVoteStatus = false;
      });
    }
  }

  Future<void> _voteForApproval() async {
    if (_isLoadingVote || _hasVoted || _userId == null) return;

    setState(() {
      _isLoadingVote = true;
    });

    try {
      final supabase = Supabase.instance.client;
      final milestoneId = widget.milestone['id'];

      // Record the vote in a votes table
      await supabase.from('milestone_votes').insert({
        'milestone_id': milestoneId,
        'user_id': _userId,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Increment the votecount in the milestones table
      final currentVotes = widget.milestone['votecount'] ?? 0;
      await supabase
          .from('campaign_milestones')
          .update({'votecount': currentVotes + 1}).eq('id', milestoneId);

      // Update local state
      setState(() {
        _hasVoted = true;
        widget.milestone['votecount'] = currentVotes + 1;

        // Recalculate percentage
        if (_totalDonors > 0) {
          _votePercentage =
              (widget.milestone['votecount'] / _totalDonors) * 100;
        }
      });

      // Notify parent that data has changed
      widget.onDataChanged();

      // Check if the milestone has reached approval threshold
      if (_votePercentage >= 60) {
        // Consider updating the is_verified field if this is your logic
        await supabase
            .from('campaign_milestones')
            .update({'is_verified': true}).eq('id', milestoneId);

        setState(() {
          widget.milestone['is_verified'] = true;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vote recorded successfully!')),
      );
    } catch (e) {
      log('Error recording vote: ${e.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to record your vote. Please try again.')),
      );
    } finally {
      setState(() {
        _isLoadingVote = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final milestone = widget.milestone;
    final verified = milestone['is_verified'] == true;

    // Format date if available
    String formattedDate = 'Not set';
    if (milestone['target_date'] != null) {
      try {
        final date = milestone['target_date'] is String
            ? DateTime.parse(milestone['target_date'])
            : milestone['target_date'] as DateTime;
        formattedDate = DateFormat('MMM d, yyyy').format(date);
      } catch (e) {
        // If parsing fails, just use the string representation
        formattedDate = milestone['target_date'].toString().substring(0, 10);
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: verified ? Colors.green.shade300 : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showMilestoneDetails(context),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      milestone['milestone_name'] ?? 'Unnamed Milestone',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: verified
                          ? Colors.green.shade50
                          : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: verified
                            ? Colors.green.shade200
                            : Colors.orange.shade200,
                      ),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          verified ? Icons.verified : Icons.pending,
                          color: verified ? Colors.green : Colors.orange,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          verified ? 'Verified' : 'Pending',
                          style: TextStyle(
                            color: verified ? Colors.green : Colors.orange,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.campaign, size: 16, color: Colors.grey),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      milestone['campaigns']?['campaign_name'] ??
                          'Unknown Campaign',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  SizedBox(width: 6),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.attach_money, size: 16, color: Colors.grey),
                  SizedBox(width: 6),
                  Text(
                    '\$${milestone['funding_required']?.toStringAsFixed(2) ?? '0.00'}',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              if (!_isCheckingVoteStatus && !verified)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Community Approval',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 6),
                    Stack(
                      children: [
                        Container(
                          height: 6,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        Container(
                          height: 6,
                          width: MediaQuery.of(context).size.width *
                              ((_votePercentage / 100) *
                                  0.8), // Account for padding
                          decoration: BoxDecoration(
                            color: _votePercentage >= 60
                                ? Colors.green
                                : Colors.blue,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_votePercentage.toStringAsFixed(1)}% of donors approved',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Text(
                          '60% needed',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _hasVoted || _isLoadingVote
                            ? null
                            : _voteForApproval,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _hasVoted ? Colors.grey.shade300 : Colors.blue,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoadingVote
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Text(
                                _hasVoted ? 'You Voted' : 'Vote for Approval'),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMilestoneDetails(BuildContext context) {
    final milestone = widget.milestone;
    final verified = milestone['is_verified'] == true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(24),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      milestone['milestone_name'] ?? 'Milestone Details',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              SizedBox(height: 16),
              _buildDetailRow(
                  Icons.campaign,
                  'Campaign',
                  milestone['campaigns']?['campaign_name'] ??
                      'Unknown Campaign'),
              SizedBox(height: 16),
              _buildDetailRow(
                  Icons.calendar_today,
                  'Target Date',
                  milestone['target_date']?.toString().substring(0, 10) ??
                      'Not set'),
              SizedBox(height: 16),
              _buildDetailRow(Icons.attach_money, 'Funding Required',
                  '\$${milestone['funding_required']?.toStringAsFixed(2) ?? '0.00'}'),
              SizedBox(height: 16),
              _buildDetailRow(
                verified ? Icons.verified : Icons.pending,
                'Status',
                verified ? 'Verified' : 'Pending Verification',
                iconColor: verified ? Colors.green : Colors.orange,
              ),
              if (milestone['document_url'] != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16),
                    _buildDetailRow(
                      Icons.description,
                      'Documentation',
                      'View Document',
                      isLink: true,
                      onTap: () {
                        // Add code to open the document URL
                        log('Opening document: ${milestone['document_url']}');
                      },
                    ),
                  ],
                ),
              SizedBox(height: 24),
              Text(
                'Description',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    milestone['description'] ?? 'No description available',
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24),
              if (!verified && !_isCheckingVoteStatus)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Community Approval',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: _votePercentage / 100,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _votePercentage >= 60 ? Colors.green : Colors.blue,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_votePercentage.toStringAsFixed(1)}% of donors approved',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Text(
                          '60% needed for verification',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _hasVoted || _isLoadingVote
                            ? null
                            : _voteForApproval,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _hasVoted ? Colors.grey.shade300 : Colors.blue,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoadingVote
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Text(
                                _hasVoted
                                    ? 'You have voted'
                                    : 'Vote for Approval',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value,
      {Color? iconColor, bool isLink = false, VoidCallback? onTap}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor ?? Colors.grey.shade700, size: 20),
        SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 2),
            isLink
                ? GestureDetector(
                    onTap: onTap,
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                : Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
          ],
        ),
      ],
    );
  }
}
