import 'package:flutter/material.dart';
import '../services/api_client.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? _error;
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _checkBackend();
  }

  Future<void> _checkBackend() async {
    setState(() {
      _checking = true;
      _error = null;
    });
    try {
      final res = await AppServices.I.api.health();
      if (mounted) {
        if (res['status'] == 'ok') {
          await Future.delayed(const Duration(milliseconds: 300));
          final authed = context.read<AuthProvider>().isAuthenticated;
          context.go(authed ? '/home' : '/login');
        } else {
          setState(() => _error = '后端健康检查失败: ${res.toString()}');
        }
      }
    } catch (e) {
      if (mounted) setState(() => _error = '无法连接后端: $e');
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const FlutterLogo(size: 64),
              const SizedBox(height: 16),
              if (_checking) const CircularProgressIndicator(),
              if (!_checking && _error == null) const Text('健康检查通过，正在进入...'),
              if (_error != null) ...[
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _checkBackend,
                  child: const Text('重试'),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
