# Campus Crew After Dark

**Name:** Muhammad Samad Khan  
**Course:** CSC 4360 — Mobile Application Development  
**Activity:** 11  
**Track:** Undergraduate  
**Project type:** Individual  
**GitHub repository:** https://github.com/mkhan10004/In-Class-Activity-11

## My project

My app extends the Activity 10 signup form into three screens: Welcome Foyer,
Signup Laboratory, and Celebration Ballroom. It keeps the original validators
and adds a password visibility button, a required birth date, a loading step,
and a personalized success screen with confetti. No real account is created.

I ran the app and captured the screenshots below. I also confirmed that pressing
the device Back button from the success screen returned me to the Foyer.

## Main features

- Purple and orange haunted-campus theme with three room indicators.
- Typewriter welcome title and an Enter If You Dare button.
- Required name, basic email validation, and a six-character password minimum.
- Password show/hide button and a required birth-date picker.
- Date range from January 1, 1920 through the device's current date.
- Two-second loading step in the code before success navigation.
- Welcome message using the entered name, confetti, and return to Foyer.
- Signup Coach carried over from Activity 10, clearly labeled as a mock when used.

## Files and navigation

| File | Purpose |
|---|---|
| `lib/main.dart` | Starts the app and sets the theme |
| `lib/screens/welcome_screen.dart` | Welcome screen and entry button |
| `lib/screens/signup_screen.dart` | Form, date picker, visibility, and loading |
| `lib/screens/success_screen.dart` | Personal greeting and confetti |
| `lib/validation/signup_validators.dart` | Original Activity 10 validation rules |
| `lib/widgets/signup_coach.dart` | Retained signup-tip interface |

The Foyer uses `Navigator.push` to open the Lab, so Back can return to the Foyer.
The Lab normally uses `Navigator.pushReplacement` after valid input. This removes
the old form and leaves the Foyer below the Ballroom. I confirmed that system
Back from the Ballroom returned to the Foyer.

The form's controllers, selected birth date, visibility flag, and loading flag
live in SignupScreen State. A normal rotation can keep this State alive; leaving
the route disposes its controllers. A new Lab starts empty, as shown in Figure 10.
The success screen receives only the trimmed name through its constructor and
disposes its ConfettiController when it closes.

## My test evidence

| Check | Recorded result | Evidence |
|---|---|---|
| Welcome screen | Theme and entry button displayed | Figure 1 |
| Empty form | Name, email, password, and birth-date errors displayed | Figure 2 |
| Invalid email | Address without @ rejected | Figure 3 |
| Password visibility | Password text displayed | Figures 4, 6, 7 |
| Birth-date selection | 1920 and 2008 displayed in the date field | Figures 6, 7 |
| Future date | Dates after October 28 greyed out in corrected calendar | Figure 8 |
| Landscape | Name and email remained visible | Figure 5 |
| Successful signup | Welcome, Samad! and confetti appeared | Figure 9 |
| System Back from success | Returned to Foyer | My observation |
| Later Lab visit | Empty form displayed | Figure 10 |



## Ghost Hunt 1 — The Reversed Trapdoor

My normal flow uses push into the Lab and pushReplacement into the Ballroom.
I confirmed that the device Back button on the Ballroom returned me to the
Foyer, matching the expected behavior. With push instead of replacement, I
predict that Back would reveal the old Lab and allow another signup. For the
three cycles below, Back is pressed before each new signup, so the push version
does not accumulate three Ballroom routes. The alternate push run and repeated
cycles have not been recorded and remain predictions.

Stack order is bottom to top: F = Foyer, L = Lab, B = Ballroom.

| Cycle | Replacement at success | After Back | Push at success | After Back |
|---|---|---|---|---|
| 1 | F, B | F | F, L, B | F, L |
| 2 | F, B | F | F, L, B | F, L |
| 3 | F, B | F | F, L, B | F, L |

Trace: `WelcomeScreen` calls `Navigator.push`; `SignupScreen` passes the trimmed
name into `SuccessScreen(userName: ...)` and normally calls `pushReplacement`.
Figure 9 shows the Ballroom; the Back destination is my confirmed observation.

## Ghost Hunt 2 — The Clairvoyant Ghost

My picker allows dates from January 1, 1920 through the device's current date.
The screenshots show 1920 and 2008 in the field, and dates after October 28, 2026
greyed out in the calendar. A wrong `lastDate: DateTime(1990)` would reject 2008
and recent dates, and could prevent the dialog opening if initialDate exceeded
that limit. The table separates captured evidence from the unrecorded lower-bound
rejection. Date selection screenshots retain earlier form errors, so they do not
prove a separate successful signup for each chosen date.

| Input | Expected | Observed |
|---|---|---|
| January 1, 1920 | Selectable | Displayed in field, Figure 6 |
| January 1, 2008 | Selectable | Displayed in field, Figures 4 and 7 |
| Shown current date | Selectable | October 28 selected, Figure 8 |
| Next day | Not selectable | October 29 greyed out, Figure 8 |

The corrected calendar screenshot shows October 28 selected, while October 29–31 are greyed out. This supports the current-date and future-date checks shown in Figure 8.

## Run the project

From the project folder, after installing Flutter and preparing Android:

```powershell
python tool/bootstrap.py
flutter pub get
flutter run --dart-define=USE_MOCK=true
```

If Android files are already set up, skip the bootstrap command. On Windows,
`py tool/bootstrap.py` may be used instead of `python`.

```powershell
flutter analyze
flutter test --dart-define=USE_MOCK=true
flutter build apk --release --dart-define=USE_MOCK=true
```

The release APK is generated at
`build/app/outputs/flutter-apk/app-release.apk`. These commands are instructions,
not a claim that their results have been verified.

## Screenshots

Keep this README beside the `evidence` folder so the images display on GitHub.
Figures 1–7 and 9–10 use the original screenshots. Figure 8 uses the corrected October 28 screenshot.

### Figure 1

Welcome screen with the haunted campus theme and entry button.

![Figure 1](evidence/figure-01.png)

### Figure 2

Empty form showing required errors for name, email, password, and birth date.

![Figure 2](evidence/figure-02.png)

### Figure 3

An email without @ is rejected.

![Figure 3](evidence/figure-03.png)

### Figure 4

The password is visible and the selected date is January 1, 2008. Earlier errors remain on screen.

![Figure 4](evidence/figure-04.png)

### Figure 5

The Lab is shown in landscape. The visible name and email remain in their fields.

![Figure 5](evidence/figure-05.png)

### Figure 6

The birth-date field displays January 1, 1920. Earlier validation messages remain visible.

![Figure 6](evidence/figure-06.png)

### Figure 7

The birth-date field displays January 1, 2008 in the portrait layout.

![Figure 7](evidence/figure-07.png)

### Figure 8

The calendar selects October 28, 2026; October 29–31 are greyed out in this capture.

![Figure 8](evidence/figure-08.png)

### Figure 9

The Ballroom displays Welcome, Samad! with confetti.

![Figure 9](evidence/figure-09.png)

### Figure 10

The Lab is empty on a later visit, with the password hidden by default.

![Figure 10](evidence/figure-10.png)

