import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/network/dio_client.dart';
import '../../core/utils/formatters.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// FUN COINS SCREEN
/// Dedicated page with:
///   1. Balance header (gold gradient)
///   2. Buy Coins packs (Coming Soon)
///   3. How to Earn section
///   4. Referral card with share
///   5. How to Use info
///   6. Transaction history
/// ─────────────────────────────────────────────────────────────────────────────
class FunCoinsScreen extends ConsumerStatefulWidget {
  const FunCoinsScreen({super.key});

  @override
  ConsumerState<FunCoinsScreen> createState() => _FunCoinsScreenState();
}

class _FunCoinsScreenState extends ConsumerState<FunCoinsScreen> {
  bool _loading = true;
  int _supercoins = 0;
  String _referralCode = '';
  int _referralsCount = 0;
  Map<String, dynamic>? _settings;
  List<dynamic> _history = [];
  bool _buying = false;

  // Razorpay
  late Razorpay _razorpay;
  String? _pendingOrderId; // razorpay order id for verify
  String? _pendingPackId;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _fetchData();
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        DioClient().get('/loyalty/balance'),
        DioClient().get('/loyalty/settings'),
        DioClient().get('/loyalty/history'),
      ]);

      setState(() {
        _supercoins = results[0].data['supercoins'] ?? 0;
        _referralCode = results[0].data['referralCode'] ?? '';
        _referralsCount = results[0].data['referralsCount'] ?? 0;
        _settings = results[1].data['settings'];
        _history = results[2].data['history'] ?? [];
      });
    } catch (e) {
      debugPrint('FunCoins fetch error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _shareReferral() {
    if (_referralCode.isEmpty) return;
    SharePlus.instance.share(
      ShareParams(
        text:
            '🎉 Use my referral code "$_referralCode" on Lallafy and get Fun Coins on your first order!\n\nDownload now: https://lallafy.com',
      ),
    );
  }

  void _copyCode() {
    Clipboard.setData(ClipboardData(text: _referralCode));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Referral code copied! 📋'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ── Razorpay Payment Handlers ──────────────────────────────────────────────
  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      final verifyRes = await DioClient().post(
        '/loyalty/buy-coins/verify',
        data: {
          'razorpay_order_id': response.orderId,
          'razorpay_payment_id': response.paymentId,
          'razorpay_signature': response.signature,
        },
      );

      if (verifyRes.data['success'] == true) {
        final coinsAdded = verifyRes.data['coinsAdded'] ?? 0;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('+$coinsAdded Fun Coins added! 🎉'),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
        _fetchData(); // Refresh balance & history
      } else {
        _showError(verifyRes.data['message'] ?? 'Verification failed');
      }
    } catch (e) {
      _showError('Payment verification failed: $e');
    } finally {
      if (mounted) setState(() => _buying = false);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (mounted) {
      setState(() => _buying = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: ${response.message ?? "Unknown error"}'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('External wallet: ${response.walletName}');
  }

  void _showError(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  // ── Buy Pack Flow ─────────────────────────────────────────────────────────
  Future<void> _onBuyPack(String packId) async {
    if (_buying) return;
    setState(() => _buying = true);

    try {
      // Step 1: Create order on backend
      final orderRes = await DioClient().post(
        '/loyalty/buy-coins/create-order',
        data: {'packId': packId},
      );

      if (orderRes.data['success'] != true) {
        _showError(orderRes.data['message'] ?? 'Failed to create order');
        setState(() => _buying = false);
        return;
      }

      final razorpayOrderId = orderRes.data['orderId'];
      final amount = orderRes.data['amount'];
      final keyId = orderRes.data['keyId'] ?? 'rzp_test_TDJpb2HvvvomV0';
      final parsedAmount = (double.tryParse(amount.toString()) ?? 0).round();

      _pendingOrderId = razorpayOrderId;
      _pendingPackId = packId;

      // Step 2: Open Razorpay Checkout
      final options = {
        'key': keyId,
        'amount': parsedAmount,
        'currency': 'INR',
        'order_id': razorpayOrderId,
        'name': 'Lallafy',
        'description': 'Buy Fun Coins - ${orderRes.data['packDetails']?['label'] ?? packId}',
        'theme': {'color': '#E91E63'},
      };

      _razorpay.open(options);
      // Result handled by callbacks
    } catch (e) {
      _showError('Failed to initiate payment: $e');
      setState(() => _buying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final coinValue = _settings?['coin_value'] ?? 1;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Fun Coins'),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // ── 1. Balance Card ──
                  _buildBalanceCard(coinValue),
                  const SizedBox(height: 20),

                  // ── 2. Buy Coins Packs ──
                  _buildBuyCoinsSection(),
                  const SizedBox(height: 20),

                  // ── 3. How to Earn ──
                  _buildHowToEarn(),
                  const SizedBox(height: 20),

                  // ── 4. Referral Card ──
                  if (_referralCode.isNotEmpty) ...[
                    _buildReferralCard(),
                    const SizedBox(height: 20),
                  ],

                  // ── 5. How to Use ──
                  _buildHowToUse(),
                  const SizedBox(height: 20),

                  // ── 6. Transaction History ──
                  if (_history.isNotEmpty) _buildHistory(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  1. BALANCE CARD — Gold Gradient
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildBalanceCard(dynamic coinValue) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
        ),
        borderRadius: BorderRadius.circular(20),
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
              // Coin badge
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: const Center(
                  child: Text('🪙', style: TextStyle(fontSize: 30)),
                ),
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
                    const SizedBox(height: 2),
                    Text(
                      '$_supercoins',
                      style: AppTextStyles.h1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 40,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  '≈ ${Formatters.price((_supercoins * (coinValue as num)).toDouble())} value',
                  style: AppTextStyles.bodySm.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  '1 Coin = ₹${coinValue}',
                  style: AppTextStyles.bodySm.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  2. BUY COINS SECTION
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildBuyCoinsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE3EC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.shopping_bag_rounded,
                  color: Color(0xFFE91E63), size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              'Buy Coins',
              style: AppTextStyles.h3.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3CD),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '⭐ Best Value',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Packs grid (2 columns)
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.85,
          children: [
            _CoinPackCard(
              name: 'Starter',
              price: 49,
              coins: 50,
              bonus: 0,
              color: const Color(0xFF3B82F6),
              icon: Icons.flash_on_rounded,
              onBuy: () => _onBuyPack('starter'),
            ),
            _CoinPackCard(
              name: 'Popular',
              price: 99,
              coins: 120,
              bonus: 20,
              color: const Color(0xFFE91E63),
              icon: Icons.favorite_rounded,
              badge: 'POPULAR',
              onBuy: () => _onBuyPack('popular'),
            ),
            _CoinPackCard(
              name: 'Super Saver',
              price: 199,
              coins: 250,
              bonus: 50,
              color: const Color(0xFF8B5CF6),
              icon: Icons.diamond_rounded,
              onBuy: () => _onBuyPack('super_saver'),
            ),
            _CoinPackCard(
              name: 'Mega Pack',
              price: 499,
              coins: 700,
              bonus: 200,
              color: const Color(0xFFF59E0B),
              icon: Icons.rocket_launch_rounded,
              badge: 'BEST VALUE',
              onBuy: () => _onBuyPack('mega'),
            ),
          ],
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  3. HOW TO EARN SECTION
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildHowToEarn() {
    final perHundred = _settings?['supercoins_per_100'] ?? 1;
    final referralReward = _settings?['referral_reward_coins'] ?? 50;
    final refereeWelcome = _settings?['referee_welcome_coins'] ?? 50;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('⚡', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Text(
                'How to Earn Coins',
                style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _EarnMethodTile(
            icon: Icons.shopping_cart_rounded,
            iconColor: const Color(0xFF3B82F6),
            bgColor: const Color(0xFFDBEAFE),
            title: 'Shop & Earn',
            subtitle: 'Earn $perHundred Fun Coin for every ₹100 spent',
          ),
          const SizedBox(height: 12),

          _EarnMethodTile(
            icon: Icons.people_alt_rounded,
            iconColor: const Color(0xFF10B981),
            bgColor: const Color(0xFFD1FAE5),
            title: 'Refer a Friend',
            subtitle: 'Get $referralReward Coins when your friend orders',
          ),
          const SizedBox(height: 12),

          _EarnMethodTile(
            icon: Icons.card_giftcard_rounded,
            iconColor: const Color(0xFFF59E0B),
            bgColor: const Color(0xFFFEF3C7),
            title: 'Get Referred',
            subtitle: 'New users earn $refereeWelcome Coins on 1st order',
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  4. REFERRAL CARD
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildReferralCard() {
    final referralReward = _settings?['referral_reward_coins'] ?? 50;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('👥', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Refer & Earn $referralReward Coins',
                      style: AppTextStyles.body.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'You\'ve referred $_referralsCount friends',
                      style: AppTextStyles.bodySm.copyWith(
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Referral code box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _referralCode,
                    style: AppTextStyles.body.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _copyCode,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'COPY',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Share button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _shareReferral,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF6366F1),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              icon: const Icon(Icons.share_rounded, size: 18),
              label: const Text(
                'Share with Friends',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  5. HOW TO USE COINS
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildHowToUse() {
    final maxPercent = _settings?['max_redemption_percent'] ?? 10;
    final coinValue = _settings?['coin_value'] ?? 1;
    final expiryMonths = _settings?['expiry_months'] ?? 12;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💡', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Text(
                'How to Use Coins',
                style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _InfoRow(icon: '✅', text: 'Use coins at checkout to get discounts'),
          const SizedBox(height: 8),
          _InfoRow(icon: '💰', text: '1 Fun Coin = ₹$coinValue'),
          const SizedBox(height: 8),
          _InfoRow(
              icon: '📊',
              text: 'Max $maxPercent% of order can be paid with coins'),
          const SizedBox(height: 8),
          _InfoRow(
              icon: '⏰', text: 'Coins expire after $expiryMonths months'),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  6. TRANSACTION HISTORY
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('📜', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Text(
              'Transaction History',
              style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: _history.take(20).map<Widget>((item) {
              final earned = item['supercoinsEarned'] ?? 0;
              final used = item['supercoinsUsed'] ?? 0;
              final isEarned = earned > 0;
              final orderNum = item['orderNumber'] ?? '';
              final status = item['orderStatus'] ?? '';

              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  border: Border(
                    bottom:
                        BorderSide(color: AppColors.border, width: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    // Icon
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isEarned
                            ? const Color(0xFFD1FAE5)
                            : const Color(0xFFFFE4E6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isEarned
                            ? Icons.add_circle_rounded
                            : Icons.remove_circle_rounded,
                        color: isEarned
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            orderNum,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            status.toLowerCase() == 'cancelled'
                                ? 'Cancelled'
                                : isEarned
                                    ? 'Earned'
                                    : 'Redeemed',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Amount
                    Text(
                      isEarned ? '+$earned' : '-$used',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: isEarned
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  REUSABLE WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════

/// Single Coin Pack Card
class _CoinPackCard extends StatelessWidget {
  final String name;
  final int price;
  final int coins;
  final int bonus;
  final Color color;
  final IconData icon;
  final String? badge;
  final VoidCallback onBuy;

  const _CoinPackCard({
    required this.name,
    required this.price,
    required this.coins,
    required this.bonus,
    required this.color,
    required this.icon,
    required this.onBuy,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: badge != null ? color.withOpacity(0.4) : const Color(0xFFE5E7EB),
          width: badge != null ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon circle
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(height: 8),
                // Name
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                // Coins
                Text(
                  '$coins Coins',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: Color(0xFF1E293B),
                  ),
                ),
                if (bonus > 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    '+$bonus Bonus',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ],
                const Spacer(),
                // Buy button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onBuy,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      '₹$price',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Badge
          if (badge != null)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(17),
                    bottomLeft: Radius.circular(10),
                  ),
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Earn Method Tile
class _EarnMethodTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final String subtitle;

  const _EarnMethodTile({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Info Row for How to Use section
class _InfoRow extends StatelessWidget {
  final String icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF1E293B),
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}
