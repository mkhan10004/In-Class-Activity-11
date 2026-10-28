import 'package:flutter/material.dart';
import '../services/signup_tip_service.dart';

// Activity 10 coach moved intact in behavior into a separate state owner.
class SignupCoach extends StatefulWidget {
  const SignupCoach({super.key});
  @override
  State<SignupCoach> createState() => _SignupCoachState();
}

class _SignupCoachState extends State<SignupCoach> {
  static const _endpoint = String.fromEnvironment('AI_PROXY_URL');
  static const _allowMock = bool.fromEnvironment('USE_MOCK');
  SignupTipService? _service;
  String? _configurationError;
  String? _tip;
  String? _error;
  bool _loading = false;
  MockScenario _scenario = MockScenario.success;

  @override
  void initState() {
    super.initState();
    if (_endpoint.isNotEmpty) {
      try {
        _service = HttpSignupTipService(endpoint: Uri.parse(_endpoint));
      } catch (_) {
        _configurationError = 'Invalid configuration. Supply the instructor HTTPS endpoint.';
      }
    } else if (_allowMock) {
      _service = createMockService(_scenario);
    } else {
      _configurationError = 'The instructor endpoint is not configured. '
          'See README for live setup or the documented mock fallback.';
    }
  }

  Future<void> _getTip() async {
    final service = _service;
    if (_loading || service == null) return;
    setState(() {
      _loading = true;
      _tip = null;
      _error = null;
    });
    try {
      final result = await service.getTip();
      if (!mounted) return;
      setState(() => _tip = result);
    } on TipException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Could not load a tip. Please retry.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _changeScenario(MockScenario? value) {
    if (value == null || _loading) return;
    _service?.close();
    setState(() {
      _scenario = value;
      _service = createMockService(value);
      _tip = null;
      _error = null;
    });
  }


  @override
  void dispose() {
    _service?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mock = _service?.isMock ?? false;
    return Card(child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('Signup Coach', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(mock ? 'MOCK AI ADVICE — deterministic example; no live model called.'
            : 'AI-generated advice — suggestions only.'),
        const SizedBox(height: 8),
        const Text('Only a fixed task and topic are sent. No form values or birth date leave the device.'),
        if (_configurationError != null) Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(_configurationError!),
        ),
        if (mock) ...[
          const SizedBox(height: 12),
          DropdownButtonFormField<MockScenario>(
            value: _scenario, isExpanded: true,
            decoration: const InputDecoration(labelText: 'Mock test scenario'),
            items: MockScenario.values.map((scenario) => DropdownMenuItem(
              value: scenario,
              child: Text(switch (scenario) {
                MockScenario.success => 'Successful response',
                MockScenario.offline => 'Offline failure',
                MockScenario.malformed => 'Malformed JSON',
                MockScenario.empty => 'Empty tip',
                MockScenario.timeout => '10-second timeout',
                MockScenario.serverError => 'HTTP 503 error',
              }),
            )).toList(),
            onChanged: _loading ? null : _changeScenario,
          ),
        ],
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _loading || _service == null ? null : _getTip,
          icon: const Icon(Icons.lightbulb_outline),
          label: Text(_loading ? 'Getting tip…' : 'Get a signup tip'),
        ),
        if (_loading) const Center(child: Padding(
          padding: EdgeInsets.all(12),
          child: CircularProgressIndicator(semanticsLabel: 'Loading signup tip'))),
        if (_tip != null) Semantics(liveRegion: true,
          child: Text(_tip!, key: const Key('tip-result'))),
        if (_error != null) Semantics(liveRegion: true,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(_error!),
            TextButton(onPressed: _loading ? null : _getTip, child: const Text('Retry')),
          ])),
      ]),
    ));
  }
}
