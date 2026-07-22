import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';

/// Why Trust Lallafy Section — mirrors "Why Trust Lallafy?" from Home.jsx
class WhyTrustLallafySection extends StatelessWidget {
  const WhyTrustLallafySection({super.key});

  static const List<_FeatureItem> _features = [
    _FeatureItem(
      icon: Icons.verified_user_rounded,
      title: 'Premium Quality',
      desc: 'Curated to meet the highest safety and playtime standards for kids.',
    ),
    _FeatureItem(
      icon: Icons.extension_rounded,
      title: 'Huge Selection',
      desc: 'Explore hundreds of safe, fun, and educational toys for kids of all ages.',
    ),
    _FeatureItem(
      icon: Icons.local_shipping_rounded,
      title: 'Fast Delivery',
      desc: 'Quick and reliable door-to-door delivery right to your doorstep across India.',
    ),
    _FeatureItem(
      icon: Icons.support_agent_rounded,
      title: 'Friendly Support',
      desc: 'Our dedicated customer service team is always here to help you.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        children: [
          // Header
          Text(
            'Why Trust Lallafy?',
            style: AppTextStyles.h2.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: const Color(0xFFFF448C),
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Delivering Happiness with Premium Quality, Safe, & Fun Toys for Kids',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // 2x2 Grid of Feature Cards
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _features.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.95,
            ),
            itemBuilder: (context, index) {
              final item = _features[index];
              return _buildFeatureCard(item);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(_FeatureItem item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              item.icon,
              size: 22,
              color: const Color(0xFF1A1C23),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            item.title,
            style: const TextStyle(
              fontFamily: 'Outfit',
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1C23),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              item.desc,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 11,
                fontWeight: FontWeight.w400,
                height: 1.3,
                color: Colors.grey.shade500,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem {
  final IconData icon;
  final String title;
  final String desc;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.desc,
  });
}
