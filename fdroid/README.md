# F-Droid preparation — RGB Remote

This directory tracks work toward an F-Droid submission. It is **not an F-Droid metadata package**, and the app must not be described as F-Droid-ready until the open items below are verified.

## Project facts checked from the repository

- Upstream: https://github.com/marufallammahim/RGB-Remote
- Application label: RGB Remote
- Android application ID: `com.marufallammahim.rgbremote`
- Flutter package version: `1.0.0+7` (version name `1.0.0`, version code `7`)
- Flutter SDK constraint: `>=3.7.0 <4.0.0`
- Android manifest declares `TRANSMIT_IR` and `VIBRATE`.
- The consumer-IR hardware feature is optional (`required="false"`).
- The main Android manifest does not declare `INTERNET`. This alone does **not** prove the final merged APK has no network permission; merged manifests and all plugin manifests must be checked.
- The current Codemagic release workflow builds a signed AAB and APK. F-Droid must build from source and should not consume that signed binary as its build input.

## Current direct Flutter dependencies

Versions are taken from `pubspec.lock`:

| Package | Locked version | License status |
| --- | ---: | --- |
| flutter_font_icons | 3.0.0 | Verify exact package license and bundled assets |
| material_neumorphic | 1.2.1 | **Unverified — blocker** |
| flutter_dropdown_alert | 1.0.7 | Verify exact package license |
| shared_preferences | 2.5.3 | Verify package and platform implementation notices |
| package_info_plus | 8.3.0 | Verify package and platform implementation notices |
| url_launcher | 6.3.1 | Verify package and platform implementation notices |
| page_transition | 2.2.2 | Verify exact package license |
| just_the_tooltip | 0.0.12 | Verify exact package license |

This is only the direct dependency list. The complete transitive Dart, Flutter, Android/Gradle, Kotlin, and bundled asset license inventory is still required. Do not treat this table as a completed license audit.

## Important licensing issue

The root `LICENSE` currently identifies the project as GPL-3.0-or-later, but its contents are a project-specific policy/summary rather than the complete standard GNU GPLv3 license text. The document itself says it does not replace the full license.

Before changing the root license file:
1. Confirm that you own or have permission to license all original code and assets under GPL-3.0-or-later.
2. Preserve third-party copyright and license notices.
3. Replace the summary-only root `LICENSE` with the unmodified official GPLv3 text, and move project-specific notes to a separate `NOTICE` or `COPYRIGHT.md`.
4. Add the recommended per-file GPL notice where appropriate.

Official license: https://www.gnu.org/licenses/gpl-3.0.html
GNU guidance: https://www.gnu.org/licenses/gpl-howto.en.html

## Required work before submission

- [ ] Confirm copyright ownership and GPL-3.0-or-later intent for all original source and assets.
- [ ] Correct the root license presentation as described above.
- [ ] Generate a complete third-party license inventory, including transitive packages, Android Gradle dependencies, fonts, icons, and sound assets.
- [ ] Inspect all source and merged Android manifests for permissions, trackers, analytics, crash reporting, network access, and embedded non-free components.
- [ ] Verify the final app does not rely on proprietary services or non-free network resources.
- [ ] Pin a supported Flutter SDK/build environment and prepare an F-Droid-compatible source build recipe.
- [ ] Verify the recipe in a clean F-Droid build environment; ensure it does not download prebuilt app binaries or use signing credentials.
- [ ] Run `flutter pub get --enforce-lockfile`, `flutter analyze`, `flutter test`, and a clean release build.
- [ ] Inspect the built APK: package ID, version code, merged permissions, native libraries/ABIs, signing state, and reproducibility.
- [ ] Prepare F-Droid metadata, app description, icon, screenshots, changelog, and source tag.
- [ ] Submit the verified metadata to the official F-Droid metadata repository.

## Notes

- Keeping iOS project files in the upstream repository does not by itself mean the F-Droid Android build includes iOS code. Do not delete platform directories merely for F-Droid.
- Do not add `INTERNET` or remove permissions without checking app functionality and the merged manifest.
- Do not claim that the app is tracker-free, fully offline, reproducible, or F-Droid compliant until the corresponding checks have been completed.
- This preparation note records findings and outstanding checks; it does not certify compliance.
