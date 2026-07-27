import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';

/// Redesigned Register Screen
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _referralCodeController = TextEditingController();

  bool _showPassword = false;
  bool _showConfirm = false;
  bool _agreedToTerms = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _referralCodeController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Terms & Privacy Policy'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    ref.read(authProvider.notifier).clearError();

    try {
      await ref.read(authProvider.notifier).register(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            referralCode: _referralCodeController.text.trim(),
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created! Welcome to Lallafy 🎉'),
          backgroundColor: AppColors.success,
        ),
      );

      context.go('/home');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        context.go('/home');
      },
      child: Scaffold(
        body: Stack(
        children: [
          // ── Background Glows & Gradients ──
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFFF0F2), // Very soft pink top
                  Color(0xFFFFFFFF), // White middle
                  Color(0xFFFFF0F2), // Soft pink bottom
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Decorative top-left circle glow
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFD1DC).withOpacity(0.3),
              ),
            ),
          ),

          // Decorative bottom-right circle glow
          Positioned(
            bottom: -150,
            right: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFD1DC).withOpacity(0.25),
              ),
            ),
          ),

          // Scattered Hearts & Confetti
          Positioned.fill(
            child: CustomPaint(
              painter: _BackgroundDecorator(),
            ),
          ),

          // ── Content ──
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 10),

                        // Logo with soft border and rounded corners
                        Container(
                          height: 80,
                          width: 140,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFFFD1DC), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFBC3B5D).withOpacity(0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Image.asset(
                            'assets/images/lallafy.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => const Text(
                              'Lallafy',
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFFF448C),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Title with outline star/sparkle
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Create Account',
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFBC3B5D),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Transform.rotate(
                              angle: 0.1,
                              child: const Icon(
                                Icons.star_border_rounded,
                                color: Color(0xFFEF476F),
                                size: 28,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          'Join Lallafy today to find the perfect toys & gifts',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Form Card
                        Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(maxWidth: 460),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 24,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Full Name
                                _CustomFormInput(
                                  label: 'Full Name *',
                                  hint: 'Your name',
                                  controller: _nameController,
                                  textInputAction: TextInputAction.next,
                                  prefixIcon: Icons.person_outline_rounded,
                                  validator: Validators.name,
                                ),

                                const SizedBox(height: 20),

                                // Phone Number
                                _CustomFormInput(
                                  label: 'Phone Number *',
                                  hint: '10-digit mobile number',
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  textInputAction: TextInputAction.next,
                                  prefixIcon: Icons.phone_outlined,
                                  validator: Validators.phone,
                                ),

                                const SizedBox(height: 20),

                                // Email Address
                                _CustomFormInput(
                                  label: 'Email Address *',
                                  hint: 'you@example.com',
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  prefixIcon: Icons.email_outlined,
                                  validator: Validators.email,
                                ),

                                const SizedBox(height: 20),

                                // Password
                                _CustomFormInput(
                                  label: 'Password *',
                                  hint: 'Min 6 characters',
                                  controller: _passwordController,
                                  obscureText: !_showPassword,
                                  textInputAction: TextInputAction.next,
                                  prefixIcon: Icons.lock_outline_rounded,
                                  validator: Validators.password,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _showPassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      size: 20,
                                      color: const Color(0xFF94A3B8),
                                    ),
                                    onPressed: () => setState(
                                        () => _showPassword = !_showPassword),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // Confirm Password
                                _CustomFormInput(
                                  label: 'Confirm Password *',
                                  hint: 'Repeat your password',
                                  controller: _confirmController,
                                  obscureText: !_showConfirm,
                                  textInputAction: TextInputAction.done,
                                  prefixIcon: Icons.lock_outline_rounded,
                                  validator: Validators.confirmPassword(
                                      _passwordController.text),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _showConfirm
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      size: 20,
                                      color: const Color(0xFF94A3B8),
                                    ),
                                    onPressed: () => setState(
                                        () => _showConfirm = !_showConfirm),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // Referral Code (Optional)
                                _CustomFormInput(
                                  label: 'Referral Code (Optional)',
                                  hint: 'Enter referral code',
                                  controller: _referralCodeController,
                                  textInputAction: TextInputAction.done,
                                  prefixIcon: Icons.card_giftcard_rounded,
                                  textCapitalization: TextCapitalization.characters,
                                ),

                                const SizedBox(height: 24),

                                // Terms & Conditions Checkbox
                                GestureDetector(
                                  onTap: () => setState(
                                      () => _agreedToTerms = !_agreedToTerms),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: Checkbox(
                                          value: _agreedToTerms,
                                          onChanged: (v) => setState(
                                              () => _agreedToTerms = v ?? false),
                                          activeColor: const Color(0xFFFF448C),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          side: BorderSide(
                                            color: Colors.grey.shade300,
                                            width: 1.5,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text.rich(
                                          TextSpan(
                                            text: "I agree to Lallafy's ",
                                            style: const TextStyle(
                                              fontFamily: 'Outfit',
                                              fontSize: 13,
                                              color: Color(0xFF64748B),
                                              height: 1.3,
                                            ),
                                            children: [
                                              const TextSpan(
                                                text: 'Terms of Service',
                                                style: TextStyle(
                                                  color: Color(0xFFFF448C),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const TextSpan(text: ' and '),
                                              const TextSpan(
                                                text: 'Privacy Policy',
                                                style: TextStyle(
                                                  color: Color(0xFFFF448C),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 28),

                                // Register Button
                                _CustomButton(
                                  label: authState.isLoading
                                      ? 'Creating account...'
                                      : 'Create Account',
                                  onPressed: _handleRegister,
                                  isLoading: authState.isLoading,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Login Screen Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Already have an account? ',
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 14,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => context.push('/login'),
                              child: const Text(
                                'Sign in →',
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 14,
                                  color: Color(0xFFEF476F),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 48),

                        // Bottom Features Row
                        _buildFeaturesRow(),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
   );
  }

  Widget _buildFeaturesRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildFeatureItem(
          icon: Icons.lock_outline_rounded,
          title: 'Secure',
          subtitle: 'Shopping',
        ),
        Container(
          height: 24,
          width: 1,
          color: const Color(0xFFE2E8F0),
        ),
        _buildFeatureItem(
          icon: Icons.verified_outlined,
          title: 'Quality',
          subtitle: 'Products',
        ),
        Container(
          height: 24,
          width: 1,
          color: const Color(0xFFE2E8F0),
        ),
        _buildFeatureItem(
          icon: Icons.local_shipping_outlined,
          title: 'Fast & Safe',
          subtitle: 'Delivery',
        ),
      ],
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: const Color(0xFFEF476F),
          size: 22,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5E5E6A),
                height: 1.1,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Color(0xFF94A3B8),
                height: 1.1,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Custom Locally-Styled Inputs ──────────────────────────────────
class _CustomFormInput extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final IconData prefixIcon;
  final FormFieldValidator<String>? validator;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;

  const _CustomFormInput({
    required this.label,
    required this.hint,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    required this.prefixIcon,
    this.validator,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Outfit',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF5E5E6A),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          textInputAction: textInputAction,
          textCapitalization: textCapitalization,
          cursorColor: const Color(0xFFEF476F),
          style: const TextStyle(
            fontFamily: 'Outfit',
            fontSize: 15,
            color: Color(0xFF0F172A),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 15,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  prefixIcon,
                  color: const Color(0xFFEF476F),
                  size: 20,
                ),
              ),
            ),
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFFFD1DC), width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFFFD1DC), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFEF476F), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Custom Locally-Styled Button ──────────────────────────────────
class _CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;

  const _CustomButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFBC3B5D),
            Color(0xFFC13B5E),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFBC3B5D).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ],
              ),
      ),
    );
  }
}

