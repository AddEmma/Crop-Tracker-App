# Crop-Tracker-App

A simple Flutter application to help farmers and gardeners track their crops from planting to harvest.                                                                                       It allows adding, viewing, and managing crops with key details such as planting date, expected harvest date, notes, and growth status.

Setup Instructions                                                                                                                                                                          **1. Prerequisites**
[Flutter SDK](https://docs.flutter.dev/get-started/install) (version 3.35.1)
- Dart SDK (bundled with Flutter)
- Android Studio / VS Code with Flutter extensions
- A connected device or emulator:
- **Android:** physical device with USB debugging enabled or an Android emulator  
- **iOS:** physical device or simulator (requires macOS and an Apple Developer account for real device deployment)

# Install Dependencies
flutter pub get
# Run the App
flutter run
# Run Tests
flutter test

# State Management
This project uses Provider for state management.
**Why Provider?**
- Lightweight and officially recommended by the Flutter team.
- Simple API for dependency injection and reactive UI updates.
- Scales well for small to medium applications like Crop Tracker.
- Makes it easy to listen to changes in crop data across multiple screens.

# Assumptions & Limitations
Assumptions:
- Crops always have a planting date and an expected harvest date.
- Growth follows a linear timeline (no seasonal/weather adjustments).
- Users will input realistic dates within the provided validation ranges.
- Notes are optional but limited to 500 characters.

Limitations:
- No backend/database integration yet — all data is stored locally (using shared_preferences).
- Images are static placeholders (e.g., assets/icons/crop.jpg) and not crop-specific.
- Notifications/reminders for harvest are not implemented.
- Works best on mobile devices; desktop/web support is not optimized.

# Tests
Model Tests: Ensure Crop model serialization, deserialization, and copy behavior are correct.
Validator Tests: Confirm crop name and date validation rules work as intended.
