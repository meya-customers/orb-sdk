# Orb SDK
Welcome to the Orb SDK! This guide will help you integrate the Orb SDK into 
your existing Android or iOS application and allow you to connect to your 
Meya app.

First a bit of context about the Orb SDK. The Orb SDK is implemented using the 
cross platform Flutter framework and the Dart language. Flutter allows you to 
build high fidelity, fast apps targeting multiple platforms including Android,
iOS, Web, Linux, Windows and macOS. Currently the Orb SDK only supports the 
Android and iOS platforms.

This repo contains two folders, namely:
- `orb`: This is a **Flutter plugin** package and contains all the Dart code 
  and platform specific integration code for the core Orb SDK.
- `module`: This is a **Flutter module** that allows you to integrate the 
  Orb SDK into your native app. The `module` Flutter module depends on the 
  `orb` Flutter package.


## Getting started

### Install Android Studio
Follow the Android Studio installation instructions for your development
environment:

- [Windows/macOS/Linux/ChromeOs](https://developer.android.com/studio/install)


### Install Xcode
Follow the Xcode installation instructions for your development mac:

- [macOS](https://developer.apple.com/xcode/)


### Install Flutter
Follow the Flutter installation instructions for your development environment:

- [Windows](https://flutter.dev/docs/get-started/install/windows)
- [macOS](https://flutter.dev/docs/get-started/install/macos)
- [Linux](https://flutter.dev/docs/get-started/install/linux)
- [ChromeOs](https://flutter.dev/docs/get-started/install/chromeos)

Check your Flutter installation:

```shell
which flutter
flutter doctor
```

### Install Android Studio Flutter plugin
We recommend using Android Studio to view and edit any Flutter app/package/plugin/module.

Follow the Flutter editor setup instructions for your development environment:

- [Windows/macOs/Linux](https://flutter.dev/docs/get-started/editor?tab=androidstudio)

### Open `module` in Android Studio
- Open Android Studio
- Select `Open an Existing Project`
- Navigate to the `orb-sdk` repo folder and select the `module` folder
- Click `Open`

This will open the `module` Flutter project in Android Studio. The Flutter 
plugin in Android Studio will do a couple of things:
- Detect that it is a Flutter project and not an Android project.
- Run `flutter pub get`: this will read the `pubspec.yaml` file and download
  all the Flutter dependencies.
- Index all the Dart source code.
- Detect any running Android/iOS/Web devices

### Run the `module`
A Flutter module is not intended to be run on it's own, it's primary purpose is to integrate
the Flutter module into an existing native app. However, it is still possible to run a Flutter
module.

This is good to do initially to test that your Android and iOS environments work correctly 
and that everything compiles.

#### Run on Android
If you do not have one already you need to setup an Android Virtual Device:
- Go to `Tools > AVD Manager`
- Click `+ Create Virtual Device` at the bottom left
- From the `Phone` category, select a device e.g. `Pixel 3`
- Click `Next`
- Use the recommended release (you can customize this if you wish).
- Click `Next`
- Optionally set the `AVD Name`
- Click `Finish`
- From the `AVD Manager`, click the "Play" button of the device you've just 
  created.
  
Android Studio should automatically detect the AVD device and create a new run configuration for
the Android device.

- In the device dropdown menu, select `Refresh`
- Then select the AVD device you wish to target.
- Make sure the `main.dart` run configuration is selected in the dropdown to the right of the
  device dropdown menu.
- Click the "Play" button.

The Flutter plugin in Android Studio will now do a couple of things:
- It will run all the Gradle tasks to build and assemble the Android app
- It will install the Debug APK onto the AVD via `adb`
- It will launch the app on the AVD and connect the Flutter debugger

**Min SDK version build error**

If the Gradle build fails with the following error:

```text
AndroidManifest.xml Error:
  uses-sdk:minSdkVersion 16 cannot be smaller than version 18 declared in library [:orb] 
...
  Suggestion: use a compatible library with a minSdk of at most 16,
    or increase this project's minSdk version to at least 18,
    or use tools:overrideLibrary="ai.meya.orb" to force usage (may lead to runtime failures)
```

Then manually edit the generated Gradle build file:
- Open `.android/app/build.gradle`
- Change the line `minSdkVersion 16` to `minSdkVersion 18`
- Save the change
- Click the "Play" button again

You should see a screen saying `Ready to connect`.

#### Run on iOS
- In the device dropdown menu, select `Open iOS Simulator`
- This will launch the `iOS Simulator`
- In the `iOS Simulator`, go to `File > Open Simulator > iOS 14.4 > iPhone 11`
- This will open the iPhone simulator
- Once the simulator is running, Android Studio will detect the new device
- In the device dropdown menu, select the `iPhone 11 (mobile)` device
- Make sure the `main.dart` run configuration is selected in the dropdown to the right of the
  device dropdown menu.
- Click the "Play" button.

The Flutter plugin in Android Studio will now do a couple of things:
- It will run `pod install` and collect all the Cocoapod dependencies
- It will build the iOS app using XCode
- It will copy over the app bundle to the iPhone simulator and install the app
- It will connect the Flutter debugger

You should see a screen saying `Ready to connect`.

## Add to an Android app
### Project setup
In your terminal:
- Go to the `module` folder:
  `cd some/path/module`
- Run: `flutter build aar`
- This will build various AAR packages and create a local Gradle repository.
- Open your app's `app/build.gradle` file
- Ensure you have the following repositories configured:
  ```
  String storageUrl = System.env.FLUTTER_STORAGE_BASE_URL ?: "https://storage.googleapis.com"
  repositories {
      maven {
          url projectDir.absolutePath + '/some/relative/path/module/build/host/outputs/repo'
      }
      maven {
          url "$storageUrl/download.flutter.io"
      }
  }
  ```
- Make the app depend on the Flutter module
  ```
  dependencies {
      debugImplementation 'ai.meya.orb_module:flutter_debug:1.0'
      profileImplementation 'ai.meya.orb_module:flutter_profile:1.0'
      releaseImplementation 'ai.meya.orb_module:flutter_release:1.0'
  }
  ```
- Add the `profile` build type to your `android.buildTypes` e.g.:
  ```
  android {
    buildTypes {
      profile {
        initWith debug
      }
    }
  }
  ```
- Sync your `build.gradle` changes

For extra information on adding Flutter modules to Android, view the 
[Add to Android app Flutter documentation](https://flutter.dev/docs/development/add-to-app/android/project-setup#add-the-flutter-module-as-a-dependency)

### Add and launch the ChatActivity

- Create a `ChatActivity` class in your app.
- [Example Orb Demo `ChatActivity`](https://github.com/meya-customers/orb-demo-android/blob/main/app/src/main/java/ai/meya/orb_demo/ChatActivity.java)
- The Orb SDK provides an `OrbActivity` class to initialize, connect and 
  display the Orb in a full screen view.
- Make sure to set your **Meya App ID** in the `OrbConnectionOptions`. 
  Note, the `pageContext` is an arbitrary `Map<String, Object>` object that 
  you can use to send custom context data to your bot when the Orb connects.
- Add the `ChatActivity` to your `AndroidManifest.xml` file, see the 
  [example Orb Demo `AndroidManifest.xml` file](https://github.com/meya-customers/orb-demo-android/blob/main/app/src/main/AndroidManifest.xml#L24) 

  **Note**, make sure the `android:name` has the correct class path to where you 
  created the `ChatActivity` file.

  Also add the following permissions to allow Orb access to the photo gallery and
  camera:

  ```xml
  <uses-permission android:name="android.permission.CAMERA" />
  <queries>
      <intent>
          <action android:name="android.media.action.IMAGE_CAPTURE" />
      </intent>
  </queries>
  ```

- Start `ChatActivity`: 
  ```java
  myChatButton.setOnClickListener(new View.OnClickListener() {
      @Override
      public void onClick(View view) {
          startActivity(
              ChatActivity.createDefaultIntent(getBaseContext(), ChatActivity.class)
          );
      }
  });
  ```


## Add to an iOS app
### Project setup
Requirements:
- [CocoaPods](https://cocoapods.org/) v1.10 or later.

If your existing iOS app doesn't already have a Podfile, follow the 
[CocoaPods getting started guide](https://guides.cocoapods.org/using/using-cocoapods.html)
to add a `Podfile` to your project.

- Add the following to your `Podfile`:
  ```ruby
  orb_sdk_path = 'some/relative/path/module'
  load File.join(orb_sdk_path, '.ios', 'Flutter', 'podhelper.rb')
  ```

- For each Podfile target that needs to embed the Orb SDK, call 
  `install_all_flutter_pods(orb_sdk_path)` e.g.:
  ```ruby
  target `MyApp` do
      install_all_flutter_pods(orb_sdk_path)
  end
  ```

- Run `pod install`

**Note**, when you update the version of the `module` and/or `orb`, run 
`flutter pub get` in the `module` folder to refresh the list of dependencies 
read by `podhelper.rb`. Then, run `pod install` again for your application.

The `podhelper.rb` script embeds the `module` framework, `Flutter.framework` 
and any transitive Flutter plugin dependencies into your project.

Open your apps `.xcworkspace` file in Xcode and build using `Cmd+B`.

### Add and launch the Orb

- Create the `OrbInit.swift` file in your app's code folder.
- [Example Orb Demo `OrbInit.swift` file](https://github.com/meya-customers/orb-demo-ios/blob/main/OrbDemo/OrbInit.swift)
- This code extends the `Orb` class to initialize the Flutter engine with the
  correct plugins and initializes internal callbacks between the `Orb` class
  and the `OrbPlugin` class.

The Orb SDK gives you a lot of flexibility in how to initialize and show the
Orb chat, but the simplest method is to simply create a new instance of `Orb`
and display it's `ViewController` in **fullscreen** mode.

- Create a button and an `@IBAction` handler
- [Example Orb Demo `@IBAction` handler](https://github.com/meya-customers/orb-demo-ios/blob/main/OrbDemo/LaunchViewController.swift#L63)
- Set your **Meya App ID** in the `OrbConnectionOptions`. Note, the 
  `pageContext` is an arbitrary dictionary that you can use to send custom
  context data to your bot when the Orb connects.


### Flutter specific help
For help getting started with Flutter, view the online
[Flutter documentation](https://flutter.dev/).

For instructions integrating Flutter modules to your existing applications,
see the [add-to-app documentation](https://flutter.dev/docs/development/add-to-app).


# Push Notifications
The  Orb SDK supports handling push notifications when the Orb chat is not 
active. This is especially useful when a bot escalates the conversation to a 
human agent, but the agent takes a while to respond.

To fully setup push notifications you will need to configure the following 
three components:

1. Android Firebase Cloud Messaging (FCM)
2. Apple Push Notification service (APNs)
3. **Orb Mobile** integration in your Meya app.
   
   **Note**, this is **not** the same as the standard Orb integration used for 
   the web client. The Orb Mobile integration is identified by 
   `type: meya.orb.mobile.integration` - [here is an example configuration](https://github.com/meya-customers/demo-app/blob/master/integration/orb/mobile.yaml).
   You can still connect the Orb SDK to the Orb integration, but it will **not**
   handle any push notifications.


## Android Setup
### 1. Setup Firebase Cloud Messaging (FCM) on Android

Follow these instructions to add FCM to your app:
[Set up a Firebase Cloud Messaging client app on Android](https://firebase.google.com/docs/cloud-messaging/android/client)


### 2. Get your Firebase Service Account Key

- Open your [Firebase Console](https://console.firebase.google.com/)
- Select the project you're using for FCM
- Click gear icon next to **Project Overview**
- Go to **Project settings**
- Click on **Generate new private key**
- This will download a `.json` file to your computer


### 3. Add the Service Account Key to your app's vault

- Copy the JSON from the `.json` private key file you downloaded from the Firebase
  Console.
- Open your app's vault in the Meya Console
- Add the vault key named `orb.mobile.service_account_key`
- Paste the JSON you copied
- Click the ✓ button
- Click **Save**


### 4. Add the Orb Mobile integration to your app

Add the following BFML to you app, we recommend you save this file in the 
`integration/orb/mobile/` folder, but you can save this anywhere.

```yaml
id: integration.orb.mobile
type: meya.orb.mobile.integration
android:
  service_account_key: (@ vault.orb.mobile.service_account_key )
```

**Note**, the integration's ID is explicitly set in this example. If you do 
not explicitly set the ID then Meya will use the folder path (using `.` 
notation e.g. `some/folder/file.yaml` becomes `some.folder.file` ) as the 
integration's ID.


### 5. Push your Meya app

If you're in the Meya Console then clicking **Save** will save the BFML and 
push the changes to your app.

If you're using the Meya CLI then you'll need to do an explicit push:
```shell
meya push
```


### 6. Provide the FCM device token to the Orb SDK

- You need to capture and pass the FCM device token to the `Orb` class before you
  call `orb.connect()`. 
- [Example Orb Demo `ChatActivity`](https://github.com/meya-customers/orb-demo-android/blob/main/app/src/main/java/ai/meya/orb_demo/ChatActivity.java)
- Also make sure that your `ChatActivity` is registered in your app's 
  `AndroidManifest.xml` - [example Orb Demo manifest](https://github.com/meya-customers/orb-demo-android/blob/main/app/src/main/AndroidManifest.xml#L23)


Any activity can then be launched from the push notification when the Orb 
Mobile integration's `android.click_action` setting is set, here is an 
example BFML configuration for the Orb Demo app:

```yaml
id: integration.orb.mobile
type: meya.orb.mobile.integration
collect:
  location: user
identity_verification: (@ vault.orb.identity_verification )
android:
  service_account_key: (@ vault.orb.mobile.service_account_key )
  # This is the name of the activity you would like to launch that contains the
  # Orb SDK
  click_action: .ChatActivity
```


### 7. Test your push notifications

The best way to test push notifications is to:

- Escalate to an agent (e.g. Zendesk/Front), close the chat activity and send
  an agent message, or
- Send a message via a webhook while the app is closed, see how to set up 
  a [Webhook integration](https://docs.meya.ai/docs/making-api-calls).


### 8. Consider in-app notifications

The Orb Mobile integration will only send a push notification when it detects 
that the Orb is no longer active (it uses an internal heartbeat to detect 
inactivity). However, your app could be in a running state which means the 
push notification will **not** appear, and you'll need to handle
the incoming notification **explicitly** in a `FirebaseMessagingService` class.

The Orb Demo app has an example implementation of a `FirebaseMessagingService`
class [here](https://github.com/meya-customers/orb-demo-android/blob/main/app/src/main/java/ai/meya/orb_demo/OrbMessagingService.java).

The example implementation does not do anything special other than
log the received payloads. However, it's important to note that the Orb Mobile
integration always adds the `meya_integration_id` key to the push notification
data payload which allows you to identify Meya notifications and handle them 
separately from your own app notifications.

If you would like to still show a notification while the app is running, you 
can create a notification manually as shown in the FCM quick start app 
[here](https://github.com/firebase/quickstart-android/blob/cdf2619efe945f2b3d2536c805fbb71636adc96f/messaging/app/src/main/java/com/google/firebase/quickstart/fcm/java/MyFirebaseMessagingService.java#L161)

**Note**, advanced in-app push notification handling is on the Orb SDK roadmap
which will also provide features such as quick replies, buttons etc. 

## iOS Setup
### 1. Add APNs notifications to your app
   
- First [enable the Push Notifications Capability](https://developer.apple.com/documentation/usernotifications/registering_your_app_with_apns#overview) in your app
- You'll need to implement the various `application` hooks to register the app 
  for push notifications and receive the APNs device token.
- [Example Orb Demo `AppDelegate`](https://github.com/meya-customers/orb-demo-ios/blob/main/OrbDemo/AppDelegate.swift)
- You need to set the `orb.deviceToken` property before your call 
  `orb.connect()`. This can be done in the `application` lifecycle hook as 
  shown [here in the Orb Demo](https://github.com/meya-customers/orb-demo-ios/blob/main/OrbDemo/AppDelegate.swift#L52)
  , or you can store it in your app state and use it later in your view
  hierarchy.

**Note**, currently the Orb does **not** use [method swizzling](https://abhimuralidharan.medium.com/method-swizzling-in-ios-swift-1f38edaf984f)
to autoconfigure these hooks for you (this might be added in a future release), so
if you're using the Firebase SDK for iOS you'll need to disable Firebase's method 
swizzling and implement these methods manually.

### 2. Create your APNs auth key

- Open the [Apple Developer Member Center](https://developer.apple.com/account/)
- Go to **Certificates Identifiers & Profiles**
- Go to **Keys** in the menu to the left
- Click `+` icon next to the **Keys** title
- Give your new key a name
- Select **Apple Push Notifications service (APNs)**
- Click **Continue**
- Click **Register**
- Click **Download** to download the file
- Note the **Key ID**, you'll need this for the Orb Mobile integration config


### 3. Add the auth APNs credentials to your app's vault

- Copy the private key from the auth key file that you downloaded. 
- Open your app's vault in the Meya Console
- Add the vault key named `orb.mobile.auth_key`
- Paste the auth key you copied
- Click the ✓ button
- Copy the **Key ID** from the key you created, [Apple Developer Member Center / Keys](https://developer.apple.com/account/resources/authkeys/)
- Add the vault key named `orb.mobile.auth_key_id`
- Paste the auth key id you copied 
- Click the ✓ button
- Copy you Apple **Team ID**, this is at the top right of the page, under your 
  login name
- Add the vault key named `orb.mobile.team_id`
- Paste the team id you copied
- Click the ✓ button
- Click **Save**


### 4. Add the Orb Mobile integration to your app

Add the following BFML to you app, we recommend you save this file in the
`integration/orb/mobile/` folder, but you can save this anywhere.

```yaml
id: integration.orb.mobile
type: meya.orb.mobile.integration
ios:
  auth_key: (@ vault.orb.mobile.auth_key )
  auth_key_id: (@ vault.orb.mobile.auth_key_id )
  team_id: (@ vault.orb.mobile.team_id )
  topic: YOUR APP BUNDLE ID
```

**Note**, the integration's ID is explicitly set in this example. If you do
not explicitly set the ID then Meya will use the folder path (using `.`
notation e.g. `some/folder/file.yaml` becomes `some.folder.file` ) as the
integration's ID.


### 5. Push your Meya app

If you're in the Meya Console then clicking **Save** will save the BFML and 
push the changes to the app.

If you're using the Meya CLI then you'll need to do an explicit push
```shell
meya push
```


### 6. Test your push notifications

The best way to test push notifications is to:

- Escalate to an agent (e.g. Zendesk/Front), close the chat activity and send
  an agent message, or
- Send a message via a webhook while the app is closed, see how to set up
  a [Webhook integration](https://docs.meya.ai/docs/making-api-calls).


### 7. Consider in-app push notifications
As is the case with Android, the Orb Mobile integration will only send a 
push notification when it detects that the Orb is no longer active 
(it uses an internal heartbeat to detect inactivity). However, your app could
be in a running state which means the push notification will **not** appear, 
and you'll need to handle the incoming notification **explicitly** in your 
`application` hook with the `didReceiveNotification` parameter.

The Orb Demo app has an [example implementation of this hook](https://github.com/meya-customers/orb-demo-ios/blob/main/OrbDemo/AppDelegate.swift#L20).

The example implementation does not do anything special other than
log the received payloads. However, it's important to note that the Orb Mobile
integration always adds the `meya_integration_id` key to the push notification
data payload which allows you to identify Meya notifications and handle them
separately from your own app notifications.

**Note**, advanced in-app push notification handling is on the Orb SDK roadmap
which will also provide features such as quick replies, buttons etc. 
