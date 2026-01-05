


# Promise

## Overview & Motivation

Promise is a Flutter-based application designed to help users organize their schedules and collaborate with friends. In addition to managing personal plans, users can “promise” each other to complete shared tasks and track one another’s progress. The app includes a point-based reward system that allows users to strengthen their in-game relationships and unlock fun features as they stay consistent with their commitments. .

---

## Technologies Used

- **Flutter** (SDK)
- **Dart**
- **Firebase**
  - Authentication
  - Firestore / Realtime Database
- **Provider** (State Management)

---

# How to Run

Before running the project, make sure you have the following installed:

* **Flutter SDK** (^3.10.x)
* **Dart SDK**
* **Android Studio** or **VS Code**
* **Android Emulator** or **Physical Device**
* A **Firebase account**

To verify Flutter installation:

```
flutter doctor
```

---

## Setup Instructions

### 1. Clone the Repository

```
git clone https://github.com/cemfukara/CS310
cd CS310
```

---

### 2. Install Dependencies

```
flutter pub get
```

---

3. Firebase Configuration
This project requires Firebase to run correctly.

Step 1: Create Firebase Project
Go to https://console.firebase.google.com/

Click Add Project

Follow the setup steps

Step 2: Register App
For Android:

Package name: com.example.promise (Check android/app/build.gradle to confirm)

Download google-services.json

Place it inside:

android/app/google-services.json
For iOS:

Download GoogleService-Info.plist

Place it inside:

ios/Runner/GoogleService-Info.plist
Step 3: Enable Firebase Services
Enable the following services from the Firebase Console to ensure the app functions correctly.

1. Authentication

Go to Build > Authentication in the side menu.

Click Get Started.

Select Email/Password from the Sign-in providers list.

Toggle Enable and click Save.

2. Cloud Firestore

Go to Build > Firestore Database.

Click Create Database.

Select your preferred location (e.g., eur3 or us-central1).

Select Start in Test Mode (for easiest setup) and click Create.

3. Update Security Rules (Crucial) To allow the app to read and write data (create promises, add friends), update the rules:

Go to the Rules tab in Firestore Database.

Replace the existing code with the following:

Kod snippet'i

rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
Click Publish.

4. Create Indexes (If prompted)

Run the app and log in.

If you see an app crash or empty list with a message "The query requires an index" in the debug console:

Click the link provided in the console error. This will automatically create the necessary composite index for sorting promises.

### 4. Run the Application

```
flutter run
```

---

## Running Tests

To run all tests in the project:

```
flutter test
```

This includes unit tests and widget tests located in the `test/` directory.

### Test

TODO

---

## Known Limitations / Bugs

TODO

---

