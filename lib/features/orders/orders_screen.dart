import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/cached_image.dart';

/// Orders tabs
const _tabs = ['All', 'Pending', 'Confirmed', 'Delivered', 'Cancelled'];

/// Orders provider — fetches ALL user orders once (backend doesn't support status filter)
final allOrdersProvider =
    FutureProvider<List<dynamic>>((ref) async {
  final response = await DioClient().get(ApiConstants.myOrders);
  final data = response.data;
  final rawOrders = data['orders'] ??
      (data['data'] is Map ? data['data']['orders'] : null) ??
      data['data'] ??
      [];
  return (rawOrders as List<dynamic>);
});

/// Orders Screen — mirrors OrdersPage.tsx
///
/// Tabs for status filtering, order cards with item previews
class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  String _activeTab = 'All';

  @override
  void initState() {
    super.initState();
    // Always refetch orders when entering this screen
    Future.microtask(() => ref.invalidate(allOrdersProvider));
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(allOrdersProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
        ),
        title: const Text('My Orders'),
      ),
      body: Column(
        children: [
          // ── Tab bar ──
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _tabs.map((tab) {
                final isActive = _activeTab == tab;
                return GestureDetector(
                  onTap: () => setState(() => _activeTab = tab),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isActive
                              ? AppColors.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      tab,
                      style: AppTextStyles.bodySm.copyWith(
                        color: isActive
                            ? AppColors.primary
                            : AppColors.textMuted,
                        fontWeight:
                            isActive ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),

          // ── Orders list (client-side filtered) ──
          Expanded(
            child: ordersAsync.when(
              data: (allOrders) {
                // Client-side filtering by orderStatus
                final orders = _activeTab == 'All'
                    ? allOrders
                    : allOrders.where((o) {
                        final status = (o['orderStatus'] ?? '').toString().toLowerCase();
                        return status == _activeTab.toLowerCase();
                      }).toList();
                if (orders.isEmpty) return _buildEmpty();
                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    ref.invalidate(allOrdersProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: orders.length,
                    itemBuilder: (context, index) =>
                        _OrderCard(order: orders[index]),
                  ),
                );
              },
              loading: () =>
                  const LoadingWidget(message: 'Loading orders...'),
              error: (err, _) => Center(
                child: Text(err.toString(),
                    style: AppTextStyles.bodySm
                        .copyWith(color: AppColors.danger)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📦', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text('No orders found', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Text(
              "You haven't placed any orders yet.",
              style:
                  AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/shop'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppTheme.radiusFull),
                ),
              ),
              child: const Text('Start Shopping'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual order card
class _OrderCard extends ConsumerWidget {
  final dynamic order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = (order['items'] ?? order['orderItems'] ?? []) as List<dynamic>;
    final status = (order['orderStatus'] ?? order['status'] ?? 'pending').toString();
    final total = double.tryParse('${order['totalAmount'] ?? order['total'] ?? 0}') ?? 0;
    final paymentMethod = order['paymentMethod'];

    return GestureDetector(
      onTap: () => context.push('/orders/${order['_id'] ?? order['id']}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '#${order['orderNumber'] ?? ''}',
                    style: AppTextStyles.bodySm
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    _formatDate(order['createdAt'] ?? ''),
                    style: AppTextStyles.bodyXs
                        .copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
              Row(
                children: [
                  _statusBadge(status),
                  if (paymentMethod == 'cod') ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusFull),
                      ),
                      child: Text(
                        '💵 COD',
                        style: AppTextStyles.bodyXs.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Item thumbnails
          if (items.isNotEmpty) ...[
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: items.length > 5 ? 6 : items.length,
                separatorBuilder: (_, _) => const SizedBox(width: 6),
                itemBuilder: (_, i) {
                  if (i == 5) {
                    return Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.bgElevated,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusSm),
                      ),
                      child: Center(
                        child: Text('+${items.length - 5}',
                            style: AppTextStyles.bodyXs
                                .copyWith(color: AppColors.textMuted)),
                      ),
                    );
                  }
                  final itemProd = items[i]['product'];
                  final prodMap = (itemProd is Map) ? itemProd : null;
                  final prodImages = prodMap?['images'];
                  final imageUrl = items[i]['image'] ??
                      ((prodImages is List && prodImages.isNotEmpty)
                          ? (prodImages[0] is String ? prodImages[0] : (prodImages[0] is Map ? prodImages[0]['url'] : null))
                          : null);
                  return ClipRRect(
                    borderRadius:
                        BorderRadius.circular(AppTheme.radiusSm),
                    child: imageUrl != null
                        ? CachedImage(
                            imageUrl: imageUrl,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 48,
                            height: 48,
                            color: AppColors.bgElevated,
                            child: const Center(
                                child: Text('🎁',
                                    style: TextStyle(fontSize: 16))),
                          ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Footer: total + actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Formatters.price(total),
                style: AppTextStyles.h4.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox.shrink(),
            ],
          ),
        ],
      ),
    ),
  );
}

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      return Formatters.date(dt);
    } catch (_) {
      return dateStr;
    }
  }

  Widget _statusBadge(String status) {
    Color bg;
    Color textColor;
    switch (status.toLowerCase()) {
      case 'delivered':
        bg = AppColors.success.withValues(alpha: 0.1);
        textColor = AppColors.success;
        break;
      case 'cancelled':
        bg = AppColors.danger.withValues(alpha: 0.1);
        textColor = AppColors.danger;
        break;
      case 'confirmed':
      case 'shipped':
        bg = AppColors.primary.withValues(alpha: 0.1);
        textColor = AppColors.primary;
        break;
      default:
        bg = AppColors.warning.withValues(alpha: 0.1);
        textColor = AppColors.warning;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Text(
        status[0].toUpperCase() + status.substring(1),
        style: AppTextStyles.bodyXs.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
