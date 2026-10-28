# Ghost Hunt I: repeatable evidence procedure

The Word document uses the Reversed Trapdoor and Clairvoyant Ghost prompts.
The normal app has no graduate extension. The diagnostic flags below exist only
to make the required experiment and route-stack screenshots reproducible.

## 1. Reversed Trapdoor

Fully stop the app between modes; hot reload does not change compile-time defines.

Normal mode with visible route names:

```powershell
flutter run --dart-define=USE_MOCK=true --dart-define=SHOW_ROUTE_TRACE=true
```

1. Enter Lab, fill dummy data, select a birth date, then submit.
2. Capture Ballroom with the route strip. Expected: Foyer > Ballroom.
3. Press system Back. Expected: Foyer, with no Lab to return to.
4. Enter again, confirm the form is empty, refill, and submit.
5. Repeat until there have been three submissions. Capture Back behavior each time.

Swapped push mode:

```powershell
flutter run --dart-define=USE_MOCK=true --dart-define=SHOW_ROUTE_TRACE=true --dart-define=GHOST_USE_PUSH=true
```

1. Fill the form and submit; capture Foyer > Lab > Ballroom.
2. Press system Back; expected Lab with its existing values.
3. Submit again from that Lab; repeat through three submissions.
4. Record what actually happened and compare with the predicted table.

This procedure pops Ballroom before each resubmission. It does NOT accumulate
three Ballrooms. Under replacement it returns to Foyer and opens a new Lab each
cycle; under push it returns to the same Lab. The experimental branch resets
loading after the pushed Ballroom closes so the same form can be submitted again.

| Cycle | Normal: after success | Normal: after Back | Swapped: after success | Swapped: after Back | Observed |
|---|---|---|---|---|---|
| 1 | Foyer > Ballroom | Foyer | Foyer > Lab > Ballroom | Foyer > Lab | Pending |
| 2 | Foyer > Ballroom | Foyer | Foyer > Lab > Ballroom | Foyer > Lab | Pending |
| 3 | Foyer > Ballroom | Foyer | Foyer > Lab > Ballroom | Foyer > Lab | Pending |

Screenshot names suggested for your own captures: replacement-success.png,
replacement-back.png, push-success.png, push-back.png. The route strip contains
only screen names and never form values. Do not claim screenshots exist until captured.

## 2. Clairvoyant Ghost: date boundary tests

Run the normal build. Tap Birth Date, switch to input mode with the edit icon,
enter each candidate in the device's date format, and tap OK. Alternatively use
the calendar/year selector. Clear/cancel between invalid candidates as needed.
Use the actual local test date for Today/Tomorrow; the app calculates it at runtime.

| Candidate | Correct expected result | Effect of erroneous lastDate: DateTime(1990) | Observed |
|---|---|---|---|
| 01/01/1920 | Accepted (inclusive first date) | Accepted | Pending |
| 12/31/1919 | Rejected (before first date) | Rejected | Pending |
| 01/01/2005 | Accepted | Wrongly rejected | Pending |
| Today | Accepted (inclusive last date) | Wrongly rejected for current dates | Pending |
| Tomorrow | Rejected (future date) | Rejected | Pending |

Capture the selected field for accepted cases and the picker error/disabled
choice for rejected cases. The test that leaves Birth Date empty is also covered
in the full-flow log; it is separate from these five boundary rows.

If actually trying lastDate: DateTime(1990), note that it means January 1, 1990.
The default initial date is today minus 18 years. On modern dates this would
exceed the broken lastDate and trigger an assertion before the picker appears.
Record that initial failure; only to isolate the upper-bound experiment, set a
valid initial date such as DateTime(1989), rerun the rows, and restore the correct
code afterward. Do not report the predicted assertion as observed until tested.

## Restore normal behavior

Stop and rerun without GHOST_USE_PUSH and SHOW_ROUTE_TRACE before your normal
build. The original source default already uses pushReplacement.
