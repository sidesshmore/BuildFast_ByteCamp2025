# 🌍 Daansure – Ensuring every donation is used right

## Introduction
![alt text](https://img.shields.io/badge/Flutter-white?style=for-the-badge&logo=flutter&logoColor=02569B) 
![alt text](https://img.shields.io/badge/Supabase-181818?style=for-the-badge&logo=supabase&logoColor=white) 
![alt text](https://img.shields.io/badge/Express.js-white?style=for-the-badge)
![alt text](https://img.shields.io/badge/PostgreSQL-white?style=for-the-badge&logo=postgresql&logoColor=316192)

**Daansure** is a Flutter-based app that empowers NGOs to secure and manage funds transparently, ensuring accountability and donor trust through a blockchain-based centralized ledger.  

---

## 🚀 **Overview**  
NGOs often face challenges with securing and managing funds due to:  
- Misuse and lack of accountability  
- Difficulty in tracking donations  
- Fragmented and opaque payment systems prone to fraud  

**Daansure** solves these issues by providing a unified platform where NGOs can create campaigns, receive donations, and release funds based on verified milestones — ensuring complete transparency and building donor confidence.  

---

## 🎯 **Key Features**  
✅ **Campaign Management**  
- NGOs can create and list campaigns.  
- Donors can browse and select campaigns to support.  

✅ **Milestone-Based Fund Release**  
- NGOs set milestones to ensure proper fund allocation.  
- Donors can vote to approve milestone completion.  
- If 60% or more donors approve, funds are released.  

✅ **Secure and Immutable Transactions**  
- Transactions are recorded in an **IPFS peer-to-peer system**.  
- A hash of each transaction is stored in a **PostgreSQL** database, ensuring data integrity.  

✅ **Payment Integration**  
- Uses **Razorpay** for secure and reliable payment processing.  

✅ **Transparency and Trust**  
- Real-time updates on fund usage.  
- Complete visibility for donors into how their contributions are utilized.  

---

## 🏗️ **Tech Stack**  
| Component | Technology |  
|-----------|------------|  
| **Frontend** | Flutter,React |  
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
