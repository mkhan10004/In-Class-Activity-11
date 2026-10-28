import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signup_app/main.dart';
import 'package:signup_app/diagnostics/route_trace.dart';
import 'package:signup_app/screens/signup_screen.dart';
import 'package:signup_app/screens/success_screen.dart';
import 'package:signup_app/screens/welcome_screen.dart';

Future<void> openLab(WidgetTester tester) async {
  await tester.pumpWidget(const HauntedMansionApp());
  await tester.tap(find.byKey(const Key('enter-mansion')));
  await tester.pumpAndSettle();
}

Future<void> fillForm(WidgetTester tester) async {
  await tester.enterText(find.byKey(const Key('name')), '  Samad  ');
  await tester.enterText(find.byKey(const Key('email')), 'demo@example.com');
  await tester.enterText(find.byKey(const Key('password')), 'demo123');
  await tester.ensureVisible(find.byKey(const Key('birth-date')));
  await tester.tap(find.byKey(const Key('birth-date')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => routeTrace.resetForTest());

  testWidgets('empty form preserves all Activity 10 errors and requires date', (tester) async {
    await openLab(tester);
    final submit = find.byKey(const Key('signup'));
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pump();
    expect(find.text('Please enter your name'), findsOneWidget);
    expect(find.text('Please enter your email'), findsOneWidget);
    expect(find.text('Please enter a password'), findsOneWidget);
    expect(find.text('Pick your birth date'), findsOneWidget);
    expect(find.byType(SuccessScreen), findsNothing);
  });

  testWidgets('password visibility changes without changing text', (tester) async {
    await openLab(tester);
    final password = find.byKey(const Key('password'));
    await tester.enterText(password, 'demo123');
    final editable = find.descendant(of: password, matching: find.byType(EditableText));
    expect(tester.widget<EditableText>(editable).obscureText, isTrue);
    await tester.tap(find.byKey(const Key('toggle-password')));
    await tester.pump();
    expect(tester.widget<EditableText>(editable).obscureText, isFalse);
    expect(tester.widget<TextFormField>(password).controller!.text, 'demo123');
    await tester.tap(find.byKey(const Key('toggle-password')));
    await tester.pump();
    expect(tester.widget<EditableText>(editable).obscureText, isTrue);
  });

  testWidgets('picker bounds are 1920 through today and cancel keeps date empty', (tester) async {
    await openLab(tester);
    final field = find.byKey(const Key('birth-date'));
    await tester.ensureVisible(field);
    await tester.tap(field);
    await tester.pumpAndSettle();
    final picker = tester.widget<DatePickerDialog>(find.byType(DatePickerDialog));
    expect(picker.firstDate, DateTime(1920));
    expect(picker.lastDate, DateUtils.dateOnly(DateTime.now()));
    expect(picker.initialDate!.isAfter(picker.lastDate), isFalse);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(tester.widget<TextFormField>(field).controller!.text, isEmpty);
  });

  testWidgets('back from lab destroys typed values', (tester) async {
    await openLab(tester);
    await tester.enterText(find.byKey(const Key('name')), 'Samad');
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(WelcomeScreen), findsOneWidget);
    await tester.tap(find.byKey(const Key('enter-mansion')));
    await tester.pumpAndSettle();
    expect(tester.widget<TextFormField>(find.byKey(const Key('name'))).controller!.text, isEmpty);
  });

  testWidgets('loading disables submit, then success receives trimmed name', (tester) async {
    await openLab(tester);
    await fillForm(tester);
    final submit = find.byKey(const Key('signup'));
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pump();
    expect(tester.widget<ElevatedButton>(submit).onPressed, isNull);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(submit); // disabled second tap must not queue a route
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Welcome, Samad!'), findsOneWidget);
    expect(routeTrace.names, experimentUsesPush
        ? ['Foyer', 'Lab', 'Ballroom'] : ['Foyer', 'Ballroom']);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(experimentUsesPush ? SignupScreen : WelcomeScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('leaving during loading never opens ballroom later', (tester) async {
    await openLab(tester);
    await fillForm(tester);
    await tester.ensureVisible(find.byKey(const Key('signup')));
    await tester.tap(find.byKey(const Key('signup')));
    await tester.pump();
    await tester.pageBack();
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(find.byType(SuccessScreen), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('normal rotation preserves form State while route remains alive', (tester) async {
    tester.view.physicalSize = const Size(600, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await openLab(tester);
    await fillForm(tester);
    await tester.ensureVisible(find.byKey(const Key('toggle-password')));
    await tester.tap(find.byKey(const Key('toggle-password')));
    await tester.pump();
    final before = tester.widget<TextFormField>(find.byKey(const Key('birth-date'))).controller!.text;
    tester.view.physicalSize = const Size(1000, 600);
    await tester.pumpAndSettle();
    expect(tester.widget<TextFormField>(find.byKey(const Key('name'))).controller!.text, '  Samad  ');
    expect(tester.widget<TextFormField>(find.byKey(const Key('birth-date'))).controller!.text, before);
    final editable = find.descendant(of: find.byKey(const Key('password')), matching: find.byType(EditableText));
    expect(tester.widget<EditableText>(editable).obscureText, isFalse);
    expect(tester.takeException(), isNull);
  });
}
