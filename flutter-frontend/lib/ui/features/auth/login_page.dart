import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/services/auth_controller.dart';
import '../../core/widgets.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _form = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _visible = false;
  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    await context.read<AuthController>().login(_username.text, _password.text);
  }

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    return AuthFrame(
      title: '欢迎回到 MoneyDay',
      subtitle: '登录云端账本，在每一端管理你的收支与计划。',
      child: Form(
        key: _form,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _username,
                enabled: !auth.busy,
                decoration: const InputDecoration(
                  labelText: '用户名',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: requiredText,
                autofillHints: const [AutofillHints.username],
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _password,
                enabled: !auth.busy,
                obscureText: !_visible,
                decoration: InputDecoration(
                  labelText: '密码',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    tooltip: _visible ? '隐藏密码' : '显示密码',
                    onPressed: () => setState(() => _visible = !_visible),
                    icon: Icon(
                      _visible
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                  ),
                ),
                validator: requiredText,
                autofillHints: const [AutofillHints.password],
                onFieldSubmitted: (_) {
                  if (!auth.busy) _submit();
                },
              ),
              if (auth.error != null) ...[
                const SizedBox(height: 16),
                Text(
                  auth.error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: auth.busy ? null : _submit,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(auth.busy ? '正在登录…' : '登录'),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '账号由管理员创建。忘记密码时请联系管理员重置。',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthFrame extends StatelessWidget {
  const AuthFrame({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });
  final String title;
  final String subtitle;
  final Widget child;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.savings_outlined,
                  size: 60,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(subtitle, textAlign: TextAlign.center),
                const SizedBox(height: 32),
                child,
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
