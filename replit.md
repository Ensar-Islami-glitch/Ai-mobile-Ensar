# AI Mobile App - Ensar Islami

## Overview
Flutter web application with Supabase authentication. Features a login screen with email and password authentication, error handling via SnackBar, and navigation to a home page upon successful login.

## Recent Changes
- **2025-10-23**: Initial Flutter project setup with Supabase integration
  - Installed Flutter and Chromium via Nix package manager
  - Created login page with email/password authentication
  - Integrated supabase_flutter package for authentication
  - Configured workflow to run on port 5000
  - Set up deployment configuration

## Project Architecture

### Tech Stack
- **Framework**: Flutter 3.32.0 for Web
- **Authentication**: Supabase (supabase_flutter v2.5.0)
- **Language**: Dart 3.8.0

### Project Structure
```
lib/
├── main.dart           # App entry point, Supabase initialization
├── login_page.dart     # Login screen with form validation
└── home_page.dart      # Home screen after successful authentication

web/
├── index.html          # HTML entry point
├── manifest.json       # PWA manifest
└── flutter_bootstrap.js # Flutter initialization script

pubspec.yaml            # Dependencies and project configuration
```

### Features
1. **Login Screen**
   - Email and password input fields with validation
   - Password visibility toggle
   - Loading indicator during authentication
   - Error handling with SnackBar messages
   - Material 3 design

2. **Authentication Flow**
   - Supabase email/password authentication
   - Session management
   - Automatic navigation to home page on success
   - Error messages for invalid credentials

3. **Home Page**
   - Displays logged-in user's email
   - Logout functionality
   - Returns to login screen after logout

## Environment Variables
The app requires two Supabase environment variables (stored in Replit Secrets):
- `SUPABASE_URL`: Your Supabase project URL  
- `SUPABASE_ANON_KEY`: Your Supabase anonymous key

These are passed to the Flutter app via `--dart-define` flags.

## Running the App

### Development
The app runs automatically via the configured workflow:
```bash
flutter run -d web-server --web-hostname=0.0.0.0 --web-port=5000 \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
```

### Manual Run
```bash
flutter pub get
flutter run -d web-server --web-hostname=0.0.0.0 --web-port=5000 \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
```

## Deployment
The app is configured for autoscale deployment using Replit's deployment system. It will:
1. Build the web app with `flutter build web`
2. Run the production server on port 5000

## User Preferences
None specified yet.

## Next Steps
Potential enhancements:
- Add user registration flow
- Implement password reset functionality
- Add AI features to the home page
- Enhance UI/UX with animations
- Add profile management
