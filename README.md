
![Daansure!](https://github.com/user-attachments/assets/0996a25a-578e-4d94-aac4-6ca0d3d3a8d9)


# 🌍 Daansure – Ensuring every donation is used right
## Introduction
![alt text](https://img.shields.io/badge/Flutter-white?style=for-the-badge&logo=flutter&logoColor=02569B) 
![alt text](https://img.shields.io/badge/Supabase-181818?style=for-the-badge&logo=supabase&logoColor=white) 
![alt text](https://img.shields.io/badge/Express.js-white?style=for-the-badge)
![alt text](https://img.shields.io/badge/PostgreSQL-white?style=for-the-badge&logo=postgresql&logoColor=316192)
<br>
**Daansure** is a Flutter-based app that empowers NGOs to secure and manage funds transparently, ensuring accountability and donor trust through a blockchain-based centralized ledger.  
---

## 📱 **Demo Videos**
### User App
https://github.com/user-attachments/assets/4e03c1ea-dcfb-4c6f-986a-8c57a1b7551f



### NGO Website
https://github.com/user-attachments/assets/5317370e-0217-4c4e-bca4-b6d8d5898c9c



---
## 🚀 **Overview**  
NGOs often face challenges with securing and managing funds due to:  
- Misuse and lack of accountability  
- Difficulty in tracking donations  
- Fragmented and opaque payment systems prone to fraud  
**Daansure** solves these issues by providing a unified platform where NGOs can create campaigns, receive donations, and release funds based on verified milestones — ensuring complete transparency and building donor confidence.  
---
Here’s an improved version of the **Key Features** section with better clarity, conciseness, and engagement:  

---
## ⚙️ **Process**  
![PHOTO-2025-03-16-08-10-54](https://github.com/user-attachments/assets/67825533-1455-45e1-8413-113a03bcfbe8)
![PHOTO-2025-03-16-08-26-53](https://github.com/user-attachments/assets/66150906-b35f-4f67-aed5-f5e8d83a2ed6)

---

## 🎯 **Key Features**  

### ✅ **Seamless Campaign Management**  
- NGOs can create fundraising campaigns with detailed descriptions and milestones.  
- Donors can explore verified campaigns, track progress, and contribute easily.  

### ✅ **Milestone-Based Fund Release**  
- Funds are disbursed in **phases** based on pre-defined project milestones.  
- NGOs submit milestone completion reports, and donors **vote** to approve progress.  
- If **60% or more** donors approve, the next phase of funds is released.  

### ✅ **Secure & Immutable Transactions**  
- Every donation and fund release is logged on **IPFS**, ensuring tamper-proof records.  
- A cryptographic **hash of each transaction** is stored in PostgreSQL for added security.  

### ✅ **Reliable Payment Integration**  
- Powered by **Razorpay** for secure and **fast** donation processing.  
- Supports multiple payment methods for seamless donor contributions.  

### ✅ **Real-Time Transparency & Trust**  
- Donors receive **live updates** on fund allocation and usage.  
- Full visibility into how contributions are being utilized, fostering **accountability**.  

---

This version enhances readability while making the features feel more structured and engaging! 🚀 
---
## 🏗️ **Tech Stack**  
| Component | Technology |  
|-----------|------------|  
| **Frontend** | Flutter, React |  
| **Backend** | Node.js, Express.js |  
| **Database** | PostgreSQL |  
| **Blockchain** | IPFS (InterPlanetary File System) |  
| **Payment Gateway** | Razorpay |  
## 📦 Packages
| Name | Description |
| --- | --- |
| [`@cupertino_icons`](https://pub.dev/packages/cupertino_icons) | Cupertino Icons |
| [`@shared_preferences`](https://pub.dev/packages/shared_preferences) | Shared Preferences |
| [`@supabase_flutter`](https://pub.dev/packages/supabase_flutter) | Supabase |
| [`@razorpay_flutter`](https://pub.dev/packages/razorpay_flutter) | Razorpay |
| [`@http`](https://pub.dev/packages/http) | http |
---
## 📲 **Flow of the App**  
1. **NGO Campaign Creation** – NGOs create campaigns and list them on the platform.  
2. **Donor Contribution** – Users browse and select campaigns to donate to using Razorpay.  
3. **Milestone Release** – NGOs define milestones for each campaign.  
4. **Voting System** – Donors vote to verify milestone completion (60%+ approval needed).  
---
## 🔒 **Security and Integrity**  
- **Centralized Ledger** – Ensures immutability and data integrity.  
- **IPFS Logging** – All transactions are securely stored on the IPFS network.  
- **Hash Storage in PostgreSQL** – Ensures that transaction records cannot be altered.  
---
## Prerequisites
To run this app, you need to have Flutter installed on your system. If you haven't installed Flutter yet, please follow the official Flutter installation guide: [Flutter Installation](https://flutter.dev/docs/get-started/install)
## Getting Started
1. Clone this repository:
   ```bash
   git clone https://github.com/sidesshmore/DaanSure-ByteCamp
   ```
2. Change to the project directory:
   ```bash
   cd DaanSure-ByteCamp
   ```
3. Install the dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```
   This will launch the app on a connected device or emulator.

Note: You'll need to replace "insert_user_app_video_link_here" and "insert_ngo_website_video_link_here" with your actual video links. These could be links to YouTube videos, files in your repository, or any other hosting service you're using.
