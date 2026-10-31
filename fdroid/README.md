# F-Droid preparation — RGB Remote

This branch contains an initial F-Droid build setup and audit notes. It is **not yet ready for submission**: the recipe has not been run in an F-Droid build server, and license/asset checks remain incomplete.

## Repository facts

- Upstream: https://github.com/marufallammahim/RGB-Remote
- Android application ID: `com.marufallammahim.rgbremote`
- App label: `RGB Remote`
- Version in `pubspec.yaml`: `1.0.0+7` (version name `1.0.0`, version code `7`)
- Dart constraint: `>=3.7.0 <4.0.0`
- Android Gradle Plugin: `8.11.1`
- Kotlin Gradle plugin: `2.2.20`
- Gradle wrapper: `8.14.3`
- Java target: `17`
- Main manifest declares `TRANSMIT_IR` and `VIBRATE`; consumer IR hardware is optional.
- The main manifest does not declare `INTERNET`. The final merged APK still needs inspection because plugin manifests and build tooling can contribute permissions.

## Files added/changed on this preparation branch

- Root `.fdroid.yml`: initial in-repository F-Droid metadata/build recipe, using a pinned Flutter SDK reference and a source commit.
- `android/app/build.gradle`: recognizes `FDROID_BUILD=1` and leaves the release APK unsigned so F-Droid can sign it. Existing Codemagic/local signing behavior is retained when that flag is not set.
- `fdroid/DEPENDENCY_LICENSE_AUDIT.md`: preliminary direct-dependency license inventory and outstanding checks.

The recipe currently references Flutter `3.47.7` and source commit `322613fc3bff690e5541f84484ce76f781a21769`. This is a **draft**. After the preparation changes are merged and a release tag is created, update the metadata to the final tagged source commit and verify the exact Flutter srclib reference against the current F-Droid build environment.

## Dependency and asset licensing

See [DEPENDENCY_LICENSE_AUDIT.md](DEPENDENCY_LICENSE_AUDIT.md).

The direct package license metadata is identified for most packages, but `material_neumorphic 1.2.1` remains unverified. The icon-font families bundled by `flutter_font_icons`, all transitive dependencies, Android/Maven dependencies, and every app asset still require review. This is a submission blocker.

## Root license file

The root `LICENSE` says GPL-3.0-or-later but is a project-specific policy summary, not the complete standard GPL text. It explicitly says it does not replace the full license. Before submission, preserve the useful project-specific material in a separate `COPYRIGHT.md` or `NOTICE` and replace `LICENSE` with the complete official GPL-3.0-or-later text, after confirming the project owner has rights to license all original contributions under those terms.

Official text and guidance:
- https://www.gnu.org/licenses/gpl-3.0.html
- https://www.gnu.org/licenses/gpl-howto.en.html

## Build recipe

The root `.fdroid.yml` is an initial self-hosted metadata file. The F-Droid Flutter build pattern uses a Flutter source library, disables Flutter analytics, resolves packages, and builds the APK from source. The build command sets `FDROID_BUILD=1` so the release artifact is not signed with the developer's debug or Codemagic key.

The recipe has **not** been executed with `fdroid build` or in F-Droid's server environment. In particular, verify:
- Flutter 3.47.7 is available as a supported F-Droid srclib revision.
- All pub packages can be resolved within the permitted build steps.
- Gradle/Android SDK components resolve from accepted sources.
- The build produces the expected unsigned APK at the configured output path.
- The APK has the correct application ID and version code and contains no unexpected permissions, proprietary libraries, trackers, or non-free assets.

## Submission checklist

- [ ] Merge/review this preparation branch and create a public release tag.
- [ ] Update `.fdroid.yml` to the exact final release commit and verify its metadata syntax with `fdroid lint`.
- [ ] Complete the root GPL license correction and confirm rights for all original source/assets.
- [ ] Preserve the MIT notice for `material_neumorphic` and complete the transitive dependency review.
- [ ] Audit every transitive Dart/Flutter dependency and Android/Maven dependency.
- [ ] Audit all icon fonts, app icons, images, screenshots, sounds, and other bundled assets.
- [ ] Confirm the project meets F-Droid's activity/maintenance expectations or document a valid exception.
- [ ] Inspect the merged release manifest and final APK permissions.
- [ ] Run `flutter pub get --enforce-lockfile`, `flutter analyze`, and `flutter test`.
- [ ] Run the F-Droid build recipe in a clean F-Droid build environment.
- [ ] Inspect APK signing state, package ID, version code, ABI/native libraries, and generated output.
- [ ] Add final app metadata, screenshots, changelog, and source tag in the official `fdroiddata` repository.
- [ ] Submit for F-Droid review.

## Important boundaries

- Do not delete iOS or other platform source folders from the upstream project just to make the Android build; the recipe removes irrelevant platform folders only in its isolated build copy.
- Do not add or remove Android permissions without checking actual app functionality and the merged manifest.
- Do not claim “fully offline”, “tracker-free”, “reproducible”, or “F-Droid approved” until the relevant checks are actually completed.
- A successful upstream CI build does not substitute for an F-Droid server build.
