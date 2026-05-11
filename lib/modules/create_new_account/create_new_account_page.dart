import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ms_undraw/ms_undraw.dart';

import '../../app/app_constant.dart';

class CreateNewAccountPage extends StatefulWidget {
  const CreateNewAccountPage({super.key});

  @override
  State<CreateNewAccountPage> createState() => _CreateNewAccountPageState();
}

class _CreateNewAccountPageState extends State<CreateNewAccountPage> {
  static const _indigo = Color(0xFF1A237E);
  static const _deepIndigo = Color(0xFF0D144F);

  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  bool _obscurePassword = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  Map<String, String> _createBody() {
    return {
      'username': _usernameController.text.trim(),
      'email': _emailController.text.trim(),
      'password': _passwordController.text,
      'full_name': _fullNameController.text.trim(),
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
        AppConstant.apiRegisterUrl,
        data: _createBody(),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        Get.back();
        Get.snackbar(
          'สำเร็จ',
          'สมัครสมาชิกสำเร็จ',
          backgroundColor: Colors.orange,
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

  void _showErrorSnackbar() {
    Get.snackbar(
      'ลองใหม่',
      'สมัครสมาชิกไม่สำเร็จ กรุณาลองใหม่',
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
                    16,
                    horizontalPadding,
                    32,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isWide ? 520 : 430,
                      minHeight: constraints.maxHeight - 48,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton.filledTonal(
                            tooltip: 'กลับ',
                            onPressed: Get.back,
                            icon: const Icon(Icons.arrow_back),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.92,
                              ),
                              foregroundColor: _indigo,
                            ),
                          ),
                        ),
                        SizedBox(height: isWide ? 18 : 10),
                        _RegisterIllustration(isWide: isWide),
                        SizedBox(height: isWide ? 24 : 16),
                        _RegisterPanel(
                          formKey: _formKey,
                          usernameController: _usernameController,
                          emailController: _emailController,
                          passwordController: _passwordController,
                          fullNameController: _fullNameController,
                          obscurePassword: _obscurePassword,
                          onTogglePassword: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          onSubmit: _submit,
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

class _RegisterIllustration extends StatelessWidget {
  const _RegisterIllustration({required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: isWide ? 220 : 170,
          child: UnDraw(
            illustration: UnDrawIllustration.sign_up,
            color: const Color(0xFF7986CB),
            semanticLabel: 'ภาพประกอบสมัครสมาชิก',
            placeholder: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
            errorWidget: const Icon(
              Icons.person_add_alt_1_outlined,
              color: Colors.white,
              size: 88,
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
          'สร้างบัญชีเพื่อเริ่มเชื่อมต่อระบบของคุณ',
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

class _RegisterPanel extends StatelessWidget {
  const _RegisterPanel({
    required this.formKey,
    required this.usernameController,
    required this.emailController,
    required this.passwordController,
    required this.fullNameController,
    required this.obscurePassword,
    required this.onTogglePassword,
    required this.onSubmit,
    required this.isSubmitting,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController fullNameController;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onSubmit;
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
                'สมัครสมาชิก',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: indigo,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'กรอกข้อมูลสำหรับสร้างบัญชีใหม่',
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
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: _inputDecoration(
                  label: 'อีเมล',
                  icon: Icons.email_outlined,
                ),
                validator: (value) {
                  final email = value?.trim() ?? '';
                  if (email.isEmpty) {
                    return 'กรุณากรอกอีเมล';
                  }
                  if (!email.contains('@')) {
                    return 'กรุณากรอกอีเมลให้ถูกต้อง';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: passwordController,
                obscureText: obscurePassword,
                textInputAction: TextInputAction.next,
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
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: fullNameController,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.done,
                decoration: _inputDecoration(
                  label: 'ชื่อ-นามสกุล',
                  icon: Icons.badge_outlined,
                ),
                validator: (value) {
                  if ((value?.trim() ?? '').isEmpty) {
                    return 'กรุณากรอกชื่อ-นามสกุล';
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
                      : const Icon(Icons.person_add_alt_1_outlined),
                  label: Text(isSubmitting ? 'กำลังสมัคร...' : 'สมัครสมาชิก'),
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
