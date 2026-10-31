# Dependency and asset license audit

Audit scope: direct Flutter dependencies pinned by the repository's `pubspec.lock`, checked against the package pages for those exact versions where available. This is a preliminary audit, not a complete software bill of materials.

## Direct runtime dependencies

| Package | Locked version | Published package license | Result |
| --- | ---: | --- | --- |
| `flutter_font_icons` | 3.0.0 | Apache-2.0 | Package license identified; bundled icon-font families need individual upstream license/notice review |
| `material_neumorphic` | 1.2.1 | MIT | Package license identified from the exact pub.dev version page; preserve its copyright/permission notice |
| `flutter_dropdown_alert` | 1.0.7 | MIT | Package license identified |
| `shared_preferences` | 2.5.3 | BSD-3-Clause | Package license identified |
| `package_info_plus` | 8.3.0 | BSD-3-Clause | Package license identified |
| `url_launcher` | 6.3.1 | BSD-3-Clause | Package license identified |
| `page_transition` | 2.2.2 | BSD-2-Clause | Package license identified |
| `just_the_tooltip` | 0.0.12 | MIT | Package license identified |

## Still required

- Audit every transitive package in `pubspec.lock`, including the Android platform packages actually included in the APK.
- Audit Android Gradle/Maven dependencies resolved by AGP, Kotlin, and Flutter plugins; record exact versions and licenses.
- Inspect the `flutter_font_icons` archive and identify the license for every font family actually bundled into the APK. The package's Apache-2.0 declaration does not automatically replace notices from upstream icon/font projects.
- Inspect all repository assets, app icons, screenshots, sounds, and any binary files for ownership, license, and redistribution rights.
- Preserve the MIT copyright and permission notice for `material_neumorphic 1.2.1` in the third-party notices bundle, and inspect its transitive components.
- Generate a complete notices file from the exact release build's dependency graph, not merely from this direct-dependency table.

## Evidence links

- https://pub.dev/packages/flutter_font_icons
- https://pub.dev/packages/material_neumorphic
- https://pub.dev/packages/flutter_dropdown_alert
- https://pub.dev/packages/shared_preferences/versions/2.5.3
- https://pub.dev/packages/package_info_plus/versions/8.3.0
- https://pub.dev/packages/url_launcher/versions/6.3.1
- https://pub.dev/packages/page_transition/versions/2.2.2
- https://pub.dev/packages/just_the_tooltip/versions/0.0.12

## F-Droid status

**Not cleared for submission.** The unverified `material_neumorphic` license and incomplete transitive/asset audit are release blockers. F-Droid requires the complete app and its dependencies/assets to meet its free-software and redistribution requirements.
