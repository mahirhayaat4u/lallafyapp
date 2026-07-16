import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';

/// Redesigned Login Screen
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPassword = false;
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
    _emailController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    ref.read(authProvider.notifier).clearError();

    try {
      await ref.read(authProvider.notifier).login(
            _emailController.text.trim(),
            _passwordController.text,
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Welcome back! 🎉'),
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

    return Scaffold(
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
                        
                        // Lallafy Logo with soft glow
                        Container(
                          height: 75,
                          width: 170,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFFFD1DC), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF448C).withOpacity(0.08),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                        
                        const SizedBox(height: 20),
                        
                        // Welcome text with spark
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Welcome Back',
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              '✨',
                              style: TextStyle(fontSize: 22),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 6),
                        
                        const Text(
                          'Sign in to explore toys, gifts &\nmagical learning creations',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                            height: 1.4,
                          ),
                        ),
                        
                        const SizedBox(height: 32),

                        // Form Card
                        Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(maxWidth: 440),
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
                                // Email Address
                                _CustomFormInput(
                                  label: 'Email Address',
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
                                  label: 'Password',
                                  hint: 'Your password',
                                  controller: _passwordController,
                                  obscureText: !_showPassword,
                                  textInputAction: TextInputAction.done,
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
                                
                                const SizedBox(height: 10),

                                // Forgot password link
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: GestureDetector(
                                    onTap: () => context.push('/forgot-password'),
                                    child: const Text(
                                      'Forgot password?',
                                      style: TextStyle(
                                        fontFamily: 'Outfit',
                                        fontSize: 13,
                                        color: Color(0xFFEF476F),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(height: 24),

                                // Sign In button
                                _CustomButton(
                                  label: authState.isLoading
                                      ? 'Signing in...'
                                      : 'Sign In',
                                  onPressed: _handleLogin,
                                  isLoading: authState.isLoading,
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 32),

                        // Create account link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account? ",
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 14,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => context.push('/register'),
                              child: const Text(
                                'Create one →',
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

                        // Features Row at bottom
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
    );
  }

  Widget _buildSocialButton({required Widget child, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
        ),
        child: Center(
          child: child,
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
          cursorColor: const Color(0xFFFF448C),
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
                  color: const Color(0xFFFFF0F5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  prefixIcon,
                  color: const Color(0xFFFF448C),
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
              borderSide: const BorderSide(color: Color(0xFFFF448C), width: 1.5),
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
            Color(0xFFFF448C),
            Color(0xFFFF5284),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF448C).withOpacity(0.3),
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

// ─── Programmatic Brand Icons ─────────────────────────────────────
class _GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double r = w / 2;
    
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.22
      ..strokeCap = StrokeCap.butt;

    final center = Offset(r, r);
    final double sweepRadius = r - (paint.strokeWidth / 2);

    // Red Arc
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: sweepRadius),
      -2.4,
      1.7,
      false,
      paint,
    );

    // Yellow Arc
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: sweepRadius),
      -4.1,
      1.7,
      false,
      paint,
    );

    // Green Arc
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: sweepRadius),
      0.9,
      1.8,
      false,
      paint,
    );

    // Blue Arc
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: sweepRadius),
      -0.7,
      1.6,
      false,
      paint,
    );

    // Blue Horizontal Bar
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    
    canvas.drawRect(
      Rect.fromLTRB(r, r - (paint.strokeWidth / 2), w - 2, r + (paint.strokeWidth / 2)),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FacebookIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1877F2)
      ..style = PaintingStyle.fill;
    
    final double w = size.width;
    final double h = size.height;

    canvas.drawCircle(Offset(w / 2, h / 2), w / 2, paint);

    final textPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    final path = Path();
    path.moveTo(w * 0.65, h);
    path.lineTo(w * 0.65, h * 0.55);
    path.lineTo(w * 0.78, h * 0.55);
    path.lineTo(w * 0.80, h * 0.40);
    path.lineTo(w * 0.65, h * 0.40);
    path.lineTo(w * 0.65, h * 0.30);
    path.cubicTo(w * 0.65, h * 0.20, w * 0.70, h * 0.18, w * 0.78, h * 0.18);
    path.lineTo(w * 0.82, h * 0.18);
    path.lineTo(w * 0.82, h * 0.02);
    path.lineTo(w * 0.70, h * 0.02);
    path.cubicTo(w * 0.52, h * 0.02, w * 0.48, h * 0.15, w * 0.48, h * 0.28);
    path.lineTo(w * 0.48, h * 0.40);
    path.lineTo(w * 0.38, h * 0.40);
    path.lineTo(w * 0.38, h * 0.55);
    path.lineTo(w * 0.48, h * 0.55);
    path.lineTo(w * 0.48, h);
    path.close();

    canvas.drawPath(path, textPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
