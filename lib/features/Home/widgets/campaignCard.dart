// lib/features/home/widgets/campaignCard.dart
import 'package:daansure/features/Home/widgets/campaignDetailScreen.dart';
import 'package:flutter/material.dart';
import 'package:daansure/constants.dart';

class CampaignCard extends StatelessWidget {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final String ngoName;
  final String? ngoLogoUrl;
  final double fundsRequired;
  final double fundsCollected;
  final bool isCompleted;

  const CampaignCard({
    Key? key,
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.ngoName,
    this.ngoLogoUrl,
    required this.fundsRequired,
    required this.fundsCollected,
    required this.isCompleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Globals.initialize(context);

    // Calculate progress percentage
    final progress = fundsCollected / fundsRequired;
    final progressPercentage = (progress * 100).toStringAsFixed(1);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CampaignDetailScreen(campaignId: id),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: Globals.screenHeight * 0.02),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campaign image
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: imageUrl != null && imageUrl!.isNotEmpty
                  ? Image.network(
                      imageUrl!,
                      height: Globals.screenHeight * 0.18,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: Globals.screenHeight * 0.18,
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
                      height: Globals.screenHeight * 0.18,
                      width: double.infinity,
                      color: Globals.customGreyLight,
                      child: Icon(
                        Icons.image_outlined,
                        color: Globals.customGreyDark,
                        size: Globals.screenHeight * 0.05,
                      ),
                    ),
            ),

            Padding(
              padding: EdgeInsets.all(Globals.screenHeight * 0.016),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // NGO information
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: ngoLogoUrl != null && ngoLogoUrl!.isNotEmpty
                            ? Image.network(
                                ngoLogoUrl!,
                                height: Globals.screenHeight * 0.026,
                                width: Globals.screenHeight * 0.026,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: Globals.screenHeight * 0.026,
                                    width: Globals.screenHeight * 0.026,
                                    color: Globals.customGreen.withOpacity(0.1),
                                    child: Icon(
                                      Icons.business_outlined,
                                      color: Globals.customGreen,
                                      size: Globals.screenHeight * 0.014,
                                    ),
                                  );
                                },
                              )
                            : Container(
                                height: Globals.screenHeight * 0.026,
                                width: Globals.screenHeight * 0.026,
                                color: Globals.customGreen.withOpacity(0.1),
                                child: Icon(
                                  Icons.business_outlined,
                                  color: Globals.customGreen,
                                  size: Globals.screenHeight * 0.014,
                                ),
                              ),
                      ),
                      SizedBox(width: Globals.screenWidth * 0.02),
                      Text(
                        ngoName,
                        style: TextStyle(
                          fontSize: Globals.screenHeight * 0.014,
                          color: Globals.customGreyDark,
                        ),
                      ),
                      if (isCompleted) ...[
                        Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: Globals.screenWidth * 0.02,
                            vertical: Globals.screenHeight * 0.003,
                          ),
                          decoration: BoxDecoration(
                            color: Globals.customGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Completed',
                            style: TextStyle(
                              fontSize: Globals.screenHeight * 0.012,
                              color: Globals.customGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  SizedBox(height: Globals.screenHeight * 0.01),

                  // Campaign name
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: Globals.screenHeight * 0.02,
                      fontWeight: FontWeight.bold,
                      color: Globals.customBlack,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: Globals.screenHeight * 0.005),

                  // Campaign description
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: Globals.screenHeight * 0.015,
                      color: Globals.customGreyDark,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: Globals.screenHeight * 0.012),

                  // Progress bar and fund information
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '₹${fundsCollected.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: Globals.screenHeight * 0.015,
                              fontWeight: FontWeight.bold,
                              color: Globals.customGreen,
                            ),
                          ),
                          Text(
                            '$progressPercentage%',
                            style: TextStyle(
                              fontSize: Globals.screenHeight * 0.015,
                              fontWeight: FontWeight.bold,
                              color: Globals.customGreyDark,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: Globals.screenHeight * 0.006),

                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress.clamp(0.0, 1.0),
                          backgroundColor: Globals.customGreyLight,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Globals.customGreen,
                          ),
                          minHeight: Globals.screenHeight * 0.01,
                        ),
                      ),

                      SizedBox(height: Globals.screenHeight * 0.006),

                      Text(
                        'Target: ₹${fundsRequired.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: Globals.screenHeight * 0.013,
                          color: Globals.customGreyDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
