import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

enum MockScenario { success, offline, malformed, empty, timeout, serverError }

abstract class SignupTipService {
  bool get isMock;
  Future<String> getTip();
  void close();
}

class TipException implements Exception {
  const TipException(this.message);
  final String message;
}

// Shared by the live transport and mock: identical request, response parsing,
// deadline, and error behavior. This method takes NO form values.
class HttpSignupTipService implements SignupTipService {
  HttpSignupTipService({
    required this.endpoint,
    http.Client? client,
    this.isMock = false,
    this.timeout = const Duration(seconds: 10),
  }) : _client = client ?? http.Client() {
    if (endpoint.scheme != 'https' ||
        endpoint.host.isEmpty ||
        endpoint.userInfo.isNotEmpty ||
        endpoint.hasFragment) {
      throw ArgumentError('Use the exact instructor HTTPS endpoint without credentials.');
    }
  }

  final Uri endpoint;
  final http.Client _client;
  final Duration timeout;
  @override
  final bool isMock;

  @override
  Future<String> getTip() async {
    try {
      final request = http.Request('POST', endpoint)
        ..followRedirects = false
        ..headers['Content-Type'] = 'application/json'
        ..headers['Accept'] = 'application/json'
        ..body = jsonEncode(const {
          'task': 'signup_tip',
          'topic': 'password_help',
        });
      // Deadline includes both response headers and response body.
      final response = await (() async {
        final streamed = await _client.send(request);
        return http.Response.fromStream(streamed);
      })().timeout(timeout);
      if (response.statusCode != 200) {
        throw const TipException('The tip service is unavailable. Please retry.');
      }
      final Object? decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map<String, dynamic> || decoded['tip'] is! String) {
        throw const TipException('The service returned an invalid tip. Please retry.');
      }
      final tip = (decoded['tip'] as String).trim();
      if (tip.isEmpty) {
        throw const TipException('The service returned an empty tip. Please retry.');
      }
      // Limit Unicode code points without splitting a surrogate pair.
      return String.fromCharCodes(tip.runes.take(240));
    } on TimeoutException {
      throw const TipException('The tip request timed out. Please retry.');
    } on TipException {
      rethrow;
    } on FormatException {
      throw const TipException('The service returned an invalid tip. Please retry.');
    } catch (_) {
      // Never display raw responses, request details, or exception internals.
      throw const TipException('Could not load a tip. Check your connection and retry.');
    }
  }

  @override
  void close() => _client.close();
}

// No socket is opened. The .invalid address is reserved and intercepted here;
// it is NOT an invented live AI endpoint.
class MockTipClient extends http.BaseClient {
  MockTipClient({
    required this.scenario,
    this.delay = const Duration(milliseconds: 600),
  });
  final MockScenario scenario;
  final Duration delay;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    await Future<void>.delayed(delay);
    if (scenario == MockScenario.offline) {
      throw http.ClientException('Simulated offline');
    }
    if (scenario == MockScenario.timeout) {
      await Future<void>.delayed(const Duration(seconds: 11));
    }
    final body = switch (scenario) {
      MockScenario.malformed => '{not valid json',
      MockScenario.empty => '{"tip":"   "}',
      _ => jsonEncode({
          'tip': 'Use a long, unique passphrase for every account. '
              'A password manager can help you create and remember it. '
              'Never share your password in a signup-tip request.',
        }),
    };
    return http.StreamedResponse(
      Stream.value(utf8.encode(body)),
      scenario == MockScenario.serverError ? 503 : 200,
      headers: {'content-type': 'application/json'},
    );
  }
}

SignupTipService createMockService(MockScenario scenario) =>
    HttpSignupTipService(
      endpoint: Uri.parse('https://mock.invalid/signup-tip'),
      client: MockTipClient(scenario: scenario),
      isMock: true,
    );
