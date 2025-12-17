import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scrap_it_down/services/auth_service.dart';

void main() {
  test('AuthService persists sign-in state', () async {
    SharedPreferences.setMockInitialValues({});

    final s = AuthService.instance;
    await s.init();
    expect(s.signedIn.value, false);

    final res = await s.signInAnonymously();
    expect(res, true);
    expect(s.signedIn.value, true);

    await s.signOut();
    expect(s.signedIn.value, false);
  });
}
