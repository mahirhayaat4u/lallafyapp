import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Terms & Conditions Screen for Lallafy App
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.gavel_rounded, size: 40, color: AppColors.primary),
                  const SizedBox(height: 10),
                  Text(
                    'Lallafy Terms of Service',
                    style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Last updated: July 2026',
                    style: AppTextStyles.bodyXs.copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSection(
              title: '1. Acceptance of Terms',
              content:
                  'By downloading, accessing, or using the Lallafy mobile application or website, you agree to be bound by these Terms & Conditions. If you do not agree with any part of these terms, please do not use our services.',
            ),
            _buildSection(
              title: '2. Product Specifications & Pricing',
              content:
                  'All product descriptions, images, prices, and availability are subject to change without prior notice. Applicable Goods and Services Tax (GST) is calculated and disclosed during checkout based on government norms.',
            ),
            _buildSection(
              title: '3. Orders & Payment Methods',
              content:
                  'We accept online payments via Razorpay (UPI, Cards, NetBanking, Wallets) and Cash on Delivery (COD). Orders are validated upon creation to ensure price accuracy and prevent payment mismatch.',
            ),
            _buildSection(
              title: '4. Shipping & Delivery Policy',
              content:
                  'We ship products across India. Standard delivery timeline is 3–5 business days. FREE shipping is available on qualifying order values as shown in your cart summary.',
            ),
            _buildSection(
              title: '5. Return, Replacement & Cancellation',
              content:
                  'We offer a 7-day hassle-free replacement policy for defective, damaged, or wrong items. Orders can be cancelled anytime before dispatch from the "My Orders" screen.',
            ),
            _buildSection(
              title: '6. User Conduct & Security',
              content:
                  'Users must maintain the confidentiality of their account login details. Any unauthorized or fraudulent activity will result in immediate suspension of account privileges.',
            ),
            _buildSection(
              title: '7. Contact & Grievance',
              content:
                  'For any queries, complaints, or feedback regarding these terms, please reach out to our dedicated support team:\n\n'
                  '📞 Call / WhatsApp: +91 7290900282\n'
                  '✉️ Email: support@lallafy.com',
            ),

            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => _launchUrl('tel:+917290900282'),
                icon: const Icon(Icons.phone_in_talk_rounded, size: 18),
                label: const Text('Contact Support (+91 7290900282)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.bodySm.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.text,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.textMuted,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
