


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

### 3. Firebase Configuration

This project requires Firebase to run correctly.

#### Step 1: Create Firebase Project

1. Go to [https://console.firebase.google.com/](https://console.firebase.google.com/)
2. Click **Add Project**
3. Follow the setup steps

#### Step 2: Register App

* For **Android**:

  * Package name: `<your.package.name>`
  * Download `google-services.json`
  * Place it inside:

    ```
    android/app/google-services.json
    ```

* For **iOS**:

  * Download `GoogleService-Info.plist`
  * Place it inside:

    ```
    ios/Runner/GoogleService-Info.plist
    ```

#### Step 3: Enable Firebase Services

TODODODODOD


Enable the following services from Firebase Console:

* **Authentication**

  * Email/Password
* **Cloud Firestore** (or Realtime Database)

---

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

