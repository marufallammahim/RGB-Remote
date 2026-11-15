# Android Release Signing with GitHub Actions

This repository uses a persistent Android signing identity for customer-facing APK updates.

## Important

- Generate the release keystore once and keep at least two secure offline backups.
- Never commit the keystore, `key.properties`, passwords, or Base64 keystore data.
- Never generate a new keystore for routine app updates. Every update must use the same keystore and alias.
- Do not use the debug signing key for customer releases.
- A new signing key cannot update an older installation signed with a different certificate. Verify the old public APK certificate before the first production release.

## 1. Generate the keystore (Windows PowerShell)

Run this once in a private folder on a trusted computer:

```powershell
keytool -genkeypair -v -keystore RGB-LED-REMOTE-release.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias rgbremote
```

Use a strong, unique keystore password and key password. Save them in a password manager. Keep the JKS file backed up securely.

## 2. Add repository Actions secrets

Open:

**GitHub repository → Settings → Secrets and variables → Actions → New repository secret**

Create these four secrets (names are case-sensitive):

| Secret name | Value |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | Base64 encoding of the complete `.jks` file |
| `ANDROID_KEYSTORE_PASSWORD` | Keystore password |
| `ANDROID_KEY_ALIAS` | `rgbremote` |
| `ANDROID_KEY_PASSWORD` | Password for the `rgbremote` key |

To obtain the Base64 value in PowerShell (do not print it in a terminal or commit it):

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("$PWD\RGB-LED-REMOTE-release.jks")) | Set-Clipboard
```

Paste the clipboard value directly into the `ANDROID_KEYSTORE_BASE64` secret field, then clear the clipboard.

## 3. How a signed GitHub Actions job should prepare signing

A signed workflow should decode the keystore only inside the temporary GitHub-hosted runner and create `android/key.properties`:

```yaml
- name: Configure Android release signing
  env:
    ANDROID_KEYSTORE_BASE64: ${{ secrets.ANDROID_KEYSTORE_BASE64 }}
    ANDROID_KEYSTORE_PASSWORD: ${{ secrets.ANDROID_KEYSTORE_PASSWORD }}
    ANDROID_KEY_ALIAS: ${{ secrets.ANDROID_KEY_ALIAS }}
    ANDROID_KEY_PASSWORD: ${{ secrets.ANDROID_KEY_PASSWORD }}
  run: |
    set -euo pipefail
    test -n "$ANDROID_KEYSTORE_BASE64"
    test -n "$ANDROID_KEYSTORE_PASSWORD"
    test -n "$ANDROID_KEY_ALIAS"
    test -n "$ANDROID_KEY_PASSWORD"

    echo "$ANDROID_KEYSTORE_BASE64" | base64 --decode > android/upload-keystore.jks
    chmod 600 android/upload-keystore.jks

    cat > android/key.properties <<EOF
    storeFile=../upload-keystore.jks
    storePassword=$ANDROID_KEYSTORE_PASSWORD
    keyAlias=$ANDROID_KEY_ALIAS
    keyPassword=$ANDROID_KEY_PASSWORD
    EOF
    chmod 600 android/key.properties
```

The existing `android/app/build.gradle` already reads `android/key.properties` and uses it for release signing when the configured keystore exists.

## 4. Verify the signing identity

After a signed APK is built, verify it with Android Build Tools:

```bash
apksigner verify --verbose --print-certs path/to/app-release.apk
```

Record the SHA-256 certificate digest securely. Future release APKs must report the same signer certificate. Also compare it with the certificate of the currently published APK before promising seamless updates.

## Repository status

- `android/app/build.gradle` supports the `android/key.properties` signing route.
- `.gitignore` excludes `android/key.properties` and JKS/keystore files.
- The existing `.github/workflows/android-apk.yml` is intentionally an unsigned F-Droid-compatible build; do not turn that workflow into a customer release workflow.
- Repository Actions secrets must be entered by an authorized repository owner in GitHub Settings. The connected GitHub integration cannot create or read secret values.
