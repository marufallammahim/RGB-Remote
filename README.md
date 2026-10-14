<div align="center">

# RGB-LED-REMOTE 📱

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Language-Dart-0175C2?logo=dart&logoColor=white)](https://dart.dev/)
[![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android&logoColor=white)](https://www.android.com/)
[![IR](https://img.shields.io/badge/Control-Infrared%20(IR)-6A5ACD)](#কাজের-ধারা)
[![License](https://img.shields.io/badge/License-See%20Repository-lightgrey)](LICENSE)

[English](#english) · [বাংলা](#বাংলা) · [Features](#ফিচারসমূহ) · [Build](#build-ও-রান)

### Flutter-ভিত্তিক Android IR Remote App

**A Flutter application for controlling compatible RGB LED strips and bulbs that use infrared (IR). The Android device must have a consumer infrared emitter.**

## Android package

Android application ID: `com.marufallammahim.rgbremote`

Dart package name: `rgb_remote` 

**RGB LED controller-এর জন্য একটি সহজ, আধুনিক ও responsive ইনফ্রারেড রিমোট অ্যাপ।**


</div>

---


## 📌 প্রজেক্ট পরিচিতি

**RGB-LED-REMOTE** হলো Flutter ও Dart দিয়ে তৈরি একটি Android অ্যাপ, যার উদ্দেশ্য ফোনের **built-in IR (Infrared) emitter** ব্যবহার করে সামঞ্জস্যপূর্ণ RGB LED strip/controller পরিচালনা করা। অ্যাপের রিমোট UI থেকে কমান্ড বেছে নেওয়া হয়; Android native Kotlin layer সেই কমান্ড IR transmitter API-তে পাঠায়।

- **App name:** `RGB Remote`
- **Android application ID:** `com.marufallammahim.rgbremote`
- **প্রযুক্তি:** Flutter, Dart, Android/Kotlin, MethodChannel
- **লক্ষ্য প্ল্যাটফর্ম:** Android
- **ইন্টারনেট:** IR কমান্ড পাঠানোর জন্য ইন্টারনেট লাগে না

> **হার্ডওয়্যার নোট:** IR নিয়ন্ত্রণ কাজ করার জন্য ফোনে IR emitter থাকতে হবে এবং LED controller-কে অ্যাপের পাঠানো IR প্রোটোকল/কমান্ড সমর্থন করতে হবে। শুধু অ্যাপ ইনস্টল করলেই সব ফোন বা সব LED controller-এ কাজ করার নিশ্চয়তা নেই।

## ✨ ফিচারসমূহ

বর্তমান সোর্স ও প্রকল্প-পরিবর্তনের নথিতে থাকা কার্যকারিতাগুলো:

- 🎛️ **Remote control UI** — LED controller-এর জন্য বোতামভিত্তিক রিমোট ইন্টারফেস।
- 🎨 **Preset controls** — অন্তর্ভুক্ত `ONE` ও `TWO` preset থেকে কমান্ড নির্বাচন।
- 💡 **Brightness control** — সমর্থিত IR কমান্ড দিয়ে উজ্জ্বলতা নিয়ন্ত্রণ; হার্ডওয়্যার/প্রিসেট অনুযায়ী আচরণ নির্ভরশীল।
- 🌑 **Appearance settings** — `Dark` ও `AMOLED black` থিম বেছে নেওয়া এবং পছন্দ সংরক্ষণ।
- 📟 **Transmission status** — `SENDING`, `SENT` ও `SEND FAILED` অবস্থা দেখানো। `SENT` মানে Android-এর IR transmit call সম্পন্ন হয়েছে; LED controller থেকে নিশ্চিত প্রতিক্রিয়া পাওয়া নয়।
- 🔊 **ঐচ্ছিক sound feedback** — সাউন্ড লোড না হলে বা অনুপলব্ধ থাকলে সেটি IR কমান্ড পাঠানো আটকে দেওয়ার কথা নয়।
- 📳 **Vibration setting** — vibration চালু/বন্ধ; প্রথমবার ইনস্টলে ডিফল্ট OFF।
- 💾 **Settings persistence** — সমর্থিত সেটিংস SharedPreferences-এ সংরক্ষণের ব্যবস্থা।
- 🛡️ **IR input validation** — Pronto data, frequency ও timing values যাচাই; queue ব্যস্ত থাকলে `BUSY` error ফেরত দেওয়ার ব্যবস্থা।
- ⚙️ **Native Android bridge** — Flutter `MethodChannel` থেকে Kotlin/Android IR API-তে কমান্ড পাঠানো।
- 📱 **Responsive layout** — রিমোট কার্ডের অবস্থান ও অভ্যন্তরীণ spacing সমন্বয়ের কাজ অন্তর্ভুক্ত।

> **সততা ও সীমাবদ্ধতা:** এগুলো সোর্স/ইমপ্লিমেন্টেশন রিপোর্টে নথিভুক্ত ফিচার। Flutter analyze, automated tests, release APK build, APK signature verification এবং বাস্তব IR hardware test সফল হয়েছে—এমন দাবি এই README করছে না।

## 🔄 কাজের ধারা

![RGB-LED-REMOTE IR command workflow](docs/ir-workflow.svg)

1. ব্যবহারকারী রিমোট UI-তে একটি বোতাম বা preset নির্বাচন করেন।
2. Flutter layer সংশ্লিষ্ট কমান্ড ও প্রয়োজনীয় parameters প্রস্তুত করে।
3. `MethodChannel`-এর মাধ্যমে Android native Kotlin layer-এ request পাঠানো হয়।
4. Native layer input যাচাই করে IR transmission queue-তে কমান্ড পাঠায়।
5. ফোনের IR emitter সমর্থিত LED controller-এ সংকেত পাঠায়।
6. অ্যাপ transmission call-এর ফল অনুযায়ী `SENDING`, `SENT` অথবা `SEND FAILED` status দেখায়।

**গুরুত্বপূর্ণ:** অ্যাপের `SENT` status controller বাস্তবে রঙ/মোড পরিবর্তন করেছে—এমন hardware acknowledgement নয়।

## 🧱 প্রযুক্তি ও প্রজেক্ট কাঠামো

| অংশ | ভূমিকা |
|---|---|
| Flutter / Dart | UI, screen, remote controls ও app logic |
| Android / Kotlin | Native IR transmission, sound loading এবং Android platform integration |
| MethodChannel | Flutter ও native Android code-এর মধ্যে যোগাযোগ |
| SharedPreferences | নির্বাচিত app settings সংরক্ষণ |
| GitHub Actions | CI checks ও Android release APK তৈরির workflow |

প্রধান source directory-গুলো:

```text
lib/
  application/      # Application services
  core/              # Shared config/constants
  data/              # Persistence/data sources
  domain/            # Domain models
  plugins/           # Platform bridge / IR plugin
  presentation/      # Screens, widgets and UI
android/
  app/src/main/kotlin/  # Native Android implementation
.github/workflows/      # GitHub Actions workflows
 test/                  # Automated tests
```

> ফোল্ডারের সঠিক নাম/বিন্যাস branch বা সংস্করণভেদে বদলাতে পারে। উপরেরটি প্রকল্পের পরিচিত architecture-এর সারাংশ।

## 🧑‍💻 Contributors

GitHub repository-র commit history থেকে contributors-এর বর্তমান তালিকা দেখুন:

- **[Contributors graph](https://github.com/marufallammahim/RGB-Remote/graphs/contributors)** — GitHub commit activity অনুযায়ী স্বয়ংক্রিয়ভাবে তৈরি।
- **[Commit history](https://github.com/marufallammahim/RGB-Remote/commits/main/)** 
- ![Repository contributors](https://contrib.rocks/image?repo=marufallammahim/RGB-Remote)

নতুন contributor-এর commit repository-তে যুক্ত হলে GitHub-এর contributor view সাধারণত নিজে থেকেই আপডেট হয়। এটি commit author metadata-এর ওপর নির্ভর করে; সব ধরনের অবদান (যেমন issue, design বা testing) commit graph-এ নাও দেখা যেতে পারে।

## 🛠️ Build ও রান

### প্রয়োজনীয় সফটওয়্যার

- Flutter SDK (প্রকল্পের বর্তমান `pubspec.yaml`-এর সঙ্গে সামঞ্জস্যপূর্ণ stable version)
- Android SDK ও Android Build Tools
- Java/JDK 17
- IR emitter-যুক্ত Android ফোন — বাস্তবে IR পরীক্ষা করার জন্য!

### লোকাল build

```bash
git clone https://github.com/marufallammahim/RGB-Remote.git
cd RGB-Remote
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

Release APK :

```text
build/app/outputs/flutter-apk/app-release.apk
```

### GitHub Actions release

এই repository-তে `main` branch-এ push অথবা workflow manual trigger করার জন্য Android CI/release workflow কনফিগার করা যেতে পারে। বর্তমান workflow ফাইল ও repository settings যাচাই করে নিশ্চিত করুন যে workflow:

1. Java 17 ও Flutter সেটআপ করে;
2. dependencies resolve করে;
3. `flutter analyze` ও `flutter test` চালিয়ে;
4. release APK তৈরি করে;
5. `RGB-LED-REMOTE.apk` নামে সরাসরি GitHub Release-এ APK আপলোড করে — ZIP artifact হিসেবে নয়।

Release তৈরির আগে `.github/workflows/`-এর workflow, GitHub token permissions এবং Release/tag policy পরীক্ষা করুন। README-তে workflow সফল বলে দাবি করা হচ্ছে না।

## 🧪 যাচাইয়ের অবস্থা

প্রকল্পের implementation report অনুযায়ী কিছু static checks সম্পন্ন হয়েছে: `AndroidManifest.xml` XML parsing, `pubspec.yaml`/`codemagic.yaml` YAML parsing, Dart import cross-check এবং preset-গুলোর bundled Pronto command-এর header/count validation।

নিচেরগুলো আলাদাভাবে চালিয়ে নিশ্চিত করা প্রয়োজন:

- [ ] `flutter analyze`
- [ ] `flutter test`
- [ ] `flutter build apk --release`
- [ ] APK signature verification
- [ ] IR emitter-যুক্ত বাস্তব Android ফোনে Power/brightness/preset পরীক্ষা
- [ ] Settings persistence ও ছোট স্ক্রিনে UI regression পরীক্ষা

## 🤝 অবদান রাখুন

Bug report, feature suggestion বা pull request স্বাগত। পরিবর্তন জমা দেওয়ার আগে সম্ভব হলে `flutter analyze` এবং `flutter test` চালান। IR hardware-নির্ভর পরিবর্তনের ক্ষেত্রে ফোনের মডেল, LED controller এবং পরীক্ষার ফল উল্লেখ করুন।

## 📄 License

Repository-তে থাকা `LICENSE` ফাইল দেখুন। License ফাইল না থাকলে ব্যবহার বা পুনর্বিতরণের আগে repository owner-এর কাছ থেকে লাইসেন্সের শর্ত নিশ্চিত করুন।

---

<a id="english"></a>
## English

**RGB-LED-REMOTE** is a Flutter/Dart Android application intended to control compatible RGB LED strip controllers through a phone's built-in infrared (IR) emitter. Flutter handles the remote UI and app logic; a Kotlin Android layer receives requests over a `MethodChannel` and submits validated IR commands for transmission.

### Highlights

- Button-based remote UI and bundled `ONE` / `TWO` presets.
- Brightness commands where supported by the selected preset/controller.
- Persisted `Dark` and `AMOLED black` appearance settings.
- `SENDING`, `SENT`, and `SEND FAILED` transmission states.
- Optional sound feedback and vibration preference (vibration defaults to OFF on first install).
- SharedPreferences-backed settings and validation for Pronto/frequency/timing inputs.
- Bounded IR transmission queue with a `BUSY` error path.
- GitHub contributor graph and commit history for automatically updated contributor information.

**Hardware requirement:** the phone must have an IR emitter, and the target controller must support the transmitted commands. `SENT` confirms completion of Android's transmit call, not a response from the LED controller.

### Build

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

The release APK is normally written to `build/app/outputs/flutter-apk/app-release.apk`. See the Bengali documentation above for the workflow and verification checklist. Build, automated tests, signing, and physical-device IR behavior should be verified in the target environment before publishing.

### Contributors

See the [GitHub contributors graph](https://github.com/marufallammahim/RGB-Remote/graphs/contributors) and [commit history](https://github.com/marufallammahim/RGB-Remote/commits/main/) for the current automatically derived list.
