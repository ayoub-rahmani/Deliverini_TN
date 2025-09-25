# Delivrini_TN

Delivrini_TN is a modern mobile application developed using Flutter and Dart, integrated with Firebase for backend services. It offers a seamless meal ordering experience with live messaging capabilities for real-time communication between clients and delivery personnel. The app features secure user authentication, dynamic meal customization, order management, push notifications, and responsive UI optimized for mobile devices.

## Features

- Secure Firebase Authentication supporting clients and delivery users.
- Real-time chat using Firebase Cloud Firestore.
- Customizable meal orders with ingredient selection.
- Live order status tracking and notifications.
- Smooth animations and responsive design.

---

## Getting Started

Follow the steps below to set up and run Delivrini_TN on your local machine.

### Prerequisites

- Flutter SDK installed. ([Flutter installation guide](https://flutter.dev/docs/get-started/install))
- A Firebase project configured with Authentication and Firestore.
- Android Studio or Visual Studio Code with Flutter and Dart plugins.
- An emulator or physical device for running the app.

### Installation Steps

1. Clone this repository:

    git clone https://github.com/ayoub-rahmani/Delivrini_TN.git cd Delivrini_TN

2. Install Flutter dependencies:

flutter pub get

3. Set up Firebase for your app:

- Create a Firebase project at [Firebase Console](https://console.firebase.google.com/).
- Enable **Authentication** (Email/Password or other providers as needed).
- Enable **Cloud Firestore** and set appropriate rules.
- Download the `google-services.json` file for Android and place it in `android/app/`.
- Download the `GoogleService-Info.plist` file for iOS and place it in `ios/Runner/`.

4. Configure Firebase in the Flutter app if needed, by verifying the `firebase_options.dart` or equivalent config files.

5. Run the app on your emulator or connected device:

flutter run

---

## Contribution

Contributions are welcome! To contribute:

- Fork the repository.
- Create a new feature branch.
- Commit your changes.
- Open a pull request describing the changes.

---

## License

This project is licensed under the MIT License.
