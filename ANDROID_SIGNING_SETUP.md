# Android Release Signing with GitHub Actions

This repository uses a persistent Android signing identity for customer-facing APK updates.

## Important

- Generate the release keystore once and keep at least two secure offline backups.
- Never commit the keystore, `key.properties`, passwords, or Base64 keystore data.
- Never generate a new keystore for routine app updates. Every update must use the same keystore and alias.
- Do not use the debug signing key for customer releases.
- A new signing key cannot update an older installation signed with a different certificate. Verify the old public APK certificate before promising seamless updates.

## 1. Generate the keystore on Arch Linux

Install Java 17:

```bash
sudo pacman -S --needed jdk17-openjdk
```

Generate the keystore once in a private directory:

```bash
keytool -genkeypair -v \
  -keystore RGB-LED-REMOTE-release.jks \
  -storetype JKS \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias rgbremote
```

Use strong, unique passwords. Keep the JKS file and passwords in secure offline backups/password manager. The JKS deprecation warning does not mean key generation failed; this workflow supports the JKS file created by the command above.

## 2. Encode the keystore for GitHub Actions

From the directory containing the JKS file:

```bash
base64 -w 0 RGB-LED-REMOTE-release.jks > keystore-base64.txt
```

Copy the value to the clipboard if you have a clipboard utility installed:

- Wayland: `wl-copy < keystore-base64.txt` (package: `wl-clipboard`)
- X11: `xclip -selection clipboard -i keystore-base64.txt` (package: `xclip`)

Or open `keystore-base64.txt` in a text editor and copy its complete single-line content. Do not paste the value into chat, terminal logs, or repository files.

## 3. Add repository Actions secrets

Open:

**GitHub repository → Settings → Secrets and variables → Actions → New repository secret**

Create these four secrets (names are case-sensitive):

| Secret name | Value |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | Complete Base64 encoding of the JKS file |
| `ANDROID_KEYSTORE_PASSWORD` | Keystore password |
| `ANDROID_KEY_ALIAS` | `rgbremote` |
| `ANDROID_KEY_PASSWORD` | Password for the `rgbremote` key |

## 4. Build and publish signed releases

The workflow `.github/workflows/signed-release.yml`:

- Uses the four repository secrets to reconstruct the JKS only on the temporary GitHub-hosted runner.
- Runs `flutter pub get`, `flutter analyze`, and `flutter test`.
- Builds ABI-specific APKs plus a universal APK.
- Verifies every APK signature and confirms that all four APKs use the same certificate.
- Publishes APKs, SHA-256 checksums, and build information when a matching version tag is pushed.
- A manual `workflow_dispatch` run builds and uploads signed APKs as a temporary Actions artifact; it does not publish a Stable Release.
- Leaves the F-Droid unsigned workflow separate and unchanged.

To publish a stable release, update `pubspec.yaml` first using a version newer than the existing stable release. The latest existing stable tag is `v1.0.3`; therefore the next version name must be higher (for example, `1.0.4`). Set its Android `versionCode` to a number higher than the one recorded in the previous version tag; the workflow checks this automatically. Then create the matching tag (for example, `v1.0.4`).

To test the signing setup before publishing, open **Actions → RGB-LED-REMOTE Signed Android Release → Run workflow**. The signed APKs will be available in that run's Artifacts section.

## 5. Verify signing identity

The workflow prints the SHA-256 signing certificate digest and stores it in `BUILD-INFO.txt`. Future releases must report the same digest. Also compare it with the certificate of any APK currently installed by users before promising seamless in-place upgrades.

## Repository security

- `android/key.properties` and JKS/keystore files are excluded by `.gitignore`.
- Never upload the JKS file to the repository or expose any secret value.
- The existing `.github/workflows/android-apk.yml` remains an unsigned F-Droid-compatible build and is intentionally not used for customer releases.
