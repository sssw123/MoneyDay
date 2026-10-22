import 'package:flutter/material.dart';
import 'app/moneyday_app.dart';
import 'app/url_strategy.dart';
import 'data/repositories/moneyday_repository.dart';
import 'data/services/api_client.dart';
import 'data/services/auth_controller.dart';
import 'data/services/session_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureUrlStrategy();
  try {
    final session = SessionController();
    final api = ApiClient(session: session);
    final auth = AuthController(api: api, session: session);
    runApp(
      MoneydayApp(
        auth: auth,
        repository: MoneydayRepository(api: api),
      ),
    );
  } on ApiException catch (error) {
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SelectableText(
                '${error.message}\n\n启动示例：\nflutter run --dart-define=API_BASE_URL=https://your-server.example/api',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
