import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/network/dio_client.dart';
import '../../core/utils/formatters.dart';

class ReferralScreen extends ConsumerStatefulWidget {
  const ReferralScreen({super.key});

  @override
  ConsumerState<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends ConsumerState<ReferralScreen> {
  bool _loading = true;
  int _supercoins = 0;
  String _referralCode = '';
  int _referralsCount = 0;
  Map<String, dynamic>? _loyaltySettings;
  List<dynamic> _history = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        DioClient().get('/loyalty/balance'),
        DioClient().get('/loyalty/settings'),
        DioClient().get('/loyalty/history'),
      ]);

      final balanceData = results[0].data;
      final settingsData = results[1].data;
      final historyData = results[2].data;

      setState(() {
        _supercoins = balanceData['supercoins'] ?? 0;
        _referralCode = balanceData['referralCode'] ?? '';
        _referralsCount = balanceData['referralsCount'] ?? 0;
        _loyaltySettings = settingsData['settings'];
        _history = historyData['history'] ?? [];
      });
    } catch (e) {
      debugPrint('Referral fetch error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _shareReferral() {
    if (_referralCode.isEmpty) return;
    SharePlus.instance.share(
      ShareParams(
        text: '🎉 Use my referral code "$_referralCode" on Lallafy and get Fun Coins on your first order!\n\nDownload now: https://lallafy.com',
      ),
    );
  }

  void _copyCode() {
    Clipboard.setData(ClipboardData(text: _referralCode));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Referral code copied!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Fun Coins & Referrals'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchData,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // ── Supercoin Balance Card ──
                  _buildBalanceCard(),
                  const SizedBox(height: 12),

                  // ── Buy Coins Button ──
                  _buildBuyCoinsButton(),
                  const SizedBox(height: 20),

                  // ── Referral Code Card ──
                  _buildReferralCard(),
                  const SizedBox(height: 20),

                  // ── How It Works ──
                  _buildHowItWorks(),
                  const SizedBox(height: 20),

                  // ── Coin History ──
                  if (_history.isNotEmpty) _buildHistory(),
                ],
              ),
            ),
    );
  }

  Widget _buildBalanceCard() {
    final coinValue = _loyaltySettings?['coin_value'] ?? 1;
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('🪙', style: TextStyle(fontSize: 28)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Fun Coins',
                      style: AppTextStyles.bodySm.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$_supercoins',
                      style: AppTextStyles.h1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 36,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            ),
            child: Text(
              '≈ ${Formatters.price((_supercoins * (coinValue as num)).toDouble())} value',
              style: AppTextStyles.bodySm.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuyCoinsButton() {
    return GestureDetector(
      onTap: () => context.push('/fun-coins'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE91E63), Color(0xFFD81B60)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE91E63).withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.shopping_bag_rounded,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Buy Fun Coins',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Get coin packs & save more on orders',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildReferralCard() {
    final referralReward = _loyaltySettings?['referral_reward_coins'] ?? 50;
    final refereeWelcome = _loyaltySettings?['referee_welcome_coins'] ?? 50;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🎁', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Text(
                'Refer & Earn',
                style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Invite friends and earn $referralReward Fun Coins when they make their first purchase! Your friend gets $refereeWelcome coins too.',
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.textMuted,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),

          // Referral code display
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
                style: BorderStyle.solid,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Referral Code',
                        style: AppTextStyles.bodyXs.copyWith(
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _referralCode.isNotEmpty ? _referralCode : 'Loading...',
                        style: AppTextStyles.h3.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _copyCode,
                  icon: const Icon(Icons.copy_rounded),
                  color: AppColors.primary,
                  tooltip: 'Copy code',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Stats row
          Row(
            children: [
              Expanded(
                child: _statBox(
                  icon: Icons.people_alt_rounded,
                  label: 'Referrals',
                  value: '$_referralsCount',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statBox(
                  icon: Icons.monetization_on_rounded,
                  label: 'Earned',
                  value: '${_referralsCount * (referralReward as num)} coins',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Share button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _shareReferral,
              icon: const Icon(Icons.share_rounded, size: 20),
              label: Text(
                'Share Referral Code',
                style: AppTextStyles.bodySm.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statBox({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTextStyles.bodySm.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.bodyXs.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorks() {
    final earnRate = _loyaltySettings?['supercoins_per_100'] ?? 1;
    final maxRedeemPercent = _loyaltySettings?['max_redemption_percent'] ?? 10;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How It Works',
            style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          _howItWorksItem(
            icon: '🛒',
            title: 'Shop & Earn',
            description: 'Earn $earnRate Fun Coin for every ₹100 spent on orders.',
          ),
          _howItWorksItem(
            icon: '💰',
            title: 'Redeem at Checkout',
            description: 'Use Fun Coins to get discounts (up to $maxRedeemPercent% of order value).',
          ),
          _howItWorksItem(
            icon: '🎁',
            title: 'Refer Friends',
            description: 'Share your code and both of you earn Fun Coins!',
          ),
        ],
      ),
    );
  }

  Widget _howItWorksItem({
    required String icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodySm.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: AppTextStyles.bodyXs.copyWith(
                    color: AppColors.textMuted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Coin History',
          style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        ...(_history.map((order) {
          final earned = (order['supercoinsEarned'] ?? 0) as num;
          final used = (order['supercoinsUsed'] ?? 0) as num;
          final orderNum = order['orderNumber'] ?? '';
          final status = order['orderStatus'] ?? '';

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: earned > 0
                        ? const Color(0xFFD1FAE5)
                        : const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    earned > 0 ? Icons.add_circle_rounded : Icons.remove_circle_rounded,
                    color: earned > 0 ? const Color(0xFF059669) : const Color(0xFFDC2626),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        orderNum,
                        style: AppTextStyles.bodySm.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        status.toString().toUpperCase(),
                        style: AppTextStyles.bodyXs.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (earned > 0)
                      Text(
                        '+$earned',
                        style: AppTextStyles.bodySm.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF059669),
                        ),
                      ),
                    if (used > 0)
                      Text(
                        '-$used',
                        style: AppTextStyles.bodySm.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFDC2626),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
        })),
      ],
    );
  }
}
