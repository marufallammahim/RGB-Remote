# Contributing to RGB-LED-REMOTE

Thank you for considering a contribution to RGB-LED-REMOTE. This guide describes a small, safe workflow for proposing changes.

## Before you start

- Check the existing issues and pull requests to avoid duplicating work.
- Keep each change focused on one bug fix, improvement, or documentation update.
- Do not commit signing keys, passwords, API tokens, personal data, or generated build artifacts.
- For IR-related changes, identify the phone model, whether it has a consumer IR emitter, and the LED controller used for testing.

## Development setup

Install a Flutter stable SDK compatible with the constraints in `pubspec.yaml`, Android SDK tooling, and JDK 17.

From the repository root, run:

```bash
flutter pub get
flutter analyze
flutter test
```

To build an Android release locally:

```bash
flutter build apk --release
```

The expected APK output is:

```text
build/app/outputs/flutter-apk/app-release.apk
```

A successful build does not by itself verify IR behavior on physical hardware.

## Making a change

1. Create a branch from the latest `main`.
2. Make the smallest change that fully addresses the task.
3. Run the relevant checks listed above.
4. Review the diff and remove unrelated edits or temporary files.
5. Commit with a clear message describing the change.

Example branch names:

- `fix/short-description`
- `docs/short-description`
- `feature/short-description`

## Pull request checklist

In your pull request, include:

- A concise summary of the change and its motivation.
- The relevant issue number, if one exists.
- The commands you ran and their results.
- Screenshots for visible UI changes, where useful.
- Device/controller details and observed results for IR-related changes.
- Any known limitations or follow-up work.

Please do not state that a feature or hardware behavior was verified unless it was actually tested.

## Scope and compatibility

- Preserve the Android-focused scope unless a task explicitly changes it.
- Avoid changing existing IR command data or protocol behavior as part of unrelated UI or documentation work.
- Keep user-facing settings and their persistence behavior backward-compatible where possible.
- Update documentation when setup steps, supported behavior, or important limitations change.

## Reporting bugs

When filing a bug report, include the app version, Android version, phone model, steps to reproduce, expected behavior, actual behavior, and relevant logs. Remove personal information and secrets from logs before sharing them.

Thank you for helping improve RGB-LED-REMOTE.
