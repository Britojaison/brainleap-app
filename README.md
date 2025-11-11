# BrainLeap Flutter App

AI-assisted learning application built with Flutter.

## Features

- 🎨 **Interactive Whiteboard Canvas** - Draw answers and get real-time feedback
- 🤖 **AI-Powered Hints** - Get intelligent hints based on your work
- ✅ **Answer Evaluation** - AI evaluation of your canvas drawings
- 👤 **User Authentication** - Secure login and registration
- 📊 **Progress Tracking** - Track your learning journey
- 💾 **Session Persistence** - Resume where you left off

## Prerequisites

- Flutter SDK (>=3.3.0)
- Dart SDK
- iOS Simulator / Android Emulator / Physical Device

## Getting Started

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Environment Configuration

Create a `.env` file in the root directory:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
BACKEND_BASE_URL=http://localhost:4000
```

### 3. Run the App

```bash
# Development mode
flutter run

# Release mode
flutter run --release
```

## Project Structure

```
lib/
├── config/
│   └── environment.dart          # Environment configuration
├── models/
│   ├── ai_hint.dart             # AI hint model
│   ├── topic.dart               # Topic model
│   └── user.dart                # User profile model
├── providers/
│   ├── ai_assistant_provider.dart  # AI assistant state management
│   └── auth_provider.dart       # Authentication state management
├── services/
│   ├── api_service.dart         # API client
│   └── supabase_service.dart    # Supabase client
├── utils/
│   └── constants.dart           # App constants
├── views/
│   ├── ai_hint_view.dart        # AI hint display
│   ├── answer_canvas_view.dart  # Drawing canvas
│   ├── dashboard_view.dart      # Dashboard
│   ├── home_view.dart           # Home screen
│   ├── login_view.dart          # Login screen
│   └── topic_selection_view.dart # Topic selection
├── widgets/
│   ├── ai_hint_button.dart      # AI hint button
│   └── whiteboard_canvas.dart   # Whiteboard widget
└── main.dart                     # App entry point
```

## Key Technologies

- **State Management**: Provider
- **HTTP Client**: http package
- **Backend**: Supabase
- **Environment Variables**: flutter_dotenv
- **Local Storage**: shared_preferences

## Configuration

### API Timeout

Default timeout is 30 seconds. Modify in `lib/utils/constants.dart`:

```dart
class AppConfig {
  static const int apiTimeout = 30; // seconds
}
```

### Storage Keys

Session data is stored locally using SharedPreferences. Keys are defined in `lib/utils/constants.dart`.

## Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

## Building for Production

### Android

```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

### Web

```bash
flutter build web --release
```

## Troubleshooting

### Common Issues

1. **Missing dependencies**: Run `flutter pub get`
2. **Environment variables not loading**: Ensure `.env` file exists and is properly formatted
3. **API timeout errors**: Check network connection and backend URL

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License.
