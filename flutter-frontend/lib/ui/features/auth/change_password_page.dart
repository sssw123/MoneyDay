import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../data/services/auth_controller.dart';
import '../../core/widgets.dart';
import 'login_page.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});
  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _form = GlobalKey<FormState>();
  final _old = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    await context.read<AuthController>().changePassword(
      _old.text,
      _password.text,
    );
  }

  @override
  void dispose() {
    _old.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final forced = auth.user?.mustChangePassword ?? false;
    return AuthFrame(
      title: '修改密码',
      subtitle: forced ? '首次登录或密码已被重置，请先设置新密码。' : '修改成功后，所有会话将失效，请重新登录。',
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _old,
              enabled: !auth.busy,
              obscureText: true,
              validator: requiredText,
              decoration: const InputDecoration(labelText: '当前密码'),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _password,
              enabled: !auth.busy,
              obscureText: true,
              validator: (value) => passwordError(value ?? ''),
              decoration: const InputDecoration(
                labelText: '新密码',
                helperText: '至少 8 位，UTF-8 编码不超过 72 字节',
                helperMaxLines: 3,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _confirm,
              enabled: !auth.busy,
              obscureText: true,
              validator: (value) =>
                  value != _password.text ? '两次输入的密码不一致' : null,
              decoration: const InputDecoration(labelText: '确认新密码'),
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
              child: Text(auth.busy ? '正在修改…' : '修改密码并重新登录'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: auth.busy
                  ? null
                  : () {
                      if (forced) {
                        auth.logout();
                      } else {
                        context.go('/settings');
                      }
                    },
              child: Text(forced ? '退出登录' : '返回设置'),
            ),
          ],
        ),
      ),
    );
  }
}

class SessionCheckPage extends StatelessWidget {
  const SessionCheckPage({super.key});
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    return AuthFrame(
      title: '验证登录信息',
      subtitle: '正在向服务器确认账号状态与访问权限。',
      child: Column(
        children: [
          if (auth.checking) const CircularProgressIndicator(),
          if (auth.error != null) ...[
            Text(auth.error!, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: auth.checking ? null : auth.validateProfile,
              child: const Text('重新验证'),
            ),
          ],
          const SizedBox(height: 16),
          TextButton(onPressed: auth.logout, child: const Text('退出登录')),
        ],
      ),
    );
  }
}
