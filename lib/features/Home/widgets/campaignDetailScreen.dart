import 'package:flutter/material.dart';
import 'package:daansure/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CampaignDetailScreen extends StatefulWidget {
  final String campaignId;

  const CampaignDetailScreen({
    Key? key,
    required this.campaignId,
  }) : super(key: key);

  @override
  State<CampaignDetailScreen> createState() => _CampaignDetailScreenState();
}

class _CampaignDetailScreenState extends State<CampaignDetailScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _campaignData;
  Map<String, dynamic>? _ngoData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchCampaignDetails();
  }

  Future<void> _fetchCampaignDetails() async {
    try {
      final supabase = Supabase.instance.client;
      final data = await supabase
          .from('campaigns')
          .select('*, ngo_details(*)')
          .eq('id', widget.campaignId)
          .single();

      setState(() {
        _campaignData = data;
        _ngoData = data['ngo_details'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load campaign details';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Globals.initialize(context);

    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: Globals.customGreen,
                ),
              )
            : _errorMessage != null
                ? _buildErrorView()
                : _buildCampaignDetails(),
      ),
      bottomNavigationBar:
          _isLoading || _errorMessage != null ? null : _buildDonateButton(),
    );
  }

  Widget _buildCampaignDetails() {
    // Calculate progress percentage
    final fundsRequired = _campaignData!['funds_required'] as double;
    final fundsCollected = _campaignData!['funds_collected'] as double;
    final progress = fundsCollected / fundsRequired;
    final progressPercentage = (progress * 100).toStringAsFixed(1);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              // Campaign image
              _campaignData!['image_url'] != null &&
                      _campaignData!['image_url'].isNotEmpty
                  ? Image.network(
                      _campaignData!['image_url'],
                      height: Globals.screenHeight * 0.3,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: Globals.screenHeight * 0.3,
                          width: double.infinity,
                          color: Globals.customGreyLight,
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: Globals.customGreyDark,
                            size: Globals.screenHeight * 0.05,
                          ),
                        );
                      },
                    )
                  : Container(
                      height: Globals.screenHeight * 0.3,
                      width: double.infinity,
                      color: Globals.customGreyLight,
                      child: Icon(
                        Icons.image_outlined,
                        color: Globals.customGreyDark,
                        size: Globals.screenHeight * 0.05,
                      ),
                    ),
              // Back button
              Positioned(
                top: Globals.screenHeight * 0.02,
                left: Globals.screenWidth * 0.04,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      color: Globals.customBlack,
                      size: Globals.screenHeight * 0.025,
                    ),
                  ),
                ),
              ),
              // Completed tag if campaign is completed
              if (_campaignData!['is_completed'])
                Positioned(
                  top: Globals.screenHeight * 0.02,
                  right: Globals.screenWidth * 0.04,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Globals.screenWidth * 0.03,
                      vertical: Globals.screenHeight * 0.006,
                    ),
                    decoration: BoxDecoration(
                      color: Globals.customGreen.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Completed',
                      style: TextStyle(
                        fontSize: Globals.screenHeight * 0.014,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(Globals.screenWidth * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Campaign name
                Text(
                  _campaignData!['campaign_name'],
                  style: TextStyle(
                    fontSize: Globals.screenHeight * 0.028,
                    fontWeight: FontWeight.bold,
                    color: Globals.customBlack,
                  ),
                ),
                SizedBox(height: Globals.screenHeight * 0.016),

                // NGO info
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _ngoData!['logo_url'] != null &&
                              _ngoData!['logo_url'].isNotEmpty
                          ? Image.network(
                              _ngoData!['logo_url'],
                              height: Globals.screenHeight * 0.04,
                              width: Globals.screenHeight * 0.04,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: Globals.screenHeight * 0.04,
                                  width: Globals.screenHeight * 0.04,
                                  color: Globals.customGreen.withOpacity(0.1),
                                  child: Icon(
                                    Icons.business_outlined,
                                    color: Globals.customGreen,
                                    size: Globals.screenHeight * 0.025,
                                  ),
                                );
                              },
                            )
                          : Container(
                              height: Globals.screenHeight * 0.04,
                              width: Globals.screenHeight * 0.04,
                              color: Globals.customGreen.withOpacity(0.1),
                              child: Icon(
                                Icons.business_outlined,
                                color: Globals.customGreen,
                                size: Globals.screenHeight * 0.025,
                              ),
                            ),
                    ),
                    SizedBox(width: Globals.screenWidth * 0.02),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _ngoData!['ngo_name'],
                            style: TextStyle(
                              fontSize: Globals.screenHeight * 0.018,
                              fontWeight: FontWeight.bold,
                              color: Globals.customBlack,
                            ),
                          ),
                          SizedBox(height: Globals.screenHeight * 0.004),
                          Text(
                            'DARPAN ID: ${_ngoData!['darpan_id']}',
                            style: TextStyle(
                              fontSize: Globals.screenHeight * 0.014,
                              color: Globals.customGreyDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Progress section
                SizedBox(height: Globals.screenHeight * 0.024),
                Container(
                  padding: EdgeInsets.all(Globals.screenWidth * 0.04),
                  decoration: BoxDecoration(
                    color: Globals.customGreyLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '₹${fundsCollected.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: Globals.screenHeight * 0.022,
                              fontWeight: FontWeight.bold,
                              color: Globals.customGreen,
                            ),
                          ),
                          Text(
                            '$progressPercentage%',
                            style: TextStyle(
                              fontSize: Globals.screenHeight * 0.018,
                              fontWeight: FontWeight.bold,
                              color: Globals.customGreyDark,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: Globals.screenHeight * 0.01),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress.clamp(0.0, 1.0),
                          backgroundColor: Colors.white,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Globals.customGreen,
                          ),
                          minHeight: Globals.screenHeight * 0.012,
                        ),
                      ),
                      SizedBox(height: Globals.screenHeight * 0.01),
                      Text(
                        'Target: ₹${fundsRequired.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: Globals.screenHeight * 0.016,
                          color: Globals.customGreyDark,
                        ),
                      ),
                    ],
                  ),
                ),

                // About campaign
                SizedBox(height: Globals.screenHeight * 0.024),
                Text(
                  'About This Campaign',
                  style: TextStyle(
                    fontSize: Globals.screenHeight * 0.02,
                    fontWeight: FontWeight.bold,
                    color: Globals.customBlack,
                  ),
                ),
                SizedBox(height: Globals.screenHeight * 0.012),
                Text(
                  _campaignData!['campaign_description'],
                  style: TextStyle(
                    fontSize: Globals.screenHeight * 0.016,
                    color: Globals.customGreyDark,
                    height: 1.5,
                  ),
                ),

                // About NGO
                SizedBox(height: Globals.screenHeight * 0.024),
                Text(
                  'About The NGO',
                  style: TextStyle(
                    fontSize: Globals.screenHeight * 0.02,
                    fontWeight: FontWeight.bold,
                    color: Globals.customBlack,
                  ),
                ),
                SizedBox(height: Globals.screenHeight * 0.012),
                _buildNGOInfoItem(
                  Icons.person_outline,
                  'Administrator',
                  _ngoData!['administrator_name'],
                ),
                SizedBox(height: Globals.screenHeight * 0.01),
                _buildNGOInfoItem(
                  Icons.email_outlined,
                  'Email',
                  _ngoData!['email'],
                ),
                SizedBox(height: Globals.screenHeight * 0.01),
                if (_ngoData!['phone_number'] != null)
                  _buildNGOInfoItem(
                    Icons.phone_outlined,
                    'Phone',
                    _ngoData!['phone_number'],
                  ),
                if (_ngoData!['phone_number'] != null)
                  SizedBox(height: Globals.screenHeight * 0.01),
                _buildNGOInfoItem(
                  Icons.location_on_outlined,
                  'Address',
                  _ngoData!['address'],
                ),

                // Extra space at bottom for better scrolling
                SizedBox(height: Globals.screenHeight * 0.04),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showPaymentModal() async {
    // Controller for the donation amount text field
    final amountController = TextEditingController();

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Donate to ${_campaignData!['campaign_name']}',
                style: TextStyle(
                  fontSize: Globals.screenHeight * 0.022,
                  fontWeight: FontWeight.bold,
                  color: Globals.customBlack,
                ),
              ),
              SizedBox(height: Globals.screenHeight * 0.02),
              Text(
                'Enter donation amount (₹)',
                style: TextStyle(
                  fontSize: Globals.screenHeight * 0.016,
                  color: Globals.customGreyDark,
                ),
              ),
              SizedBox(height: Globals.screenHeight * 0.01),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixText: '₹ ',
                  prefixStyle: TextStyle(
                    color: Globals.customBlack,
                    fontSize: Globals.screenHeight * 0.018,
                  ),
                  hintText: '1000',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Globals.customGreyLight),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        BorderSide(color: Globals.customGreen, width: 2),
                  ),
                ),
              ),
              SizedBox(height: Globals.screenHeight * 0.03),
              ElevatedButton(
                onPressed: () {
                  // Get amount from the text field
                  final amount = double.tryParse(amountController.text);
                  if (amount == null || amount <= 0) {
                    // Show error for invalid amount
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please enter a valid amount'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // Close modal
                  Navigator.pop(context);

                  // TODO: Implement payment processing
                  // For now, just show a success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Processing payment of ₹${amount.toStringAsFixed(2)}'),
                      backgroundColor: Globals.customGreen,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Globals.customGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: Globals.screenHeight * 0.016,
                  ),
                  minimumSize: Size(double.infinity, 0),
                ),
                child: Text(
                  'PAY',
                  style: TextStyle(
                    fontSize: Globals.screenHeight * 0.018,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: Globals.screenHeight * 0.02),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNGOInfoItem(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Globals.customGreen,
          size: Globals.screenHeight * 0.022,
        ),
        SizedBox(width: Globals.screenWidth * 0.02),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: Globals.screenHeight * 0.014,
                  color: Globals.customGreyDark,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: Globals.screenHeight * 0.016,
                  color: Globals.customBlack,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDonateButton() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Globals.screenWidth * 0.04,
        vertical: Globals.screenHeight * 0.02,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _campaignData!['is_completed']
            ? null
            : () {
                _showPaymentModal();
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Globals.customGreen,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Globals.customGreyLight,
          disabledForegroundColor: Globals.customGreyDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(
            vertical: Globals.screenHeight * 0.016,
          ),
          minimumSize: Size(double.infinity, 0),
        ),
        child: Text(
          _campaignData!['is_completed'] ? 'Campaign Completed' : 'Donate Now',
          style: TextStyle(
            fontSize: Globals.screenHeight * 0.018,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: Globals.screenHeight * 0.06,
          ),
          SizedBox(height: Globals.screenHeight * 0.02),
          Text(
            _errorMessage!,
            style: TextStyle(
              color: Globals.customGreyDark,
              fontSize: Globals.screenHeight * 0.018,
            ),
          ),
          SizedBox(height: Globals.screenHeight * 0.02),
          ElevatedButton(
            onPressed: _fetchCampaignDetails,
            style: ElevatedButton.styleFrom(
              backgroundColor: Globals.customGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
