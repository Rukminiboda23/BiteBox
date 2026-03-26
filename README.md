# 🍔 BiteBox - Full-Stack Restaurant Ordering & Reservation App

BiteBox is a comprehensive, cross-platform mobile application built with **Flutter** and **Firebase**. It bridges the gap between restaurant management and hungry customers by offering real-time order tracking, dynamic menu management, and seamless table reservations.

## ✨ Key Features

### 👨‍🍳 Admin Panel (Restaurant Owners)
* **Role-Based Access:** Secure login exclusively for admins.
* **Live Order Dashboard:** View and update incoming orders in real-time (Pending ➔ Preparing ➔ Completed).
* **Dynamic Menu Management:** Add new food items instantly. Images are uploaded, optimized, and hosted via the **Cloudinary REST API**.

### 🍕 Customer App
* **Responsive UI:** Modern, responsive grid layout that adapts to both Mobile and Web views.
* **Smart Cart System:** Add items, modify quantities, and calculate totals using `Provider` state management.
* **Live Order Tracking:** Simulated delivery tracking with animated map markers and status badges.
* **Table Reservations:** Users can easily book tables with integrated date and time pickers.
* **Push Notifications:** Firebase Cloud Messaging (FCM) alerts users when their order status changes.

## 🛠️ Tech Stack & Architecture

* **Frontend:** Flutter, Dart, Material 3 Design
* **Backend:** Firebase (Authentication, Cloud Firestore, Cloud Messaging)
* **State Management:** Provider pattern for reactive UI updates
* **Image Hosting:** Cloudinary API for optimized cloud storage
* **Payments:** Razorpay UI integration (Simulated for MVP)
* **Architecture:** MVC (Model-View-Controller) / Service-Oriented Architecture

## 🚀 How to Run the Project

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Rukminiboda23/BiteBox.git
