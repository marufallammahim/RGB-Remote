# RGB Remote — সম্পূর্ণ প্রজেক্ট অডিট রিপোর্ট

## সারসংক্ষেপ

- মূল আর্কাইভ: `RGB-LED-Remote-Codemagic.zip`
- অডিট করা বর্তমান ফাইল: **113**
- সংশোধিত ফাইল: **21**
- নতুন ফাইল: **4**
- অপরিবর্তিত ফাইল: **88**
- সরানো ফাইল: **8**
- Android application ID / namespace: `com.marufallammahim.rgbremote`
- Dart package name: `rgb_remote` (সব `package:` imports-এ একই নাম)
- Android label / iOS display name: `RGB Remote`

## যাচাইয়ের ফলাফল

| পরীক্ষা | ফলাফল |
|---|---|
| মূল ZIP আর্কাইভ পরীক্ষা | সফল |
| `pubspec.yaml`, `pubspec.lock`, `codemagic.yaml`, GitHub Actions YAML parse | সফল |
| Dart local/relative import এবং dependency-name cross-check | কোনো অনুপস্থিত import পাওয়া যায়নি |
| পুরোনো Android/iOS package ID search | পুরোনো `io.github.chayanforyou` রেফারেন্স নেই |
| Ads SDK / consent / ad unit / ad widget রেফারেন্স search | কোনো ad SDK বা ad-code reference নেই |
| `activeColor` / পুরোনো `DialogTheme(` search | কোনো match নেই |
| Gradle launcher shell syntax (`sh -n`) | সফল |
| Flutter analyzer / widget tests / APK build | **এই পরিবেশে চালানো যায়নি** — Flutter/Dart SDK ইনস্টল নেই এবং build-time network access নেই |

## প্রধান পরিবর্তন

1. Android `namespace` এবং `applicationId`, Kotlin package declaration ও directory path একত্রে `com.marufallammahim.rgbremote` করা হয়েছে।
2. iOS Runner ও RunnerTests bundle identifiers একই অ্যাপ আইডির সঙ্গে সামঞ্জস্য করা হয়েছে।
3. Dart package `rgbremote` থেকে `rgb_remote` করা হয়েছে এবং সব Dart import আপডেট করা হয়েছে।
4. Gradle wrapper distribution `8.14.3`, Android Gradle Plugin `8.11.1`, Kotlin Gradle plugin `2.2.20`, Java/Kotlin target `17` করা হয়েছে।
5. Gradle wrapper shell/Windows launcher যোগ করা হয়েছে, কারণ আপলোড করা মূল প্রজেক্টে `gradlew`/`gradlew.bat` অনুপস্থিত ছিল এবং `.gitignore` সেগুলো বাদ দিচ্ছিল। Launcher প্রয়োজন হলে `gradle-wrapper.properties`-এ পিন করা distribution ডাউনলোড করে চালায়।
6. Google Mobile Ads ও AppLovin dependency, initialization, consent flow, banner/interstitial code, ad IDs, manifest metadata এবং ad-নির্দিষ্ট Dart ফাইল সরানো হয়েছে।
7. `DialogThemeData`, Material 3 theme এবং `activeThumbColor` ব্যবহার করা হয়েছে; `primaryColor`-এর পুরোনো theme override বাদ দেওয়া হয়েছে।
8. IR MethodChannel-এর null/empty pattern response handling উন্নত করা হয়েছে এবং engine detach-এ SoundPool release যোগ করা হয়েছে।
9. GitHub Actions workflow যোগ করা হয়েছে: Java 17, Flutter stable, `pub get`, `flutter analyze`, `flutter test`, release APK build এবং artifact upload। Codemagic-এ analyzer/test ব্যর্থতা আর উপেক্ষা করা হয় না।
10. আগের placeholder counter test-কে theme smoke test দিয়ে প্রতিস্থাপন করা হয়েছে। README এবং app attribution/links আপডেট করা হয়েছে।

## পরিবর্তিত ফাইল

