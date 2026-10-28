import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import '../diagnostics/route_trace.dart';
import '../widgets/mansion_step.dart';
import 'signup_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        bottomNavigationBar: const RouteTracePanel(),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Color(0xFF321058), Color(0xFF15101E)],
            ),
          ),
          child: SafeArea(
            child: LayoutBuilder(builder: (context, bounds) => SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: (bounds.maxHeight - 56).clamp(0.0, double.infinity).toDouble()),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const MansionStep(number: 1, label: 'THE FOYER', dark: true),
                        const SizedBox(height: 38),
                        const Icon(Icons.nightlight_round, size: 76, color: Color(0xFFF5A34D)),
                        const SizedBox(height: 24),
                        const Text('CAMPUS CREW', style: TextStyle(
                          color: Color(0xFFF5A34D), letterSpacing: 4,
                          fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        AnimatedTextKit(
                          animatedTexts: [TypewriterAnimatedText(
                            'After Dark Mansion',
                            textAlign: TextAlign.center,
                            textStyle: const TextStyle(fontSize: 32,
                              fontWeight: FontWeight.bold, color: Colors.white),
                            speed: const Duration(milliseconds: 90),
                          )],
                          totalRepeatCount: 1,
                          isRepeatingAnimation: false,
                          displayFullTextOnTap: true,
                        ),
                        const SizedBox(height: 18),
                        const Text('The study halls are closed.\nThe haunted guest book is open.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70, fontSize: 17, height: 1.5)),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          key: const Key('enter-mansion'),
                          onPressed: () => Navigator.push<void>(context,
                            MaterialPageRoute<void>(
                              settings: const RouteSettings(name: 'Lab'),
                              builder: (_) => const SignupScreen(),
                            )),
                          icon: const Icon(Icons.door_front_door_outlined),
                          label: const Text('Enter If You Dare'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF5A34D),
                            foregroundColor: const Color(0xFF241330),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18)),
                        ),
                        const SizedBox(height: 24),
                        const Text('A classroom guest pass. No real account is created.',
                          textAlign: TextAlign.center, style: TextStyle(color: Colors.white60)),
                      ],
                    ),
                  ),
                ),
              ),
            )),
          ),
        ),
      );
}
