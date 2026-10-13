# RGB Remote

A Flutter application for controlling compatible RGB LED strips and bulbs that use infrared (IR). The Android device must have a consumer infrared emitter.

## Android package

Android application ID: `com.marufallammahim.rgbremote`

Dart package name: `rgb_remote`

## Build

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

For a production release, configure a persistent Android release keystore in Codemagic before creating a release build. A debug-signed APK is for testing only.

## Repository

https://github.com/marufallammahim/RGB-Remote