- `README.md`
- `android/.gitignore`
- `android/app/build.gradle`
- `android/app/src/main/AndroidManifest.xml`
- `android/gradle/wrapper/gradle-wrapper.properties`
- `android/settings.gradle`
- `codemagic.yaml`
- `ios/Runner.xcodeproj/project.pbxproj`
- `ios/Runner/Info.plist`
- `lib/application/navigation/app_router.dart`
- `lib/application/services/back_press_handler.dart`
- `lib/core/config/app_theme.dart`
- `lib/main.dart`
- `lib/plugins/ir_sensor_plugin.dart`
- `lib/presentation/screens/components/about_app.dart`
- `lib/presentation/screens/components/tooltip_widget.dart`
- `lib/presentation/screens/remote_screen.dart`
- `lib/presentation/screens/settings_screen.dart`
- `pubspec.lock`
- `pubspec.yaml`
- `test/widget_test.dart`

## নতুন ফাইল

- `.github/workflows/flutter-android.yml`
- `android/app/src/main/kotlin/com/marufallammahim/rgbremote/MainActivity.kt`
- `android/gradlew`
- `android/gradlew.bat`

## সরানো ফাইল

- `android/app/src/main/kotlin/io/github/chayanforyou/rgbremote/MainActivity.kt`
- `lib/ads/applovin_ad_manager.dart`
- `lib/ads/applovin_ads.dart`
- `lib/ads/google_ad_manager.dart`
- `lib/ads/widgets/banner_ad_widget.dart`
- `lib/application/services/ad_service_manager.dart`
- `lib/core/constants/ad_unit_ids.dart`
- `lib/core/utils/consent_manager.dart`

## প্রতিটি বর্তমান ফাইলের তালিকা

