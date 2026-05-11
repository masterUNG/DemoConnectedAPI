import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ms_undraw/ms_undraw.dart';

import '../../app/app_constant.dart';
import '../create_new_account/create_new_account_page.dart';
import '../main_home/main_home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const _indigo = Color(0xFF1A237E);
  static const _deepIndigo = Color(0xFF0D144F);

  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Map<String, String> _createBody() {
    return {
      'username': _usernameController.text.trim(),
      'password': _passwordController.text,
    };
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final response = await Dio().post(
        AppConstant.apiLoginUrl,
        data: _createBody(),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      final data = response.data;
      final accessToken = data is Map ? data['access_token']?.toString() : null;

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300 &&
          accessToken != null &&
          accessToken.isNotEmpty) {
        await GetStorage().write(AppConstant.accessTokenKey, accessToken);
        Get.offAll(() => const MainHomePage());
        Get.snackbar(
          'wellcome',
          'เข้าสู่ระบบสำเร็จ',
          backgroundColor: const Color(0xFFE65100),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      _showErrorSnackbar();
    } catch (_) {
      _showErrorSnackbar();
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _openRegister() {
    Get.to(() => const CreateNewAccountPage());
  }

  void _showErrorSnackbar() {
    Get.snackbar(
      'ลองใหม่',
      'เข้าสู่ระบบไม่สำเร็จ กรุณาลองใหม่',
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_deepIndigo, _indigo, Color(0xFFF7F8FF), Colors.white],
            stops: [0, 0.34, 0.68, 1],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 720;
              final horizontalPadding = isWide ? 48.0 : 24.0;

              return Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    24,
                    horizontalPadding,
                    32,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isWide ? 520 : 430,
                      minHeight: constraints.maxHeight - 56,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _LoginIllustration(isWide: isWide),
                        SizedBox(height: isWide ? 28 : 18),
                        _LoginPanel(
                          formKey: _formKey,
                          usernameController: _usernameController,
                          passwordController: _passwordController,
                          obscurePassword: _obscurePassword,
                          onTogglePassword: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          onSubmit: _submit,
                          onRegister: _openRegister,
                          isSubmitting: _isSubmitting,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LoginIllustration extends StatelessWidget {
  const _LoginIllustration({required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: isWide ? 260 : 210,
          child: UnDraw(
            illustration: UnDrawIllustration.connected_world,
            color: const Color(0xFF7986CB),
            semanticLabel: 'ภาพประกอบโลกที่เชื่อมต่อกัน',
            placeholder: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
            errorWidget: const Icon(
              Icons.public_outlined,
              color: Colors.white,
              size: 96,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Connected API',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'เชื่อมต่อระบบของคุณได้อย่างมั่นใจ',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.82),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _LoginPanel extends StatelessWidget {
  const _LoginPanel({
    required this.formKey,
    required this.usernameController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onTogglePassword,
    required this.onSubmit,
    required this.onRegister,
    required this.isSubmitting,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onSubmit;
  final VoidCallback onRegister;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    const indigo = Color(0xFF1A237E);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 28,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'เข้าสู่ระบบ',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: indigo,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'กรอกข้อมูลบัญชีของคุณเพื่อใช้งานต่อ',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: usernameController,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                decoration: _inputDecoration(
                  label: 'ชื่อผู้ใช้',
                  icon: Icons.account_circle_outlined,
                ),
                validator: (value) {
                  if ((value?.trim() ?? '').isEmpty) {
                    return 'กรุณากรอกชื่อผู้ใช้';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: passwordController,
                obscureText: obscurePassword,
                textInputAction: TextInputAction.done,
                decoration: _inputDecoration(
                  label: 'รหัสผ่าน',
                  icon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    tooltip: obscurePassword ? 'แสดงรหัสผ่าน' : 'ซ่อนรหัสผ่าน',
                    onPressed: onTogglePassword,
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
                validator: (value) {
                  final password = value ?? '';
                  if (password.isEmpty) {
                    return 'กรุณากรอกรหัสผ่าน';
                  }
                  if (password.length < 6) {
                    return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => onSubmit(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                child: FilledButton.icon(
                  onPressed: isSubmitting ? null : onSubmit,
                  icon: isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.login_outlined),
                  label: Text(
                    isSubmitting ? 'กำลังเข้าสู่ระบบ...' : 'เข้าสู่ระบบ',
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: indigo,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: onRegister,
                icon: const Icon(Icons.person_add_alt_1_outlined),
                label: const Text('สมัครสมาชิก'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: indigo,
                  side: const BorderSide(color: indigo),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    const indigo = Color(0xFF1A237E);

    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF8F9FF),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: indigo, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }
}
