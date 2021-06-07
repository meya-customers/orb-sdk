# Meya Orb Mobile SDK 
This project is structured as a Flutter plugin which contains all the Dart code
for the Orb widgets as well as the native Android & iOS Orb APIs to start the 
Orb and send/receive events.

## Development
A Flutter plugin is not meant to be run on it's own because it contains no 
`main.dart` entry point. So for development you need to create a separate 
Flutter app and include this `orb` Flutter plugin as a dependency.

For convenience, we've created an `example` Flutter app nested under the plugin
that you can use for development.

The `example` Flutter app serves two purposes:
1. Setup a Flutter development environment allowing to Flutter debugging, hot reload etc.
2. Use the Orb native APIs to start the Orb this includes:
  - Starting the Flutter Engine
  - Passing in Orb connection options 
  - Connecting into the Orb lifecycle events

### Run the `example` app
- Open Android Studio
- Select `Open an Existing Project`
- Navigate to the `orb` directory and select the `example` directory
- Click `Open`

This will open the `example` Flutter project in Android Studio. The Flutter 
plugin in Android Studio will do a couple of things:
- Detect that it is a Flutter project and not an Android project.
- Run `flutter pub get`: this will read the `pubspec.yaml` file and download
  all the Flutter dependencies.
- Index all the Dart source code.
- Detect any running Android/iOS/Web devices

### Code Formatting
- Format Dart code: `flutter format .`
- Sort Dart imports: `flutter pub run import_sorter:main --no-comments`
