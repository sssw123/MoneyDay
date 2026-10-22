import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../data/repositories/moneyday_repository.dart';
import '../../data/services/api_client.dart';
import 'feature_view_model.dart';

String money(num? value) => NumberFormat.currency(
  locale: 'zh_CN',
  symbol: '¥',
  decimalDigits: 2,
).format(value ?? 0);
String dateOnly(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
String? requiredText(String? value) =>
    value == null || value.trim().isEmpty ? '请填写此项' : null;
String? positiveAmount(String? value) {
  final text = value?.trim() ?? '';
  final parsed = num.tryParse(text);
  if (parsed == null || !parsed.isFinite || parsed <= 0) {
    return '请输入大于 0 的金额';
  }
  return RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(text)
      ? null
      : '金额最多保留两位小数，请使用普通十进制格式';
}

num parseAmount(String value) => num.parse(value.trim());
String? passwordError(String value) =>
    value.runes.length < 8 || utf8.encode(value).length > 72
    ? '密码至少 8 位，UTF-8 编码不超过 72 字节'
    : null;

class AsyncPage extends StatelessWidget {
  const AsyncPage({super.key, required this.model, required this.child});
  final FeatureViewModel model;
  final Widget child;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: model,
    builder: (context, _) {
      if (!model.repository.authenticated) return const SizedBox.shrink();
      return Column(
        children: [
          if (model.loading || model.saving) const LinearProgressIndicator(),
          if (model.error != null)
            Material(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline),
                    const SizedBox(width: 12),
                    Expanded(child: Text(model.error!)),
                    TextButton(
                      onPressed: model.loading ? null : model.load,
                      child: const Text('刷新'),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(child: child),
        ],
      );
    },
  );
}

class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
  });
  final String title;
  final String? subtitle;
  final List<Widget> actions;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 24),
    child: LayoutBuilder(
      builder: (context, constraints) => Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 12,
        children: [
          SizedBox(
            width: constraints.maxWidth < 600 ? constraints.maxWidth : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.headlineMedium),
                if (subtitle != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
          Wrap(spacing: 8, runSpacing: 8, children: actions),
        ],
      ),
    ),
  );
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, this.message = '暂无数据'});
  final String message;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(32),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 42,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(message),
        ],
      ),
    ),
  );
}

Future<bool> confirmAction(
  BuildContext context,
  String title,
  String message, {
  bool destructive = false,
}) async {
  final repository = Provider.of<MoneydayRepository?>(context, listen: false);
  final generation = repository?.sessionGeneration;
  final result =
      await showDialog<bool>(
        context: context,
        builder: (context) => _SessionBoundDialog(
          repository: repository,
          generation: generation,
          child: AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('取消'),
              ),
              FilledButton(
                style: destructive
                    ? FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                      )
                    : null,
                onPressed: () => Navigator.pop(context, true),
                child: const Text('确认'),
              ),
            ],
          ),
        ),
      ) ??
      false;
  return result &&
      (repository == null ||
          (repository.authenticated &&
              repository.sessionGeneration == generation));
}

Future<bool> showFormDialog(
  BuildContext context, {
  required String title,
  required Widget Function(BuildContext, void Function(VoidCallback)) builder,
  required Future<void> Function() onSubmit,
  String? description,
}) async {
  final repository = Provider.of<MoneydayRepository?>(context, listen: false);
  final generation = repository?.sessionGeneration;
  final navigator = Navigator.of(context, rootNavigator: true);
  final route = DialogRoute<bool>(
    context: context,
    barrierDismissible: false,
    themes: InheritedTheme.capture(from: context, to: navigator.context),
    builder: (context) => _SessionBoundDialog(
      repository: repository,
      generation: generation,
      child: _FormDialog(
        title: title,
        contentBuilder: builder,
        description: description,
        onSubmit: () async {
          if (repository != null &&
              (!repository.authenticated ||
                  repository.sessionGeneration != generation)) {
            throw const StaleSessionException();
          }
          if (generation == null) {
            await onSubmit();
          } else {
            await ApiClient.inSession(generation, onSubmit);
          }
        },
      ),
    ),
  );
  final result = await navigator.push<bool>(route);
  // Callers own form controllers; wait until exit animation releases text fields.
  await route.completed;
  return result ?? false;
}

/// Root-navigator dialogs must not outlive the account that opened them.
class _SessionBoundDialog extends StatefulWidget {
  const _SessionBoundDialog({
    required this.repository,
    required this.generation,
    required this.child,
  });
  final MoneydayRepository? repository;
  final int? generation;
  final Widget child;
  @override
  State<_SessionBoundDialog> createState() => _SessionBoundDialogState();
}

class _SessionBoundDialogState extends State<_SessionBoundDialog> {
  @override
  void initState() {
    super.initState();
    widget.repository?.addListener(_changed);
  }

  void _changed() {
    if (widget.repository?.sessionGeneration == widget.generation) return;
    scheduleMicrotask(() {
      if (!mounted) return;
      final route = ModalRoute.of(context);
      if (route != null && route.isActive) {
        Navigator.of(context).removeRoute(route);
      }
    });
  }

  @override
  void dispose() {
    widget.repository?.removeListener(_changed);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _FormDialog extends StatefulWidget {
  const _FormDialog({
    required this.title,
    required this.contentBuilder,
    required this.onSubmit,
    this.description,
  });
  final String title;
  final Widget Function(BuildContext, void Function(VoidCallback))
  contentBuilder;
  final Future<void> Function() onSubmit;
  final String? description;
  @override
  State<_FormDialog> createState() => _FormDialogState();
}

class _FormDialogState extends State<_FormDialog> {
  final _form = GlobalKey<FormState>();
  bool _busy = false;
  bool _closing = false;
  String? _error;
  Future<void> _submit() async {
    if (_busy || !_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.onSubmit();
      if (mounted) {
        _closing = true;
        Navigator.pop(context, true);
      }
    } on StaleSessionException {
      if (mounted) {
        _closing = true;
        final route = ModalRoute.of(context);
        if (route != null && route.isActive) {
          Navigator.of(context).removeRoute(route);
        }
      }
    } catch (exception) {
      if (mounted) {
        setState(() {
          _error = exception is ApiException
              ? exception.message
              : exception.toString();
        });
      }
    } finally {
      if (mounted && !_closing) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_busy,
    child: AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Form(
            key: _form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.description != null) ...[
                  Text(widget.description!),
                  const SizedBox(height: 16),
                ],
                AbsorbPointer(
                  absorbing: _busy,
                  child: widget.contentBuilder(context, setState),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                if (_busy) ...[
                  const SizedBox(height: 12),
                  const LinearProgressIndicator(),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.pop(context, false),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: _busy ? null : _submit,
          child: const Text('保存'),
        ),
      ],
    ),
  );
}
