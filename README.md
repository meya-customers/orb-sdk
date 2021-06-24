# Orb SDK
Welcome to the Orb SDK! This guide will help you integrate the Orb SDK into your existing Android or
iOS application and allow you to connect to your Meya app.

First a bit of context about the Orb SDK. The Orb SDK is implemented using the cross platform 
Flutter framework and the Dart language. Flutter allows you to build high fidelity, fast apps
targeting multiple platforms including Android, iOS, Web, Linux, Windows and macOS. Currently 
the Orb SDK only supports the Android and iOS platforms.

This repo contains two folders, namely:
- `orb`: This is a **Flutter plugin** package and contains all the Dart code and platform 
  specific integration code for the core Orb SDK.
- `module`: This is a **Flutter module** that allows you to integrate the Orb SDK into your
  native app. The `module` Flutter module depends on the `orb` Flutter package.


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

1. Create the `ChatActivity`

The Orb SDK provides an `OrbActivity` class to initialize, connect and display the Orb in
a full screen page. First you create your own `ChatActivity` and add it to your 
`AndroidManifest.xml` file under your application tag.

Create a new class named `ChatActivity` and copy/paste this following code:
```java
import ai.meya.orb.Orb;
import ai.meya.orb.OrbActivity;

import android.os.Bundle;
import android.util.Log;

import ai.meya.orb.OrbConnectionOptions;

import java.util.HashMap;
import java.util.Map;


public class ChatActivity extends OrbActivity {
    private static final String TAG = "ChatActivity";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        String platformVersion = "Android " + android.os.Build.VERSION.RELEASE;

        Map<String, Object> pageContext = new HashMap<>();
        pageContext.put("platform_version", platformVersion);
        pageContext.put("key1", 1235);

        Map<String, Object> data = new HashMap<>();
        data.put("key1", "value1");
        data.put("key2", 12345.9);
        data.put("bool", true);
        pageContext.put("data", data);
        
        OrbConnectionOptions connectionOptions = new OrbConnectionOptions(
                "https://grid.meya.ai",
                "YOUR MEYA APP ID",
                "integration.orb.mobile",
                pageContext
        );

        if (!orb.ready) {
            orb.setOnReadyListener(new Orb.ReadyListener() {
                public void onReady() {
                    Log.d(TAG, "Orb runtime ready");
                    orb.connect(connectionOptions);
                }
            });
        } else {
            orb.connect(connectionOptions);
        }

        orb.setOnCloseUiListener(new Orb.CloseUiListener() {
            @Override
            public void onCloseUi() {
                Log.d(TAG, "Close Orb");
                finish();
            }
        });
    }
}
```

Set your **Meya App ID** in the `OrbConnectionOptions`. Note, the `pageContext` is and
arbitrary map that you can use to send context data to your bot when the Orb connects.

2. Add the `ChatActivity` to your `AndroidManifest.xml` file

```xml
<activity
    android:name=".ChatActivity"
    android:theme="@style/Theme.OrbDemo"
    android:configChanges="orientation|keyboardHidden|keyboard|screenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
    android:hardwareAccelerated="true"
    android:windowSoftInputMode="adjustResize"
/>
```

**Note**, make sure the `android:name` has the correct class path to where you created the `ChatActivity` file.

Also add the following permissions to allow Orb to take access the photo gallery and
to take pictures:

```xml
<uses-permission android:name="android.permission.CAMERA" />
<queries>
    <intent>
        <action android:name="android.media.action.IMAGE_CAPTURE" />
    </intent>
</queries>
```

3. Start `ChatActivity`

Add the following code to a button in your app:

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

If your existing iOS app doesn't already have a Podfile, follow the [CocoaPods getting started guide](https://guides.cocoapods.org/using/using-cocoapods.html)
to add a `Podfile` to your project.

1. Add the following to your `Podfile`:
```ruby
orb_sdk_path = 'some/relative/path/module'
load File.join(orb_sdk_path, '.ios', 'Flutter', 'podhelper.rb')
```

2. For each Podfile target that needs to embed the Orb SDK, call `install_all_flutter_pods(orb_sdk_path)` e.g.
```ruby
target `MyApp` do
    install_all_flutter_pods(orb_sdk_path)
end
```

3. Run `pod install`

**Note**, when you update the version of the `module` and/or `orb`, run `flutter pub get` in the `module` folder
to refresh the list of dependencies read by `podhelper.rb`. Then, run `pod install` again for your application.

The `podhelper.rb` script embeds the `module` framework, `Flutter.framework` and any transitive Flutter plugin 
dependencies into your project.

Open your apps `.xcworkspace` file in Xcode and build using `Cmd+B`.

### Add and launch the Orb

1. Add the `OrbInit.swift` file.

Create a new Swift file called `OrbInit.swift` in your app's code folder. Copy/past the following code:

