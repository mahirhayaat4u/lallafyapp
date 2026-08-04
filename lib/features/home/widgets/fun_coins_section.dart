import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/auth_provider.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';

/// Fun Coins Premium Section for Home Screen
///
/// Matches reference UI layout & styling:
/// - Light pink pastel background with subtle rounded border
/// - Left: Shiny Gold Coin + "Your Coins Balance" + "$_coins Coins" + "View Rewards >"
/// - Middle: ⚡ "Earn Coins" with subtitle
/// - Right: 🎁 "Buy Coins" with subtitle
class FunCoinsMiniSection extends ConsumerStatefulWidget {
  const FunCoinsMiniSection({super.key});

  @override
  ConsumerState<FunCoinsMiniSection> createState() =>
      _FunCoinsMiniSectionState();
}

class _FunCoinsMiniSectionState extends ConsumerState<FunCoinsMiniSection> {
  int _coins = 0;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _fetchCoins();
  }

  Future<void> _fetchCoins() async {
    try {
      final res = await DioClient().get(ApiConstants.loyaltyBalance);
      final data = res.data;
      final coins = data['supercoins'] ?? data['data']?['supercoins'] ?? 0;
      if (mounted) {
        setState(() {
          _coins = (coins is int) ? coins : int.tryParse('$coins') ?? 0;
          _loaded = true;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loaded = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    if (!auth.isAuthenticated) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFF2F5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFFD8E4), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD02752).withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── 1. LEFT: Coins Balance & View Rewards Button ──
              Expanded(
                flex: 10,
                child: GestureDetector(
                  onTap: () => context.push('/fun-coins').then((_) => _fetchCoins()),
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      // Gold Coin Graphic
                      const _GoldCoinBadge(),
                      const SizedBox(width: 6),

                      // Balance Text & Pill Button
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Your Coins Balance',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              _loaded ? '$_coins Coins' : '...',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFD02752),
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 1),
                            const Text(
                              'Use coins & save more',
                              style: TextStyle(
                                fontSize: 9,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 6),
                            // View Rewards Pill Button
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 9, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFFFFB2C5),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Text(
                                    'View Rewards',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFD02752),
                                    ),
                                  ),
                                  SizedBox(width: 0),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    size: 13,
                                    color: Color(0xFFD02752),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Vertical Divider 1
              Container(
                width: 1,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                color: const Color(0xFFFFD1DC),
              ),

              // ── 2. MIDDLE: Earn Coins CTA ──
              Expanded(
                flex: 6,
                child: GestureDetector(
                  onTap: () => context.push('/fun-coins').then((_) => _fetchCoins()),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon Circle
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFDCE5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.bolt_rounded,
                          color: Color(0xFFE91E63),
                          size: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Earn Coins',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Complete tasks\n& earn more',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 8,
                          color: Color(0xFF64748B),
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Vertical Divider 2
              Container(
                width: 1,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                color: const Color(0xFFFFD1DC),
              ),

              // ── 3. RIGHT: Buy Coins CTA ──
              Expanded(
                flex: 6,
                child: GestureDetector(
                  onTap: () => context.push('/fun-coins').then((_) => _fetchCoins()),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon Circle
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFE3EC),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.card_giftcard_rounded,
                          color: Color(0xFFE91E63),
                          size: 17,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Buy Coins',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Get extra coins\n& save more',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 8,
                          color: Color(0xFF64748B),
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shiny Gold Coin Badge Component
class _GoldCoinBadge extends StatelessWidget {
  const _GoldCoinBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFFFFDF00), Color(0xFFFFB700), Color(0xFFFF8800)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFA500).withOpacity(0.35),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFFFF7C2), width: 1),
        ),
        child: const Center(
          child: Icon(
            Icons.star_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
    );
  }
}
