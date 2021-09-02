# Orb Mobile SDK
Welcome to the Orb Mobile SDK! 

First a bit of context about the Orb Mobile SDK. The Orb Mobile SDK is 
implemented using the cross platform Flutter framework and the Dart language.
Flutter allows you to build high fidelity, fast apps targeting multiple 
platforms including Android, iOS, Web, Linux, Windows and macOS. Currently 
the Orb Mobile SDK only supports the Android and iOS platforms.

This repo contains two folders, namely:
- `orb`: This is a **Flutter plugin** package and contains all the Dart code 
  and platform specific integration code for the core Orb SDK.
- `module`: This is a **Flutter module** that allows you to integrate the 
  Orb SDK into your native app. The `module` Flutter module depends on the 
  `orb` Flutter package.


## Getting started
The following guides will help you integrate the Orb SDK into 
your existing Android or iOS application and allow you to connect to your 
Meya app.

- [Install Orb Mobile SDK](https://docs.meya.ai/docs/install-mobile-sdk)
  - [Android](https://docs.meya.ai/docs/install-mobile-sdk#add-to-an-android-app)
  - [iOS](https://docs.meya.ai/docs/install-mobile-sdk#add-to-an-ios-app)
- [Push notifications](https://docs.meya.ai/docs/push-notifications)
  - [Android](https://docs.meya.ai/docs/push-notifications#android-setup)
  - [iOS](https://docs.meya.ai/docs/push-notifications#ios-setup)
- [Config](https://docs.meya.ai/docs/orb-mobile-config)