```swift
import file_picker
import flutter_secure_storage
import image_picker
import orb
import package_info_plus
import path_provider
import url_launcher


extension Orb {
    public func initialize() {
        // Start the Flutter engine
        engine.run()
        
        // Register all required Flutter plugins
        if let registrar = engine.registrar(forPlugin: "OrbPlugin") {
            OrbPlugin.register(with: registrar)
        }
        if let registrar = engine.registrar(forPlugin: "FilePickerPlugin") {
            FilePickerPlugin.register(with: registrar)
        }
        if let registrar = engine.registrar(forPlugin: "FlutterSecureStoragePlugin") {
            FlutterSecureStoragePlugin.register(with: registrar)
        }
        if let registrar = engine.registrar(forPlugin: "FLTImagePickerPlugin") {
            FLTImagePickerPlugin.register(with: registrar)
        }
        if let registrar = engine.registrar(forPlugin: "FLTPackageInfoPlusPlugin") {
            FLTPackageInfoPlusPlugin.register(with: registrar)
        }
        if let registrar = engine.registrar(forPlugin: "FLTPathProviderPlugin") {
            FLTPathProviderPlugin.register(with: registrar)
        }
        if let registrar = engine.registrar(forPlugin: "FLTURLLauncherPlugin") {
            FLTURLLauncherPlugin.register(with: registrar)
        }
        
        self.initCallbacks()
    }
}
```

This code extends the `Orb` class to initialize the Flutter engine with the correct plugins.

2. Add `Orb` to your main `AppDelegate` e.g.:
```swift
import UIKit
import orb

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    lazy var orb = Orb()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        orb.initialize()
        return true
    }
}
```

This will create the main `Orb` object which creates a Flutter engine. Then calling `orb.initialize()` will 
start the Flutter engine and register all the plugins.

3. Start and connect the `Orb`.

In either an existing or new ViewController start the orb as follows:

```swift
import UIKit
import Flutter
import orb

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button = UIButton(type: UIButton.ButtonType.custom)
        button.addTarget(self, action: #selector(showOrb), for: .touchUpInside)
        button.setTitle("Show Orb", for: UIControl.State.normal)
        button.frame = CGRect(x: 80.0, y: 210.0, width: 160.0, height: 40.0)
        button.backgroundColor = UIColor.blue
        self.view.addSubview(button)
        
    }
    
    @IBAction func showOrb(sender: UIButton) {
        let orb = (UIApplication.shared.delegate as! AppDelegate).orb
        let platformVersion = "iOS " + UIDevice.current.systemVersion
        orb.connect(
            options: OrbConnectionOptions(
                gridUrl: "https://grid.meya.ai",
                appId: "YOUR MEYA APP ID",
                integrationId: "integration.orb",
                pageContext: [
                    "platform_version": platformVersion,
                    "a": 1234,
                    "data": [
                        "key1": "value1",
                        "key2": 123123.3,
                        "bool": true
                    ]
                ] as [String: Any?]
            ),
            result: { result in
                print("Connect result: \(String(describing: result))")
            })
        let viewController = orb.viewController()
        present(viewController, animated: true, completion: nil)
    }
}
```

Set your **Meya App ID** in the `OrbConnectionOptions`. Note, the `pageContext` is and
arbitrary dictionary that you can use to send context data to your bot when the Orb connects.


