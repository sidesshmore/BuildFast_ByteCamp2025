// lib/features/home/screens/homeScreen.dart
import 'package:daansure/features/Home/widgets/campaignCard.dart';
import 'package:flutter/material.dart';
import 'package:daansure/constants.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _campaigns = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchCampaigns();
  }

  Future<void> _fetchCampaigns() async {
    try {
      final supabase = Supabase.instance.client;
      final data = await supabase
          .from('campaigns')
          .select('*, ngo_details(ngo_name, logo_url)')
          .order('id', ascending: false);

      setState(() {
        _campaigns = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load campaigns';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Globals.initialize(context);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: Globals.customGreen,
          onRefresh: _fetchCampaigns,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Globals.screenWidth * 0.04,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: Globals.screenHeight * 0.02),
                _buildHeader(),
                SizedBox(height: Globals.screenHeight * 0.02),
                _buildSearchBar(),
                SizedBox(height: Globals.screenHeight * 0.02),
                Expanded(
                  child: _isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: Globals.customGreen,
                          ),
                        )
                      : _errorMessage != null
                          ? _buildErrorView()
                          : _campaigns.isEmpty
                              ? _buildEmptyView()
                              : _buildCampaignsList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Make a Difference',
              style: TextStyle(
                fontSize: Globals.screenHeight * 0.026,
                fontWeight: FontWeight.bold,
                color: Globals.customBlack,
              ),
            ),
            SizedBox(height: Globals.screenHeight * 0.005),
            Text(
              'Support causes that matter',
              style: TextStyle(
                fontSize: Globals.screenHeight * 0.016,
                color: Globals.customGreyDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Globals.customGreyLight,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: Globals.screenWidth * 0.03,
        vertical: Globals.screenHeight * 0.01,
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: Globals.customGreyDark,
            size: Globals.screenHeight * 0.025,
          ),
          SizedBox(width: Globals.screenWidth * 0.02),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search campaigns',
                hintStyle: TextStyle(
                  color: Globals.customGreyDark,
                  fontSize: Globals.screenHeight * 0.016,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: TextStyle(
                fontSize: Globals.screenHeight * 0.016,
              ),
              onChanged: (value) {
                setState(() {
                  if (value.isEmpty) {
                    _fetchCampaigns(); // Reset to full list when search is cleared
                  } else {
                    // Filter campaigns based on search text
                    _campaigns = _campaigns.where((campaign) {
                      final name =
                          campaign['campaign_name'].toString().toLowerCase();
                      final description = campaign['campaign_description']
                          .toString()
                          .toLowerCase();
                      final ngoName = campaign['ngo_details']['ngo_name']
                          .toString()
                          .toLowerCase();
                      final searchLower = value.toLowerCase();

                      return name.contains(searchLower) ||
                          description.contains(searchLower) ||
                          ngoName.contains(searchLower);
                    }).toList();
                  }
                });
              },
            ),
          ),
          SizedBox(width: Globals.screenWidth * 0.02),
          Icon(
            Icons.filter_list,
            color: Globals.customGreyDark,
            size: Globals.screenHeight * 0.025,
          ),
        ],
      ),
    );
  }

  Widget _buildCampaignsList() {
    return ListView.builder(
      physics: AlwaysScrollableScrollPhysics(),
      itemCount: _campaigns.length,
      itemBuilder: (context, index) {
        final campaign = _campaigns[index];
        return CampaignCard(
          id: campaign['id'],
          name: campaign['campaign_name'],
          description: campaign['campaign_description'],
          imageUrl: campaign['image_url'],
          ngoName: campaign['ngo_details']['ngo_name'],
          ngoLogoUrl: campaign['ngo_details']['logo_url'],
          fundsRequired: campaign['funds_required'],
          fundsCollected: campaign['funds_collected'],
          isCompleted: campaign['is_completed'],
        );
      },
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
            onPressed: _fetchCampaigns,
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

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.campaign_outlined,
            color: Globals.customGreyDark,
            size: Globals.screenHeight * 0.06,
          ),
          SizedBox(height: Globals.screenHeight * 0.02),
          Text(
            'No campaigns available',
            style: TextStyle(
              color: Globals.customGreyDark,
              fontSize: Globals.screenHeight * 0.018,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: Globals.screenHeight * 0.01),
          Text(
            'Check back later for new campaigns',
            style: TextStyle(
              color: Globals.customGreyDark,
              fontSize: Globals.screenHeight * 0.016,
            ),
          ),
        ],
      ),
    );
  }
}
