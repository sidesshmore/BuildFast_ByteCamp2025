import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:daansure/constants.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Add this import

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
  String final_amount = "0";
  String userId = ""; // Variable to store user ID from shared preferences

  List<Map<String, dynamic>> _transactions = [];
  bool _isTransactionsLoading = false;
  bool _isTransactionsExpanded = false;

// Add this method to your _CampaignDetailScreenState class
  Future<void> _fetchTransactions() async {
    if (_campaignData == null) return;

    setState(() {
      _isTransactionsLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
            'http://192.168.27.254:3000/ledger/transactions/${_campaignData!['id']}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _transactions =
              data.map((item) => item as Map<String, dynamic>).toList();
          _isTransactionsLoading = false;
        });
      } else {
        setState(() {
          _isTransactionsLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isTransactionsLoading = false;
      });
      log('Error fetching transactions: ${e.toString()}');
    }
  }

// Modify your _fetchCampaignDetails method to also fetch transactions
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

      // Fetch transactions after campaign details are loaded
      _fetchTransactions();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load campaign details';
        _isLoading = false;
      });
    }
  }

  void handlePaymentErrorResponse(PaymentFailureResponse response) {
    /*
    * PaymentFailureResponse contains three values:
    * 1. Error Code
    * 2. Error Description
    * 3. Metadata
    * */
    // showAlertDialog(context, "Payment Failed", "Code: ${response.code}\nDescription: ${response.message}\nMetadata:${response.error.toString()}");
  }

  void handlePaymentSuccessResponse(PaymentSuccessResponse response) async {
    try {
      // Get User Name
      final supabase = Supabase.instance.client;

      // Parse the amount to a double
      double amountValue = double.parse(final_amount);
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      int userIdInt = int.parse(userId!);

      final userResponse = await supabase
          .from('users')
          .select('name')
          .eq('id', userIdInt)
          .single();

      // First, record the transaction in the ledger
      final Map<String, dynamic> requestBody = {
        "user_id": userId, // Using userId from shared preferences
        "sender": userResponse['name'],
        "receipt_id": response.paymentId,
        "amount": final_amount,
        "campaigns_id": widget.campaignId
      };

      // Make the HTTP request to record the transaction
      final httpResponse = await http.post(
        Uri.parse('http://192.168.27.254:3000/ledger/add'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      // Now update the campaign's funds_collected in the database
      // final supabase = Supabase.instance.client;

      // First, get the current funds_collected value
      final campaign = await supabase
          .from('campaigns')
          .select('funds_collected')
          .eq('id', widget.campaignId)
          .single();

      double currentFunds = campaign['funds_collected'];
      double newFundsCollected = currentFunds + amountValue;

      // Update the campaign with the new funds_collected value
      await supabase.from('campaigns').update(
          {'funds_collected': newFundsCollected}).eq('id', widget.campaignId);

      // Check if the campaign is now completed (funds_collected >= funds_required)
      if (newFundsCollected >= _campaignData!['funds_required']) {
        await supabase
            .from('campaigns')
            .update({'is_completed': true}).eq('id', widget.campaignId);
      }

      // Show success message to the user
      if (httpResponse.statusCode == 200 || httpResponse.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment successful! Thank you for your donation.'),
            backgroundColor: Globals.customGreen,
          ),
        );

        // Refresh the campaign details to show updated funds
        _fetchCampaignDetails();
      } else {
        // Transaction logged in Razorpay but not in our ledger
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment processed but transaction logging failed.'),
            backgroundColor: Colors.orange,
          ),
        );
        // Still refresh the campaign details
        _fetchCampaignDetails();
      }
    } catch (e) {
      // Handle any exceptions
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error processing payment: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      log('Payment error: ${e.toString()}');
    }
  }

  void handleExternalWalletSelected(ExternalWalletResponse response) {
    // showAlertDialog(context, "External Wallet Selected", "${response.walletName}");
  }

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load user data when the screen initializes
    _fetchCampaignDetails();
  }

  // Add this method to load user data from SharedPreferences
  Future<void> _loadUserData() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      // Get the user ID from shared preferences
      String? storedUserId = prefs.getString('user_id');

      if (storedUserId != null && storedUserId.isNotEmpty) {
        setState(() {
          userId = storedUserId;
        });
      } else {
        // Handle case where user ID is not available
        log('User ID not found in SharedPreferences');
      }
    } catch (e) {
      log('Error loading user data: ${e.toString()}');
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

  Widget _buildTransactionsList() {
    return Container(
      margin: EdgeInsets.only(bottom: Globals.screenHeight * 0.024),
      decoration: BoxDecoration(
        border: Border.all(color: Globals.customGreyLight),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Header (always visible)
          InkWell(
            onTap: () {
              setState(() {
                _isTransactionsExpanded = !_isTransactionsExpanded;
              });
            },
            child: Padding(
              padding: EdgeInsets.all(Globals.screenWidth * 0.04),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Donations',
                    style: TextStyle(
                      fontSize: Globals.screenHeight * 0.02,
                      fontWeight: FontWeight.bold,
                      color: Globals.customBlack,
                    ),
                  ),
                  Icon(
                    _isTransactionsExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Globals.customGreyDark,
                  ),
                ],
              ),
            ),
          ),

          // Expandable content
          if (_isTransactionsExpanded) ...[
            Divider(height: 1, color: Globals.customGreyLight),
            _isTransactionsLoading
                ? Padding(
                    padding: EdgeInsets.all(Globals.screenWidth * 0.04),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Globals.customGreen,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                : _transactions.isEmpty
                    ? Padding(
                        padding: EdgeInsets.all(Globals.screenWidth * 0.04),
                        child: Center(
                          child: Text(
                            'No donations yet.',
                            style: TextStyle(
                              color: Globals.customGreyDark,
                              fontSize: Globals.screenHeight * 0.016,
                            ),
                          ),
                        ),
                      )
                    : ListView.separated(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: _transactions.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          color: Globals.customGreyLight,
                        ),
                        itemBuilder: (context, index) {
                          final transaction = _transactions[index];
                          return ListTile(
                            dense: true,
                            title: Text(
                              transaction['sender'] ?? 'Anonymous',
                              style: TextStyle(
                                fontSize: Globals.screenHeight * 0.016,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: Text(
                              '₹${double.parse(transaction['amount'].toString()).toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: Globals.screenHeight * 0.016,
                                fontWeight: FontWeight.bold,
                                color: Globals.customGreen,
                              ),
                            ),
                          );
                        },
                      ),
          ],
        ],
      ),
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

                SizedBox(height: Globals.screenHeight * 0.024),
                _buildTransactionsList(),
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

                  setState(() {
                    final_amount = amount.toString();
                  });

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

                  Razorpay razorpay = Razorpay();
                  var options = {
                    'key': 'rzp_test_6jaWR4JZLFipOk',
                    'amount': amount * 100,
                    'name': 'DaanSure',
                    'description': 'Ensuring every donation is used right',
                    'retry': {'enabled': true, 'max_count': 1},
                    'send_sms_hash': true,
                    'prefill': {
                      'contact': '8888888888',
                      'email': 'test@razorpay.com'
                    },
                    'external': {
                      'wallets': ['paytm']
                    }
                  };
                  razorpay.on(
                      Razorpay.EVENT_PAYMENT_ERROR, handlePaymentErrorResponse);
                  razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS,
                      handlePaymentSuccessResponse);
                  razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET,
                      handleExternalWalletSelected);
                  razorpay.open(options);
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