| ফাইল | রিপোর্ট |
|---|---|
| `.github/workflows/flutter-android.yml` | নতুন |
| `.gitignore` | অপরিবর্তিত; রেফারেন্স/কনফিগারেশন স্ক্যানে অন্তর্ভুক্ত |
| `.metadata` | অপরিবর্তিত; রেফারেন্স/কনফিগারেশন স্ক্যানে অন্তর্ভুক্ত |
| `README.md` | সংশোধিত |
| `analysis_options.yaml` | অপরিবর্তিত; রেফারেন্স/কনফিগারেশন স্ক্যানে অন্তর্ভুক্ত |
| `android/.gitignore` | সংশোধিত |
| `android/app/build.gradle` | সংশোধিত |
| `android/app/proguard-rules.pro` | অপরিবর্তিত; রেফারেন্স/কনফিগারেশন স্ক্যানে অন্তর্ভুক্ত |
| `android/app/src/debug/AndroidManifest.xml` | অপরিবর্তিত; রেফারেন্স/কনফিগারেশন স্ক্যানে অন্তর্ভুক্ত |
| `android/app/src/main/AndroidManifest.xml` | সংশোধিত |
| `android/app/src/main/ic_launcher-playstore.png` | অপরিবর্তিত রিসোর্স; ফাইল-ইনটেগ্রিটি পরীক্ষা |
| `android/app/src/main/kotlin/com/marufallammahim/rgbremote/MainActivity.kt` | নতুন |
| `android/app/src/main/res/drawable/ic_launcher_foreground.webp` | অপরিবর্তিত রিসোর্স; ফাইল-ইনটেগ্রিটি পরীক্ষা |
| `android/app/src/main/res/drawable/launch_background.xml` | অপরিবর্তিত; রেফারেন্স/কনফিগারেশন স্ক্যানে অন্তর্ভুক্ত |
| `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml` | অপরিবর্তিত; রেফারেন্স/কনফিগারেশন স্ক্যানে অন্তর্ভুক্ত |
| `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher_round.xml` | অপরিবর্তিত; রেফারেন্স/কনফিগারেশন স্ক্যানে অন্তর্ভুক্ত |
| `android/app/src/main/res/mipmap-hdpi/ic_launcher.webp` | অপরিবর্তিত রিসোর্স; ফাইল-ইনটেগ্রিটি পরীক্ষা |
| `android/app/src/main/res/mipmap-hdpi/ic_launcher_round.webp` | অপরিবর্তিত রিসোর্স; ফাইল-ইনটেগ্রিটি পরীক্ষা |
| `android/app/src/main/res/mipmap-mdpi/ic_launcher.webp` | অপরিবর্তিত রিসোর্স; ফাইল-ইনটেগ্রিটি পরীক্ষা |
| `android/app/src/main/res/mipmap-mdpi/ic_launcher_round.webp` | অপরিবর্তিত রিসোর্স; ফাইল-ইনটেগ্রিটি পরীক্ষা |
| `android/app/src/main/res/mipmap-xhdpi/ic_launcher.webp` | অপরিবর্তিত রিসোর্স; ফাইল-ইনটেগ্রিটি পরীক্ষা |
| `android/app/src/main/res/mipmap-xhdpi/ic_launcher_round.webp` | অপরিবর্তিত রিসোর্স; ফাইল-ইনটেগ্রিটি পরীক্ষা |
| `android/app/src/main/res/mipmap-xxhdpi/ic_launcher.webp` | অপরিবর্তিত রিসোর্স; ফাইল-ইনটেগ্রিটি পরীক্ষা |
| `android/app/src/main/res/mipmap-xxhdpi/ic_launcher_round.webp` | অপরিবর্তিত রিসোর্স; ফাইল-ইনটেগ্রিটি পরীক্ষা |
| `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.webp` | অপরিবর্তিত রিসোর্স; ফাইল-ইনটেগ্রিটি পরীক্ষা |
| `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher_round.webp` | অপরিবর্তিত রিসোর্স; ফাইল-ইনটেগ্রিটি পরীক্ষা |
| `android/app/src/main/res/raw/sound_1.mp3` | অপরিবর্তিত রিসোর্স; ফাইল-ইনটেগ্রিটি পরীক্ষা |
| `android/app/src/main/res/raw/sound_2.mp3` | অপরিবর্তিত রিসোর্স; ফাইল-ইনটেগ্রিটি পরীক্ষা |
| `android/app/src/main/res/raw/sound_3.mp3` | অপরিবর্তিত রিসোর্স; ফাইল-ইনটেগ্রিটি পরীক্ষা |
| `android/app/src/main/res/values-night/styles.xml` | অপরিবর্তিত; রেফারেন্স/কনফিগারেশন স্ক্যানে অন্তর্ভুক্ত |
| `android/app/src/main/res/values/colors.xml` | অপরিবর্তিত; রেফারেন্স/কনফিগারেশন স্ক্যানে অন্তর্ভুক্ত |
| `android/app/src/main/res/values/styles.xml` | অপরিবর্তিত; রেফারেন্স/কনফিগারেশন স্ক্যানে অন্তর্ভুক্ত |
| `android/app/src/profile/AndroidManifest.xml` | অপরিবর্তিত; রেফারেন্স/কনফিগারেশন স্ক্যানে অন্তর্ভুক্ত |
| `android/build.gradle` | অপরিবর্তিত; রেফারেন্স/কনফিগারেশন স্ক্যানে অন্তর্ভুক্ত |
| `android/gradle.properties` | অপরিবর্তিত; রেফারেন্স/কনফিগারেশন স্ক্যানে অন্তর্ভুক্ত |
| `android/gradle/wrapper/gradle-wrapper.properties` | সংশোধিত |
| `android/gradlew` | নতুন |
| `android/gradlew.bat` | নতুন |
| `android/settings.gradle` | সংশোধিত |
| `codemagic.yaml` | সংশোধিত |
| `ios/.gitignore` | অপরিবর্তিত; রেফারেন্স/কনফিগারেশন স্ক্যানে অন্তর্ভুক্ত |
| `ios/Flutter/AppFrameworkInfo.plist` | অপরিবর্তিত; রেফারেন্স/কনফিগারেশন স্ক্যানে অন্তর্ভুক্ত |
| `ios/Flutter/Debug.xcconfig` | অপরিবর্তিত; রেফারেন্স/কনফিগারেশন স্ক্যানে অন্তর্ভুক্ত |
| `ios/Flutter/Release.xcconfig` | অপরিবর্তিত; রেফারেন্স/কনফিগারেশন স্ক্যানে অন্তর্ভুক্ত |
| `ios/Podfile` | অপরিবর্তিত; রেফারেন্স/কনফিগারেশন স্ক্যানে অন্তর্ভুক্ত |
| `ios/Runner.xcodeproj/project.pbxproj` | সংশোধিত |
| `ios/Runner.xcodeproj/project.xcworkspace/contents.xcworkspacedata` | অপরিবর্তিত; রেফারেন্স/কনফিগারেশন স্ক্যানে অন্তর্ভুক্ত |
| `ios/Runner.xcodeproj/project.xcworkspace/xcshareddata/IDEWorkspaceChecks.plist` | অপরিবর্তিত; রেফারেন্স/কনফিগারেশন স্ক্যানে অন্তর্ভুক্ত |
| `ios/Runner.xcodeproj/project.xcworkspace/xcshareddata/WorkspaceSettings.xcsettings` | অপরিবর্তিত; রেফারেন্স/কনফিগারেশন স্ক্যানে অন্তর্ভুক্ত |
| `ios/Runner.xcodeproj/xcshareddata/xcschemes/Runner.xcscheme` | অপরিবর্তিত; রেফারেন্স/কনফিগারেশন স্ক্যানে অন্তর্ভুক্ত |
| `ios/Runner.xcworkspace/contents.xcworkspacedata` | অপরিবর্তিত; রেফারেন্স/কনফিগারেশন স্ক্যানে অন্তর্ভুক্ত |
| `ios/Runner.xcworkspace/xcshareddata/IDEWorkspaceChecks.plist` | অপরিবর্তিত; রেফারেন্স/কনফিগারেশন স্ক্যানে অন্তর্ভুক্ত |
| `ios/Runner.xcworkspace/xcshareddata/WorkspaceSettings.xcsettings` | অপরিবর্তিত; রেফারেন্স/কনফিগারেশন স্ক্যানে অন্তর্ভুক্ত |
| `ios/Runner/AppDelegate.swift` | অপরিবর্তিত; রেফারেন্স/কনফিগারেশন স্ক্যানে অন্তর্ভুক্ত |
| `ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json` | অপরিবর্তিত; রেফারেন্স/কনফিগারেশন স্ক্যানে অন্তর্ভুক্ত |
| `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png` | অপরিবর্তিত রিসোর্স; ফাইল-ইনটেগ্রিটি পরীক্ষা |
| `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@1x.png` | অপরিবর্তিত রিসোর্স; ফাইল-ইনটেগ্রিটি পরীক্ষা |
| `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@2x.png` | অপরিবর্তিত রিসোর্স; ফাইল-ইনটেগ্রিটি পরীক্ষা |
| `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@3x.png` | অপরিবর্তিত রিসোর্স; ফাইল-ইনটেগ্রিটি পরীক্ষা |
| `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@1x.png` | অপরিবর্তিত রিসোর্স; ফাইল-ইনটেগ্রিটি পরীক্ষা |
| `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@2x.png` | অপরিবর্তিত রিসোর্স; ফাইল-ইনটেগ্রিটি পরীক্ষা |
| `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@3x.png` | অপরিবর্তিত রিসোর্স; ফাইল-ইনটেগ্রিটি পরীক্ষা |
| `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@1x.png` | অপরিবর্তিত রিসোর্স; ফাইল-ইনটেগ্রিটি পরীক্ষা |
| `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@2x.png` | অপরিবর্তিত রিসোর্স; ফাইল-ইনটেগ্রিটি পরীক্ষা |
| `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@3x.png` | অপরিবর্তিত রিসোর্স; ফাইল-ইনটেগ্রিটি পরীক্ষা |
| `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@2x.png` | অপরিবর্তিত রিসোর্স; ফাইল-ইনটেগ্রিটি পরীক্ষা |
| `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@3x.png` | অপরিবর্তিত রিসোর্স; ফাইল-ইনটেগ্রিটি পরীক্ষা |
| `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@1x.png` | অপরিবর্তিত রিসোর্স; ফাইল-ইনটেগ্রিটি পরীক্ষা |
| `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@2x.png` | অপরিবর্তিত রিসোর্স; ফাইল-ইনটেগ্রিটি পরীক্ষা |
| `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-83.5x83.5@2x.png` | অপরিবর্তিত রিসোর্স; ফাইল-ইনটেগ্রিটি পরীক্ষা |
| `ios/Runner/Assets.xcassets/LaunchImage.imageset/Contents.json` | অপরিবর্তিত; রেফারেন্স/কনফিগারেশন স্ক্যানে অন্তর্ভুক্ত |
| `ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage.png` | অপরিবর্তিত রিসোর্স; ফাইল-ইনটেগ্রিটি পরীক্ষা |
| `ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage@2x.png` | অপরিবর্তিত রিসোর্স; ফাইল-ইনটেগ্রিটি পরীক্ষা |
| `ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage@3x.png` | অপরিবর্তিত রিসোর্স; ফাইল-ইনটেগ্রিটি পরীক্ষা |
| `ios/Runner/Assets.xcassets/LaunchImage.imageset/README.md` | অপরিবর্তিত; রেফারেন্স/কনফিগারেশন স্ক্যানে অন্তর্ভুক্ত |
| `ios/Runner/Base.lproj/LaunchScreen.storyboard` | অপরিবর্তিত; রেফারেন্স/কনফিগারেশন স্ক্যানে অন্তর্ভুক্ত |
| `ios/Runner/Base.lproj/Main.storyboard` | অপরিবর্তিত; রেফারেন্স/কনফিগারেশন স্ক্যানে অন্তর্ভুক্ত |
| `ios/Runner/Info.plist` | সংশোধিত |
| `ios/Runner/Runner-Bridging-Header.h` | অপরিবর্তিত; রেফারেন্স/কনফিগারেশন স্ক্যানে অন্তর্ভুক্ত |
| `ios/RunnerTests/RunnerTests.swift` | অপরিবর্তিত; রেফারেন্স/কনফিগারেশন স্ক্যানে অন্তর্ভুক্ত |
| `lib/application/navigation/app_router.dart` | সংশোধিত |
| `lib/application/services/back_press_handler.dart` | সংশোধিত |
| `lib/application/services/remote_assist_service.dart` | অপরিবর্তিত; রেফারেন্স/কনফিগারেশন স্ক্যানে অন্তর্ভুক্ত |
| `lib/application/services/settings_service.dart` | অপরিবর্তিত; রেফারেন্স/কনফিগারেশন স্ক্যানে অন্তর্ভুক্ত |
| `lib/core/config/app_color.dart` | অপরিবর্তিত; রেফারেন্স/কনফিগারেশন স্ক্যানে অন্তর্ভুক্ত |
| `lib/core/config/app_text.dart` | অপরিবর্তিত; রেফারেন্স/কনফিগারেশন স্ক্যানে অন্তর্ভুক্ত |
| `lib/core/config/app_theme.dart` | সংশোধিত |
| `lib/core/constants/app_strings.dart` | অপরিবর্তিত; রেফারেন্স/কনফিগারেশন স্ক্যানে অন্তর্ভুক্ত |
| `lib/core/constants/preferences_keys.dart` | অপরিবর্তিত; রেফারেন্স/কনফিগারেশন স্ক্যানে অন্তর্ভুক্ত |
| `lib/core/extensions/string_extensions.dart` | অপরিবর্তিত; রেফারেন্স/কনফিগারেশন স্ক্যানে অন্তর্ভুক্ত |
| `lib/core/utils/hex_color.dart` | অপরিবর্তিত; রেফারেন্স/কনফিগারেশন স্ক্যানে অন্তর্ভুক্ত |
| `lib/data/datasources/settings_data_source.dart` | অপরিবর্তিত; রেফারেন্স/কনফিগারেশন স্ক্যানে অন্তর্ভুক্ত |
| `lib/data/models/pronto_command.dart` | অপরিবর্তিত; রেফারেন্স/কনফিগারেশন স্ক্যানে অন্তর্ভুক্ত |
| `lib/data/models/remote_config.dart` | অপরিবর্তিত; রেফারেন্স/কনফিগারেশন স্ক্যানে অন্তর্ভুক্ত |
| `lib/data/repositories/settings_repository_impl.dart` | অপরিবর্তিত; রেফারেন্স/কনফিগারেশন স্ক্যানে অন্তর্ভুক্ত |
| `lib/domain/entities/app_settings.dart` | অপরিবর্তিত; রেফারেন্স/কনফিগারেশন স্ক্যানে অন্তর্ভুক্ত |
| `lib/domain/repositories/settings_repository.dart` | অপরিবর্তিত; রেফারেন্স/কনফিগারেশন স্ক্যানে অন্তর্ভুক্ত |
| `lib/main.dart` | সংশোধিত |
| `lib/plugins/ir_sensor_plugin.dart` | সংশোধিত |
| `lib/presentation/screens/components/about_app.dart` | সংশোধিত |
| `lib/presentation/screens/components/remote_ui.dart` | অপরিবর্তিত; রেফারেন্স/কনফিগারেশন স্ক্যানে অন্তর্ভুক্ত |
| `lib/presentation/screens/components/tooltip_widget.dart` | সংশোধিত |
| `lib/presentation/screens/remote_screen.dart` | সংশোধিত |
| `lib/presentation/screens/settings_screen.dart` | সংশোধিত |
| `lib/presentation/widgets/hyper_link.dart` | অপরিবর্তিত; রেফারেন্স/কনফিগারেশন স্ক্যানে অন্তর্ভুক্ত |
| `lib/presentation/widgets/ir_light_effect.dart` | অপরিবর্তিত; রেফারেন্স/কনফিগারেশন স্ক্যানে অন্তর্ভুক্ত |
| `lib/presentation/widgets/remote_button.dart` | অপরিবর্তিত; রেফারেন্স/কনফিগারেশন স্ক্যানে অন্তর্ভুক্ত |
| `lib/resources/pronto_data.dart` | অপরিবর্তিত; রেফারেন্স/কনফিগারেশন স্ক্যানে অন্তর্ভুক্ত |
| `lib/resources/pronto_data_type1.dart` | অপরিবর্তিত; রেফারেন্স/কনফিগারেশন স্ক্যানে অন্তর্ভুক্ত |
| `lib/resources/pronto_data_type2.dart` | অপরিবর্তিত; রেফারেন্স/কনফিগারেশন স্ক্যানে অন্তর্ভুক্ত |
| `pubspec.lock` | সংশোধিত |
| `pubspec.yaml` | সংশোধিত |
| `test/widget_test.dart` | সংশোধিত |

