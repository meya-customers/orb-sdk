# Meya Orb Mobile SDK 

Orb Mobile SDK for Android and iOS

## Getting Started

For help getting started with Flutter, view our online
[documentation](https://flutter.dev/).

1. Install [Dart](https://dart.dev/get-dart)
2. Install [Flutter](https://flutter.dev/docs/get-started/install/macos)
3. Run `flutter doctor`
4. Open orb/flutter in Android Studio
5. Set Dart SDK path in Android Studio
6. Set Flutter SDK path in Android Studio
7. Run main.dart using a selected device

### Run on iOS Simulator
- `sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer`
- `sudo xcodebuild -license`
- `open -a Simulator`
- Select an iOS version to start from `File > Open Simulator > iOS 14.4`
- Go to Android Studio and select `iPhone ...` from the devices list and click the run icon to 
  compile and run the app on the iOS simulator.

## Formatting

`dartfmt --fix -w lib test`

`flutter pub run import_sorter:main --no-comments`

## Icons

### svgcleaner
SVG icons must be clean i.e. all styles need to be inlined using `svgcleaner`

Install `svgcleaner`:
- `brew install --cask svgcleaner`

Download your SVG files to your local machine.

Run `svgcleaner` on your files:


### SVGO
Install:
- `npm -g install svgo`

### Clean file script
```shell script
#!/bin/sh

SOURCE_DIR=$1
DEST_DIR=$2

for SOURCE_FILE in $(find . -type f -iname "*.svg"); do
  FILE=$(echo "$SOURCE_FILE" | cut -c 3-)
  DEST_FILE=$(echo "$DEST_DIR/$FILE")
  echo "$DEST_FILE"
  # scour -i $SOURCE_FILE -o $DEST_FILE
  # svgo --config svgo-config.js $SOURCE_FILE -o $DEST_FILE
  svgcleaner $SOURCE_FILE $DEST_FILE
done
```