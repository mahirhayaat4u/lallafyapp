import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  // Static FAQ list matching common e-commerce toys/gifts issues
  final List<_FaqItem> _faqs = [
    _FaqItem(
      question: 'What are the delivery charges and timelines?',
      answer: 'We offer FREE delivery on all orders above ₹999. For orders below ₹999, a nominal shipping fee of ₹99 is applicable. Standard delivery takes 3–5 business days depending on your location.',
    ),
    _FaqItem(
      question: 'How do I track my order?',
      answer: 'Once your order is shipped, you will receive a tracking link via SMS. You can also view real-time status updates under the "My Orders" section in your Profile tab.',
    ),
    _FaqItem(
      question: 'What is your return & replacement policy?',
      answer: 'We offer a 7-day replacement policy for damaged, defective, or incorrect toy items. Please ensure the toy remains unused and in its original packaging with all tags intact.',
    ),
    _FaqItem(
      question: 'How does Cash on Delivery (COD) work?',
      answer: 'You can pay using Cash or UPI directly to the delivery agent when your order arrives. Please keep exact change or your UPI app ready for a seamless delivery process.',
    ),
    _FaqItem(
      question: 'Can I cancel my order?',
      answer: 'Yes, you can cancel your order anytime before it is dispatched. Simply go to "My Orders", open the order details, and tap the Cancel button.',
    ),
    _FaqItem(
      question: 'Are Lallafy toys safe for infants?',
      answer: 'Absolutely! All our toys are non-toxic, BIS-certified, and pass strict quality check standards to ensure 100% safety for infants and children of all age groups.',
    ),
  ];

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      // Fail silently
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Support & FAQ'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top Banner: Customer Care Welcome ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.support_agent_rounded,
                      color: Colors.white,
                      size: 38,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'How can we help you today?',
                    style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Our Lallafy support team is available 10 AM – 7 PM',
                    style: AppTextStyles.bodyXs.copyWith(color: AppColors.textMuted),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // ── 1. Contact Options Panel ──
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contact Channels',
                    style: AppTextStyles.bodySm.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // WhatsApp Option
                      Expanded(
                        child: _contactCard(
                          icon: Icons.chat_bubble_outline_rounded,
                          label: 'WhatsApp',
                          color: const Color(0xFF25D366),
                          onTap: () => _launchUrl('https://wa.me/919876543210?text=Hi%20Lallafy%20Support!'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Call Option
                      Expanded(
                        child: _contactCard(
                          icon: Icons.phone_in_talk_outlined,
                          label: 'Call Support',
                          color: AppColors.primary,
                          onTap: () => _launchUrl('tel:+919876543210'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Email Option
                  _contactCard(
                    icon: Icons.mail_outline_rounded,
                    label: 'Email support@lallafy.com',
                    color: AppColors.textMuted,
                    isFullWidth: true,
                    onTap: () => _launchUrl('mailto:support@lallafy.com?subject=Lallafy%20Order%20Help'),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // ── 2. FAQ Accordion Section ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Frequently Asked Questions',
                    style: AppTextStyles.bodySm.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _faqs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      return _buildFaqTile(_faqs[index]);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contactCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool isFullWidth = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x05000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: isFullWidth ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: AppTextStyles.bodySm.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqTile(_FaqItem faq) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        title: Text(
          faq.question,
          style: AppTextStyles.bodySm.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
        collapsedTextColor: AppColors.text,
        textColor: AppColors.primary,
        iconColor: AppColors.primary,
        collapsedIconColor: AppColors.textMuted,
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            faq.answer,
            style: AppTextStyles.bodyXs.copyWith(
              color: AppColors.textMuted,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqItem {
  final String question;
  final String answer;

  _FaqItem({required this.question, required this.answer});
}
