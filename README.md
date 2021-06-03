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

### Setup Flutter Editor/IDE
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
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        Log.d("Orb", "================================");
        String platformVersion = "Android " + android.os.Build.VERSION.RELEASE;

        Map<String, Object> pageContext = new HashMap<>();
        pageContext.put("platform_version", platformVersion);
        pageContext.put("key1", 1235);

        Map<String, Object> data = new HashMap<>();
        data.put("key1", "value1");
        data.put("key2", 12345.9);
        data.put("bool", true);
        pageContext.put("data", data);

        orb.setOnReadyListener(new Orb.ReadyListener() {
            public void onReady() {
                Log.d("Orb", "Orb runtime ready");
                orb.connect(new OrbConnectionOptions(
                        "https://grid.meya.ai",
                        "YOUR MEYA APP ID,
                        "integration.orb",
                        pageContext
                ));
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