import 'package:flutter/material.dart';
import '../diagnostics/route_trace.dart';
import '../validation/signup_validators.dart';
import '../widgets/mansion_step.dart';
import '../widgets/signup_coach.dart';
import 'success_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _dateController = TextEditingController();
  DateTime? _birthDate;
  bool _obscurePassword = true;
  bool _submitting = false;

  Future<void> _pickBirthDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final first = DateTime(1920, 1, 1);
    final initial = _birthDate ?? DateTime(today.year - 18, today.month, today.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(first) ? first : initial,
      firstDate: first,
      lastDate: today,
      helpText: 'Choose your birth date',
    );
    if (!mounted || picked == null) return;
    setState(() {
      _birthDate = picked;
      _dateController.text = '${picked.month}/${picked.day}/${picked.year}';
    });
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    // Snapshot the name before the async gap; freeze form controls while waiting.
    final nameForPass = _name.text.trim();
    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted || ModalRoute.of(context)?.isCurrent != true) return;
    final ballroom = MaterialPageRoute<void>(
      settings: const RouteSettings(name: 'Ballroom'),
      builder: (_) => SuccessScreen(userName: nameForPass),
    );
    if (experimentUsesPush) {
      // Controlled Ghost Hunt swap, not the default release behavior.
      await Navigator.push<void>(context, ballroom);
      if (!mounted) return;
      setState(() => _submitting = false);
    } else {
      Navigator.pushReplacement<void, void>(context, ballroom);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('The Signup Laboratory')),
        bottomNavigationBar: const RouteTracePanel(),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 540),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  const MansionStep(number: 2, label: 'THE LABORATORY'),
                  const SizedBox(height: 24),
                  Text('Sign the haunted guest book',
                    style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  const Text('One name. One guest pass. A night to remember.'),
                  const SizedBox(height: 24),
                  Form(
                    key: _formKey,
                    child: Column(children: [
                      TextFormField(
                        key: const Key('name'), controller: _name,
                        enabled: !_submitting,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(labelText: 'Full Name',
                          prefixIcon: Icon(Icons.person_outline)),
                        validator: validateName,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        key: const Key('email'), controller: _email,
                        enabled: !_submitting,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autocorrect: false,
                        decoration: const InputDecoration(labelText: 'Email Address',
                          prefixIcon: Icon(Icons.email_outlined)),
                        validator: validateEmail,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        key: const Key('password'), controller: _password,
                        enabled: !_submitting,
                        obscureText: _obscurePassword,
                        enableSuggestions: false, autocorrect: false,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          helperText: 'At least 6 characters for this classroom demo',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            key: const Key('toggle-password'),
                            tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                            onPressed: _submitting ? null : () => setState(
                              () => _obscurePassword = !_obscurePassword),
                            icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                          ),
                        ),
                        validator: validatePassword,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        key: const Key('birth-date'), controller: _dateController,
                        enabled: !_submitting, readOnly: true,
                        onTap: _pickBirthDate,
                        decoration: const InputDecoration(labelText: 'Birth Date',
                          prefixIcon: Icon(Icons.cake_outlined),
                          helperText: 'Choose a date from 1920 through today'),
                        validator: (_) => _birthDate == null ? 'Pick your birth date' : null,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(width: double.infinity,
                        child: ElevatedButton(
                          key: const Key('signup'),
                          onPressed: _submitting ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6D39B4),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(16)),
                          child: _submitting
                            ? const SizedBox(width: 22, height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2,
                                  semanticsLabel: 'Preparing your guest pass'))
                            : const Text('Join the Mansion'),
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 12),
                  const Text('Demo only. Your details are not saved.', textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  const SignupCoach(),
                ]),
              ),
            ),
          ),
        ),
      );
}
