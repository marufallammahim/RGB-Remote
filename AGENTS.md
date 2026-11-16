# RGB-LED-REMOTE — Code Review Rules

These rules apply to Codex Code Review and other AI reviewers.

## Review-only boundary
- Review changes and report findings only.
- Never edit files, push commits, create fix commits, merge pull requests, publish releases, or change repository settings.
- Do not request or use API keys, paid model endpoints, or external billing credentials.
- Do not approve a pull request merely because CI passes.

## Review priorities
1. Runtime crashes, regressions, incorrect IR command behavior, and broken Android home-screen widgets.
2. Security and privacy: exported Android components, intent handling, permissions, secrets, unsafe deserialization, and workflow token permissions.
3. Flutter/Dart correctness: async lifecycle safety, disposed controllers, null handling, state persistence, race conditions, and performance on low-memory Android devices.
4. Android compatibility: manifest declarations, Gradle/Kotlin/AGP compatibility, min/target SDK behavior, ABI packaging, and signing/release integrity.
5. Tests: missing regression tests for changed behavior and tests that do not cover relevant edge cases.

## Project-specific constraints
- This is an Android-focused Flutter application. Do not recommend adding iOS-only work unless the change explicitly requires it.
- Preserve existing RGB/IR remote behavior, button mappings, widget layouts, and user settings unless the pull request explicitly intends to change them.
- Do not recommend replacing working features or redesigning UI as part of an unrelated fix.
- Treat hardware IR behavior as device-dependent; distinguish verified defects from assumptions that require physical-device testing.
- Never expose signing keys, passwords, keystore contents, tokens, or secret values in logs, artifacts, comments, or release metadata.

## Finding quality
- Report only actionable findings introduced by the pull request.
- Prioritize severity: critical/high/medium/low.
- Include the exact file and line, the triggering scenario, the impact, and a concrete safe remedy.
- Avoid style-only feedback already covered by Flutter analysis or formatters.
- Do not invent runtime behavior. State when a finding needs device verification.
- If no actionable issue is found, say so briefly.
