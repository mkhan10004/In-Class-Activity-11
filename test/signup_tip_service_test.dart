import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:signup_app/services/signup_tip_service.dart';

void main() {
  final endpoint = Uri.parse('https://course.invalid/tip');

  test('POST contains only fixed non-sensitive fields and trims output', () async {
    final service = HttpSignupTipService(endpoint: endpoint,
      client: MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url, endpoint);
        expect(request.headers['Content-Type'], contains('application/json'));
        expect(request.followRedirects, isFalse);
        expect(jsonDecode(request.body), {
          'task': 'signup_tip', 'topic': 'password_help',
        });
        expect(request.headers.containsKey('Authorization'), isFalse);
        return http.Response('{"tip":"  A helpful tip.  "}', 200);
      }));
    addTearDown(service.close);
    expect(await service.getTip(), 'A helpful tip.');
  });

  test('output is limited to 240 Unicode code points', () async {
    final service = HttpSignupTipService(endpoint: endpoint,
      client: MockClient((_) async => http.Response(
        jsonEncode({'tip': List.filled(300, 'x').join()}), 200)));
    addTearDown(service.close);
    expect((await service.getTip()).runes.length, 240);
  });

  for (final body in ['invalid json', '{}', '[]', '{"tip":null}',
    '{"tip":42}', '{"tip":""}', '{"tip":"   "}']) {
    test('rejects malformed or empty tip: $body', () async {
      final service = HttpSignupTipService(endpoint: endpoint,
        client: MockClient((_) async => http.Response(body, 200)));
      addTearDown(service.close);
      await expectLater(service.getTip(), throwsA(isA<TipException>()));
    });
  }

  test('non-200 response is rejected', () async {
    final service = HttpSignupTipService(endpoint: endpoint,
      client: MockClient((_) async => http.Response('{"tip":"Ignored"}', 503)));
    addTearDown(service.close);
    await expectLater(service.getTip(), throwsA(isA<TipException>()));
  });

  test('offline failure can be retried successfully', () async {
    var attempts = 0;
    final service = HttpSignupTipService(endpoint: endpoint,
      client: MockClient((_) async {
        if (attempts++ == 0) throw http.ClientException('offline');
        return http.Response('{"tip":"Try a unique passphrase."}', 200);
      }));
    addTearDown(service.close);
    await expectLater(service.getTip(), throwsA(isA<TipException>()));
    expect(await service.getTip(), 'Try a unique passphrase.');
  });

  test('deadline produces a friendly timeout', () async {
    final pending = Completer<http.Response>();
    final service = HttpSignupTipService(endpoint: endpoint,
      timeout: const Duration(milliseconds: 5),
      client: MockClient((_) => pending.future));
    addTearDown(service.close);
    await expectLater(service.getTip(), throwsA(isA<TipException>().having(
      (e) => e.message, 'message', contains('timed out'))));
    pending.complete(http.Response('{"tip":"Late"}', 200));
  });

  test('insecure URL is rejected', () {
    expect(() => HttpSignupTipService(endpoint: Uri.parse('http://course.invalid')),
      throwsArgumentError);
  });
}
