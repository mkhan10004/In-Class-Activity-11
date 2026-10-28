# Campus Crew: After Dark

**Muhammad Samad Khan · CSC 4360 · Activity 11 · Undergraduate**

A haunted campus guest book extending the Activity 10 signup app. The normal
flow is Foyer → Laboratory → Ballroom. This is the shared undergraduate build;
no graduate storage or guarded-crypt extension is included.

## Start

See `START_HERE.txt` for copying the changes into your existing Activity 10
Android project. To set up this standalone source folder:

```powershell
flutter doctor
flutter devices
python tool/bootstrap.py
flutter run --dart-define=USE_MOCK=true
```

`py tool/bootstrap.py` is an alternative on Windows. The bootstrap script creates
Android platform files using your installed SDK and adds Internet permission.
The package contains source and tests, not a prebuilt APK or generated SDK files.

If the instructor service is available, keep its Activity 10 configuration:

```powershell
flutter run --dart-define=AI_PROXY_URL=INSTRUCTOR_HTTPS_ENDPOINT
```

The Activity 10 coach remains separate from signup acceptance. Its fixed request
contains only `task: signup_tip` and `topic: password_help`. Name, email, password,
and birth date are not supplied to it. Mock responses are explicitly labeled;
no model is called in mock mode. No real account or local storage is created.

## What changed from Activity 10

- `lib/main.dart` is a small app shell that opens `WelcomeScreen`.
- `lib/screens/welcome_screen.dart` has a violet night gradient, typewriter title,
  an amber entry button, and the first of three room indicators.
- `lib/screens/signup_screen.dart` reuses the original validator functions
  unchanged and adds visibility, required birth date, and loading state.
- `lib/screens/success_screen.dart` receives the trimmed name through its
  constructor and plays a three-second, non-looping confetti celebration.
- `lib/widgets/signup_coach.dart` holds the retained Activity 10 coach state.
- `lib/diagnostics/route_trace.dart` supports optional, normally hidden
  navigation evidence for the Reversed Trapdoor experiment.

## Stack, state lifetime, and disposal

The entry button uses `Navigator.push`, leaving Foyer underneath Lab. Back from
Lab therefore returns to Foyer. Lab owns the name, email, password, and date
controllers, plus `_birthDate`, `_obscurePassword`, and `_submitting`; popping
that route disposes those controllers, so entering again creates a blank form.
A normal orientation change that preserves the route's State should retain
these values. A process restart is different and no restoration is implemented.

On valid input, the submit method snapshots the trimmed name, disables form
controls and the submit button, and waits two seconds. It checks `mounted` and
whether the route is still current before navigation. In the normal build,
`pushReplacement` removes Lab and inserts Ballroom, leaving `[Foyer, Ballroom]`.
System Back can return to Foyer; it cannot return to the old Lab or resubmit it.
The explicit Back to the Foyer button uses `popUntil(route.isFirst)`.

Ballroom owns and disposes its `ConfettiController`. It retains only the string
passed as `userName`; it does not receive the password, email, or birth date.
The coach separately closes its HTTP client and checks `mounted` after awaits.

## Theme choice

Campus Crew continues from Activity 10 as a haunted campus event. The design
adds a three-room progress motif, a guest-pass card, candle-themed wording,
consistent violet/amber colors, and scrollable constrained layouts. Those
styling additions still require your small-screen/landscape verification.

## Checks

```powershell
dart format lib test
flutter analyze
flutter test --dart-define=USE_MOCK=true
```

The source includes Activity 10 validation/service tests and Activity 11 widget
tests for form errors, visibility, picker bounds, route state destruction,
loading, route replacement, mid-load exit, and rotation. **Flutter was unavailable
in the creation environment, so these tests have not been executed there.**
`docs/TEST_LOG.md` separates expected behavior from actual device observations.
The existing Activity 10 screenshots are not Activity 11 test evidence.

## Ghost Hunt experiments

`docs/GHOST_HUNT.md` gives a reproducible three-cycle navigation comparison and
a five-row birth-date boundary test. Diagnostic flags are off by default.
Do not use `GHOST_USE_PUSH=true` for the normal final build.

## Bug Graveyard

No Activity 11 runtime failure is claimed without a run. The following are
code-review findings and preventive decisions, not invented emulator results.

| Potential symptom | Code cause | Implementation decision |
|---|---|---|
| Form reappears after success | Success reached with push | Default uses pushReplacement |
| Navigation after leaving mid-load | Delayed callback outlives route | mounted and current-route check after delay |
| Keyboard or landscape overflow | Unscrollable tall Column | SafeArea and SingleChildScrollView |
| Date update after exit | Date dialog returns after disposal | mounted check before setState |
| Confetti resources remain | Controller never disposed | Dispose controller with SuccessScreen |

Actual bugs, fixes, and retest results: record these in `docs/TEST_LOG.md` after
running; do not present this preventive table as a history of observed failures.

## Build

```powershell
flutter build apk --release --dart-define=USE_MOCK=true
```

Output: `build/app/outputs/flutter-apk/app-release.apk`.
If release is blocked, use `--debug` instead and record the actual reason.
For live mode use `AI_PROXY_URL=INSTRUCTOR_HTTPS_ENDPOINT` instead of the mock
define. No APK build or installation has been verified in this environment.

## Ownership

Prepared for Muhammad Samad Khan as an individual project, as requested.
The supplied Activity 11 rubric describes group collaboration and four roles;
no collaborators, role history, or group commits are asserted here. Confirm the
individual arrangement with the instructor if the group rubric still applies.

## Reference documentation

- https://api.flutter.dev/flutter/widgets/Navigator/pushReplacement.html
- https://pub.dev/packages/animated_text_kit
- https://pub.dev/packages/confetti
