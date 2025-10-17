# 🏥 DiaMonitor – Digital Clinic Management System

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com/)
[![Laravel](https://img.shields.io/badge/Laravel-FF2D20?style=for-the-badge&logo=laravel&logoColor=white)](https://laravel.com/)
[![React](https://img.shields.io/badge/React-20232A?style=for-the-badge&logo=react&logoColor=61DAFB)](https://reactjs.org/)

<p align="center">
  <img src="https://github.com/bin2812/Medicare-Diamonitor/blob/master/demo-bac-si.gif?raw=true" width="300px" />
  <img src="https://github.com/bin2812/Medicare-Diamonitor/blob/master/demo-benh-nhan.gif?raw=true" width="300px" />
</p>

## 📱 Product Overview

DiaMonitor is a comprehensive digital clinic management system designed to revolutionize healthcare administration and patient experience. The platform seamlessly connects patients, doctors, medical staff, and administrators within a unified digital ecosystem, streamlining clinic operations from appointment scheduling to financial management.

Whether you're a small clinic looking to digitize operations or a large medical facility seeking to enhance patient care efficiency, DiaMonitor provides the tools and insights needed to deliver modern, professional healthcare services.

## 🎯 Objectives & Core Purpose

### Primary Mission
To bridge the gap between traditional healthcare practices and modern digital expectations through an integrated platform that enhances both patient experience and clinic operational efficiency.

### Key Goals
- **Patient Experience**: Simplify appointment booking, health record management, and prescription tracking
- **Clinic Efficiency**: Optimize financial management, staff coordination, and information synchronization
- **Digital Transformation**: Prepare for future integration with AI, telemedicine, and big data analytics
- **Transparency**: Provide clear, digitized records of appointments, invoices, and prescriptions

## ✨ Key Features

### 🔐 Multi-Role Authentication & Security
- Secure login system for patients, doctors, staff, and administrators
- Role-based access control (RBAC) with granular permissions
- JWT authentication with bcrypt password encryption
- AES256 encryption for sensitive medical data

### 👤 Comprehensive User Management
- **Patient Profiles**: Complete health records, demographics, medical history
- **Doctor Management**: Credentials, experience, availability, specializations
- **Staff Administration**: Role assignment and permission management
- **Family Account Linking**: Parents managing children's health records

### 📅 Advanced Appointment System
- **Smart Scheduling**: Real-time availability based on doctor schedules
- **Check-in System**: QR code scanning for quick patient processing
- **Automatic Notifications**: Email & SMS reminders 24h before appointments
- **Rescheduling & Cancellation**: Easy modification with instant notifications

### 💊 Medical Records & Prescriptions
- **Digital Health Records**: Comprehensive patient history with image support
- **Prescription Management**: Drug interaction checking and dosage validation
- **Document Storage**: X-rays, lab results, CT scans in digital format
- **PDF Export**: Downloadable prescriptions and medical certificates

### 💰 Financial Management
- **Multi-Payment Support**: Cash, VNPay, MoMo integration
- **Automated Invoicing**: QR-verified electronic invoices
- **Financial Analytics**: Revenue tracking by department, doctor, and period
- **Insurance Integration**: Support for health insurance processing

### 📊 Analytics & Reporting
- **Real-time Dashboard**: Patient statistics, appointment status, revenue trends
- **Patient Demographics**: Age, gender, and specialty-based analytics
- **Performance Metrics**: Doctor workload and patient satisfaction ratings
- **Export Capabilities**: Excel/PDF reports for management presentations

## 🛠️ Technologies Used

### Mobile Applications (Flutter)
- **Flutter** with Dart for cross-platform mobile development
- **Firebase** for real-time database and authentication
- **State Management** with Provider/Riverpod
- **Local Storage** with SQLite for offline capabilities

### Web Admin Panel (React)
- **React.js** with Vite for fast development and deployment
- **Tailwind CSS** for responsive, customizable UI
- **Axios** for API communication
- **Chart.js** for data visualization

### Backend Infrastructure
- **Laravel (PHP)** for robust API development and business logic
- **MySQL/MariaDB** for relational data storage
- **RESTful APIs** for seamless frontend-backend communication
- **Middleware** for security, logging, and request validation

### Cloud & Deployment
- **AWS/Digital Ocean** for scalable hosting
- **SSL/TLS** certificates for secure connections
- **Automated Backups** with daily database snapshots
- **CI/CD Pipeline** with GitHub Actions

## 🚀 Installation Guide

### Prerequisites
- **Node.js** >= 18.0.0
- **Flutter SDK** >= 3.0.0
- **PHP** >= 8.1 with Composer
- **MySQL** >= 8.0
- **Git** for version control

### Required Accounts
- **Firebase** project for mobile app backend
- **Cloudinary** account for image management
- **Payment Gateway** (VNPay/MoMo) for financial transactions

### Step-by-Step Installation

#### 1. Clone the Repository
```bash
git clone https://github.com/your-username/diamonitor.git
cd diamonitor
```

#### 2. Backend Setup (Laravel)
```bash
cd backend
composer install
cp .env.example .env
php artisan key:generate
php artisan migrate --seed
php artisan serve
```

#### 3. Mobile App Setup (Flutter)
```bash
cd doctorapp
flutter pub get
flutter run

cd ../userapp  
flutter pub get
flutter run
```

#### 4. Web Admin Setup (React)
```bash
cd admin-panel
npm install
npm run dev
```

#### 5. Configuration
```env
# Database Configuration
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=diamonitor
DB_USERNAME=root
DB_PASSWORD=

# Firebase Configuration
FIREBASE_API_KEY=your_firebase_api_key
FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
FIREBASE_PROJECT_ID=your_project_id

# Payment Gateway
VNPAY_TMN_CODE=your_vnpay_code
VNPAY_HASH_SECRET=your_vnpay_secret
```

## 📋 System Architecture

### User Roles & Permissions
- **Super Admin**: Full system access and configuration
- **Doctors**: Patient management, prescriptions, medical records
- **Reception Staff**: Check-in, scheduling, payment processing
- **Accountants**: Financial reports and invoice management
- **Patients**: Appointment booking, health record access

### Database Schema
- **patients**: User demographics and medical history
- **doctors**: Professional credentials and availability
- **appointments**: Scheduling and status tracking
- **invoices**: Financial transactions and payments
- **medicines**: Drug inventory and prescription data
- **promotions**: Marketing campaigns and discounts

## 🔒 Security Features

- **Data Encryption**: AES256 for sensitive medical information
- **Access Control**: Role-based permissions with session management
- **Audit Logging**: Complete activity tracking for compliance
- **Backup Strategy**: Automated daily backups with encryption
- **GDPR Compliance**: Patient data protection and privacy controls

## 📈 Future Roadmap

### Phase 1 (Current)
- ✅ Core appointment management
- ✅ Basic financial tracking
- ✅ Patient record digitization

### Phase 2 (Next 6 months)
- 🔄 AI-powered symptom checker
- 🔄 Telemedicine integration
- 🔄 Advanced analytics dashboard

### Phase 3 (Next 12 months)
- 📅 Wearable device integration
- 📅 Blockchain health records
- 📅 Predictive health analytics

## 🤝 Contributing

We welcome contributions from the community! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details on how to get started.
---

**DiaMonitor** - Transforming healthcare through digital innovation 🏥✨