## গুরুত্বপূর্ণ সীমাবদ্ধতা

এই রিপোর্টটি archive integrity, YAML parse, import/dependency cross-reference এবং targeted source/configuration scans-এর ওপর ভিত্তি করে। Flutter/Dart SDK এই পরিবেশে নেই, তাই analyzer, tests, Android Gradle configuration evaluation বা APK build-এর সফলতা নিশ্চিত করা হয়নি। প্রথম GitHub Actions run-কে বাস্তব compile/test validation হিসেবে ধরতে হবে। যদি analyzer/build কোনো নতুন error দেয়, সেই লগ অনুযায়ী পরবর্তী সংশোধন প্রয়োজন হতে পারে।

**Dependency version নোট:** বিজ্ঞাপন SDK ও অপ্রয়োজনীয় `cupertino_icons` dependency সরানো হয়েছে এবং lockfile থেকে অপ্রয়োজনীয় প্যাকেজ prune করা হয়েছে। অন্য সরাসরি dependency-গুলোর version-এ অন্ধভাবে major upgrade করা হয়নি, কারণ এই পরিবেশে `flutter pub outdated`/`flutter pub get` চালানো সম্ভব হয়নি; সেগুলোকে “সর্বশেষ সংস্করণে আপডেট হয়েছে” বলে দাবি করা হচ্ছে না। GitHub Actions-এ dependency resolution ও compile ফলাফল দেখে পরবর্তী version upgrade নিরাপদে নির্ধারণ করতে হবে।
