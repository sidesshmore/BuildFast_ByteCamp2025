import 'package:daansure/features/Milestones/widgets/milestoneCard.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';

class MilestoneScreen extends StatefulWidget {
  const MilestoneScreen({super.key});

  @override
  State<MilestoneScreen> createState() => _MilestoneScreenState();
}

class _MilestoneScreenState extends State<MilestoneScreen> {
  String? userId;
  bool isLoading = false;
  List<Map<String, dynamic>> milestones = [];

  @override
  void initState() {
    super.initState();
    // Fetch milestone data when the screen initializes
    fetchMilestoneData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Milestones'),
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : milestones.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          userId == null
                              ? 'User not logged in'
                              : 'No milestones found',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: fetchMilestoneData,
                          child: Text('Fetch Milestone Data'),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: milestones.length,
                          itemBuilder: (context, index) {
                            return MilestoneCard(
                              milestone: milestones[index],
                              onDataChanged: fetchMilestoneData,
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ElevatedButton(
                          onPressed: fetchMilestoneData,
                          child: Text('Refresh Milestones'),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  void _showMilestoneDetails(Map<String, dynamic> milestone) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(milestone['milestone_name'] ?? 'Milestone Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Campaign',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(milestone['campaigns']?['campaign_name'] ??
                    'Unknown Campaign'),
                SizedBox(height: 10),
                Text(
                  'Description',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(milestone['description'] ?? 'No description available'),
                SizedBox(height: 10),
                Text(
                  'Target Date',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(milestone['target_date']?.toString().substring(0, 10) ??
                    'Not set'),
                SizedBox(height: 10),
                Text(
                  'Funding Required',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text('\$${milestone['funding_required']?.toString() ?? '0'}'),
                SizedBox(height: 10),
                Text(
                  'Status',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Row(
                  children: [
                    milestone['is_verified'] == true
                        ? Icon(Icons.verified, color: Colors.green)
                        : Icon(Icons.pending, color: Colors.orange),
                    SizedBox(width: 5),
                    Text(milestone['is_verified'] == true
                        ? 'Verified'
                        : 'Pending Verification'),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // Step 1: Get user ID from SharedPreferences
  Future<String?> getUserIdFromPrefs() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      // Check both formats of user ID storage ('userId' and 'user_id')
      String? storedUserId =
          prefs.getString('userId') ?? prefs.getString('user_id');

      if (storedUserId != null && storedUserId.isNotEmpty) {
        log('Found user ID in SharedPreferences: $storedUserId');
        return storedUserId;
      } else {
        log('User ID not found in SharedPreferences');
        return null;
      }
    } catch (e) {
      log('Error loading user ID from SharedPreferences: ${e.toString()}');
      return null;
    }
  }

  // Step 2: Fetch campaign IDs where the user has donated
  Future<List<String>> getCampaignIdsForUser(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.8.31:3000/ledger/$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['transactions'] != null) {
          List<String> campaignIds = List<String>.from(data['transactions']);
          log('Retrieved ${campaignIds.length} campaign IDs for user');
          return campaignIds;
        } else {
          log('No campaign IDs found for user or unexpected response format');
          return [];
        }
      } else {
        log('Failed to fetch campaign IDs: HTTP ${response.statusCode}');
        return [];
      }
    } catch (e) {
      log('Error fetching campaign IDs: ${e.toString()}');
      return [];
    }
  }

  // Step 3: Fetch milestones for the campaign IDs
  Future<List<Map<String, dynamic>>> getMilestonesForCampaigns(
      List<String> campaignIds) async {
    if (campaignIds.isEmpty) return [];

    final supabase = Supabase.instance.client;
    List<Map<String, dynamic>> allMilestones = [];

    try {
      for (String campaignId in campaignIds) {
        try {
          final milestones = await supabase
              .from('campaign_milestones')
              .select('*, campaigns(campaign_name)')
              .eq('campaign_id', campaignId);

          if (milestones != null && milestones.isNotEmpty) {
            for (var milestone in milestones) {
              allMilestones.add(Map<String, dynamic>.from(milestone));
            }
            log('Found ${milestones.length} milestones for campaign $campaignId');
          } else {
            log('No milestones found for campaign $campaignId');
          }
        } catch (e) {
          log('Error fetching milestones for campaign $campaignId: ${e.toString()}');
        }
      }
      return allMilestones;
    } catch (e) {
      log('Error in milestone fetching process: ${e.toString()}');
      return [];
    }
  }

  // Main function to orchestrate the data fetching process
  Future<void> fetchMilestoneData() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      // Step 1: Get user ID
      userId = await getUserIdFromPrefs();
      if (userId == null) {
        log('Cannot proceed: User ID is null');
        return;
      }
      log('Step 1 complete: User ID = $userId');

      // Step 2: Get campaign IDs for the user
      List<String> campaignIds = await getCampaignIdsForUser(userId!);
      if (campaignIds.isEmpty) {
        log('No campaign IDs found for user');
      } else {
        log('Step 2 complete: Found ${campaignIds.length} campaigns');
        log('Campaign IDs: $campaignIds');
      }

      // Step 3: Get milestones for the campaigns
      List<Map<String, dynamic>> fetchedMilestones =
          await getMilestonesForCampaigns(campaignIds);
      if (fetchedMilestones.isEmpty) {
        log('No milestones found for user campaigns');
      } else {
        log('Step 3 complete: Found ${fetchedMilestones.length} total milestones');
        // Log each milestone
        for (var milestone in fetchedMilestones) {
          log('Milestone ID: ${milestone['id']}');
          log('  Name: ${milestone['milestone_name']}');
          log('  Campaign: ${milestone['campaigns']?['campaign_name'] ?? 'Unknown Campaign'}');
          log('  Description: ${milestone['description']}');
          log('  Target Date: ${milestone['target_date']}');
          log('  Funding Required: ${milestone['funding_required']}');
          log('  Verified: ${milestone['is_verified']}');
          log('------------------------------------------');
        }

        // Update the state with the fetched milestones
        setState(() {
          milestones = fetchedMilestones;
        });
      }
    } catch (e) {
      log('Error in data fetching process: ${e.toString()}');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