// ─── Decorative Background Painter ────────────────────────────────
class _BackgroundDecorator extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFD1DC).withOpacity(0.4)
      ..style = PaintingStyle.fill;

    // Soft Hearts
    _drawHeart(canvas, const Offset(60, 120), 25, paint);
    _drawHeart(canvas, Offset(size.width - 80, 200), 22, paint);
    _drawHeart(canvas, Offset(50, size.height - 240), 24, paint);
    _drawHeart(canvas, Offset(size.width - 80, size.height - 180), 30, paint);

    // Soft Gold Confetti
    final confettiPaint = Paint()
      ..color = const Color(0xFFFCD34D).withOpacity(0.5)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(const Offset(40, 280), 4, confettiPaint);
    canvas.drawCircle(Offset(size.width - 50, 100), 6, confettiPaint);
    canvas.drawCircle(Offset(size.width / 2 - 120, size.height - 350), 5, confettiPaint);
    canvas.drawCircle(Offset(90, size.height - 120), 4, confettiPaint);
  }

  void _drawHeart(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    final double width = size;
    final double height = size;

    path.moveTo(center.dx, center.dy + height * 0.25);
    path.cubicTo(
      center.dx - width * 0.5, center.dy - height * 0.25,
      center.dx - width * 0.5, center.dy + height * 0.75,
      center.dx, center.dy + height * 0.9,
    );
    path.cubicTo(
      center.dx + width * 0.5, center.dy + height * 0.75,
      center.dx + width * 0.5, center.dy - height * 0.25,
      center.dx, center.dy + height * 0.25,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
