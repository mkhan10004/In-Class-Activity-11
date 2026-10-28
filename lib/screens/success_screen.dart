import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import '../diagnostics/route_trace.dart';
import '../widgets/mansion_step.dart';

class SuccessScreen extends StatefulWidget {
  const SuccessScreen({super.key, required this.userName});
  final String userName;
  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  late final ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 3));
    _confetti.play();
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFF7F1FC),
        bottomNavigationBar: const RouteTracePanel(),
        body: Stack(children: [
          SafeArea(
            child: LayoutBuilder(builder: (context, bounds) => SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: (bounds.maxHeight - 48).clamp(0.0, double.infinity).toDouble()),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const MansionStep(number: 3, label: 'THE BALLROOM'),
                      const SizedBox(height: 32),
                      const Icon(Icons.celebration_outlined, size: 78, color: Color(0xFF6D39B4)),
                      const SizedBox(height: 24),
                      Text('Welcome, ${widget.userName}!', key: const Key('welcome-name'),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold, color: const Color(0xFF321058))),
                      const SizedBox(height: 16),
                      const Card(child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(children: [
                          Text('CAMPUS CREW  /  AFTER DARK', textAlign: TextAlign.center,
                            style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.w600)),
                          SizedBox(height: 12),
                          Text('Your haunted guest pass is confirmed.', textAlign: TextAlign.center),
                          SizedBox(height: 8),
                          Text('The candles are lit. Your crew is waiting.', textAlign: TextAlign.center),
                        ]),
                      )),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        key: const Key('back-foyer'),
                        onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                        icon: const Icon(Icons.home_outlined),
                        label: const Text('Back to the Foyer'),
                      ),
                      const SizedBox(height: 12),
                      const Text('Demo guest pass only; no account has been stored.',
                        textAlign: TextAlign.center),
                    ]),
                  ),
                ),
              ),
            )),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: IgnorePointer(child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              numberOfParticles: 12,
              emissionFrequency: 0.06,
              colors: const [Color(0xFF6D39B4), Color(0xFFF5A34D), Color(0xFF55BBA1)],
            )),
          ),
        ]),
      );
}