### Flutter specific help
For help getting started with Flutter, view the online
[Flutter documentation](https://flutter.dev/).

For instructions integrating Flutter modules to your existing applications,
see the [add-to-app documentation](https://flutter.dev/docs/development/add-to-app).


## Push Notifications
The Orb Mobile integration & Orb SDK supports sending and handling push notifications 
when the Orb chat is not active. This is especially useful when a bot escalates 
to a human agent and the agent takes a while to respond.

To fully setup push notifications you will need to configure three components:

1. Android Firebase Cloud Messaging (FCM)
2. Apple Push Notification service (APNs)
3. Orb Mobile integration in your Meya app


### Android Setup
1. Setup Firebase Cloud Messaging (FCM) on Android

Follow these instructions to add FCM to your app:
[Set up a Firebase Cloud Messaging client app on Android](https://firebase.google.com/docs/cloud-messaging/android/client)


2. Get your Firebase Service Account Key

- Open your [Firebase Console](https://console.firebase.google.com/)
- Select the project you're using for FCM
- Click gear icon next to **Project Overview**
- Go to **Project settings**
- Click on **Generate new private key**
- This will download a `.json` file to your computer


3. Add the Service Account Key to your app's vault

- Copy the JSON from the `.json` private key file you downloaded from the Firebase
  Console.
- Open your app's vault in the Meya Console
- Add the vault key named `orb.mobile.service_account_key`
- Paste the JSON you copied
- Click the ✓ button
- Click **Save**


4. Add the Orb Mobile integration to your app

Add the following BFML to you app, we recommend you save this file in the 
`integration/orb/mobile/` folder, but you can save this anywhere.

```yaml
id: integration.orb.mobile
type: meya.orb.mobile.integration
android:
  service_account_key: (@ vault.orb.mobile.service_account_key )
  # This is the name of the activity you would like to launch that contains the
  # Orb SDK
  click_action: ChatActivity
```

**Note**, the integration's ID is explicitly set in this example. If you do not explicitly
set the ID then Meya will use the folder path as the integration's ID.


5. Push your Meya app

If you're in the Meya Console then clicking **Save** will save the BFML and push
the changes to the app.

If you're using the Meya CLI then you'll need to do an explicit push
```shell
meya push
```


6. Provide the FCM device token to the Orb SDK

You need to capture and pass the FCM device token to the `Orb` class before you
connect the Orb to the grid. Here is an example of a `ChatActivity` that will
first read the device token before setting up Orb.

```java
package ai.meya.orb_demo;

import ai.meya.orb.Orb;
import ai.meya.orb.OrbActivity;

import android.os.Bundle;
import android.util.Log;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.messaging.FirebaseMessaging;

import ai.meya.orb.OrbConnectionOptions;
import androidx.annotation.NonNull;

import java.util.HashMap;
import java.util.Map;


public class ChatActivity extends OrbActivity {
    private static final String TAG = "ChatActivity";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        FirebaseMessaging.getInstance().getToken().addOnCompleteListener(new OnCompleteListener<String>() {
            @Override
            public void onComplete(@NonNull Task<String> task) {
                if (!task.isSuccessful()) {
                    Log.w(TAG, "Fetching FCM registration token failed", task.getException());
                    return;
                }
                orb.deviceToken = task.getResult();
                orbConnect();
            }
        });
    }

    private void orbConnect() {
        String platformVersion = "Android " + android.os.Build.VERSION.RELEASE;
        
        Map<String, Object> pageContext = new HashMap<>();
        pageContext.put("platform_version", platformVersion);
        pageContext.put("key1", 1235);

        Map<String, Object> data = new HashMap<>();
        data.put("key1", "value1");
        data.put("key2", 12345.9);
        data.put("bool", true);
        pageContext.put("data", data);

        OrbConnectionOptions connectionOptions = new OrbConnectionOptions(
                "https://grid.meya.ai",
                "YOUR MEYA APP ID",
                "integration.orb.mobile",
                pageContext
        );

        if (!orb.ready) {
            orb.setOnReadyListener(new Orb.ReadyListener() {
                public void onReady() {
                    Log.d(TAG, "Orb runtime ready");
                    orb.connect(connectionOptions);
                }
            });
        } else {
            orb.connect(connectionOptions);
        }

        orb.setOnCloseUiListener(new Orb.CloseUiListener() {
            @Override
            public void onCloseUi() {
                Log.d(TAG, "Close Orb");
                finish();
            }
        });
    }
}
```

Make sure that your `ChatActivity` is registered in your app's `AndroidManifest.xml`
file:

```xml
        <activity
            android:name=".ChatActivity"
            android:theme="@style/Theme.OrbDemo"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize"
        >
            <intent-filter>
                <action android:name="ChatActivity" />
                <category android:name="android.intent.category.DEFAULT" />
            </intent-filter>
        </activity>
```

This activity can then be launched from the push notification when the Orb Mobile 
integration's `android.click_action` settings is set to `ChatActivity`


7. Test your push notifications

The best way to test push notifications is to:

- Trigger a flow via a webhook while the app is closed, or
- Escalate to an agent (e.g. Zendesk/Front), close the chat activity and send an
  agent response.


### iOS Setup
1. Add APNs notifications to your app
   
- First [enable the Push Notifications Capability](https://developer.apple.com/documentation/usernotifications/registering_your_app_with_apns#overview) in your app
- You'll need to implement the various `application` hooks to register the app for
  push notifications and receive the APNs device token. Below is an example 
  `AppDelegate` that initializes the Orb and stores the device token:
  
```swift
import UIKit
import orb
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    lazy var orb = Orb()
    var deviceToken: String?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        orb.initialize()
        registerForPushNotifications()
        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        guard let _ = userInfo["aps"] as? [String: AnyObject] else {
            completionHandler(.failed)
            return
        }
        // Launch your Orb view from here
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data)}
        let token = tokenParts.joined()
        self.deviceToken = token
        orb.deviceToken = token
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, _ in
            print("Permission granted: \(granted)")
            guard granted else { return }
            self?.getNotificationSettings()
        }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
}
```

**Note**, currently the Orb does **not** use [method swizzling](https://abhimuralidharan.medium.com/method-swizzling-in-ios-swift-1f38edaf984f)
to autoconfigure these hooks for you (this might be added in a future release), so
if you're using the Firebase SDK for iOS you'll need to disable Firebase's method 
swizzling and implement these methods manually.

2. Create your APNs auth key

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


3. Add the auth APNs credentials to your app's vault

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


4. Add the Orb Mobile integration to your app

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

**Note**, the integration's ID is explicitly set in this example. If you do not explicitly
set the ID then Meya will use the folder path as the integration's ID.


5. Push your Meya app

If you're in the Meya Console then clicking **Save** will save the BFML and push
the changes to the app.

If you're using the Meya CLI then you'll need to do an explicit push
```shell
meya push
```


6. Test your push notifications

The best way to test push notifications is to:

- Trigger a flow via a webhook while the app is closed, or
- Escalate to an agent (e.g. Zendesk/Front), close the chat activity and send an
  agent response.
