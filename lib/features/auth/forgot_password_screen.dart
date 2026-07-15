import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_input.dart';
import '../../repositories/auth_repository.dart';

/// Forgot Password Screen
///
/// 💡 Mirrors ForgotPasswordPage.tsx: two states —
/// 1. Form state: email input + send button
/// 2. Success state: ✉️ icon + "Check your email!" message
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _repo = AuthRepository();

  bool _isLoading = false;
  bool _isSent = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      await _repo.forgotPassword(_emailController.text.trim());
      if (mounted) {
        // Reset animation for the success state
        _animController.reset();
        setState(() {
          _isSent = true;
          _isLoading = false;
        });
        _animController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                    // ── Logo ──
                    Container(
                      width: 140,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.text.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Image.asset(
                        'assets/images/giftswale.jpg',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Container(
                          decoration: const BoxDecoration(
                            gradient: AppColors.gradientPrimary,
                          ),
                          child: const Icon(
                            Icons.card_giftcard_rounded,
                            size: 24,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  Text('Reset Password', style: AppTextStyles.h1),
                  const SizedBox(height: 32),

                  // ── Card ──
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 440),
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusXl),
                      border: Border.all(color: AppColors.border),
                      boxShadow: AppColors.shadowMd,
                    ),
                    child: _isSent ? _buildSuccessState() : _buildFormState(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Success state — email sent confirmation
  Widget _buildSuccessState() {
    return Column(
      children: [
        const SizedBox(height: 12),
        const Text('✉️', style: TextStyle(fontSize: 56)),
        const SizedBox(height: 16),
        Text(
          'Check your email!',
          style: AppTextStyles.h3,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text.rich(
          TextSpan(
            text: "We've sent a password reset link to ",
            style:
                AppTextStyles.body.copyWith(color: AppColors.textMuted),
            children: [
              TextSpan(
                text: _emailController.text.trim(),
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
              const TextSpan(text: '.\nThe link expires in 1 hour.'),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),
        AppButton(
          label: 'Back to Login',
          onPressed: () => context.go('/login'),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  /// Form state — email input + send button
  Widget _buildFormState() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Enter your registered email address. We\'ll send you a secure link to reset your password.',
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.textMuted,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 20),
          AppInput(
            label: 'Email Address',
            hint: 'you@example.com',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            prefixIcon: const Icon(Icons.email_outlined,
                size: 20, color: AppColors.textMuted),
            validator: Validators.email,
            autofocus: true,
          ),
          const SizedBox(height: 24),
          AppButton(
            label: _isLoading ? 'Sending...' : 'Send Reset Link  →',
            onPressed: _handleSubmit,
            isLoading: _isLoading,
            isFullWidth: true,
          ),
          const SizedBox(height: 16),
          Center(
            child: GestureDetector(
              onTap: () => context.go('/login'),
              child: Text(
                '← Back to Login',
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
