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
import 'package:url_launcher/url_launcher.dart';
import 'orders_screen.dart';
/// Order detail provider
final orderDetailProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, orderId) async {
  final response = await DioClient().get(ApiConstants.orderDetail(orderId));
  final data = response.data;
  return (data['order'] ?? data['data']?['order'] ?? data['data'] ?? data)
      as Map<String, dynamic>;
});

/// Order Detail Screen — mirrors OrderDetailPage.tsx
class OrderDetailScreen extends ConsumerWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailProvider(orderId));

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/orders');
            }
          },
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
        ),
        title: orderAsync.when(
          data: (order) => Text('Order #${order['orderNumber'] ?? ''}'),
          loading: () => const Text('Loading...'),
          error: (_, __) => const Text('Order Details'),
        ),
      ),
      body: orderAsync.when(
        data: (order) => _OrderDetailBody(order: order, orderId: orderId),
        loading: () => const LoadingWidget(message: 'Loading order details...'),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('📦', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 16),
                Text('Order not found', style: AppTextStyles.h3),
                const SizedBox(height: 8),
                Text(
                  err.toString(),
                  style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.go('/orders'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    ),
                  ),
                  child: const Text('Back to Orders'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderDetailBody extends ConsumerWidget {
  final Map<String, dynamic> order;
  final String orderId;

  const _OrderDetailBody({required this.order, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = (order['orderStatus'] ?? order['status'] ?? 'pending') as String;
    final isCancelled = status == 'cancelled';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Header Card ──
        _buildHeaderCard(context, status),
        const SizedBox(height: 16),

        // ── Gift Options ──
        if (order['giftWrap'] == true ||
            (order['giftMessage'] != null && order['giftMessage'].toString().isNotEmpty))
          ...[_buildGiftCard(), const SizedBox(height: 16)],

        // ── Order Tracking ──
        if (!isCancelled) ...[
          _buildTrackingCard(status),
          const SizedBox(height: 16),
        ],

        // ── Cancelled Banner ──
        if (isCancelled) ...[
          _buildCancelledBanner(),
          const SizedBox(height: 16),
        ],

        // ── Store Orders / Items ──
        _buildItemsSection(context),
        const SizedBox(height: 16),

        // ── Price Breakdown ──
        _buildPriceBreakdown(),
        const SizedBox(height: 16),

        // ── Delivery Address ──
        if (order['shippingAddress'] != null || order['address'] != null) _buildAddressCard(),
        const SizedBox(height: 16),

        // ── Customer Support ──
        _buildSupportSection(context),

        // ── Cancel Order Button ──
        _buildCancelOrderButton(context, ref),
        const SizedBox(height: 32),
      ],
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  Widget _buildSupportSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.help_outline_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Need Help with this Order?',
                style: AppTextStyles.bodySm.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'If you have any questions regarding delivery, returns, or product issues, feel free to contact us.',
            style: AppTextStyles.bodyXs.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _launchUrl('https://wa.me/917290900282?text=Hi%20Lallafy%20Support!%20My%20Order%20ID%20is%20${order['orderNumber'] ?? ''}'),
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16, color: Color(0xFF25D366)),
                  label: Text(
                    'WhatsApp',
                    style: AppTextStyles.bodyXs.copyWith(fontWeight: FontWeight.w700, color: const Color(0xFF25D366)),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF25D366)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _launchUrl('tel:+917290900282'),
                  icon: const Icon(Icons.phone_in_talk_outlined, size: 16, color: AppColors.primary),
                  label: Text(
                    'Call Us',
                    style: AppTextStyles.bodyXs.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCancelOrderButton(BuildContext context, WidgetRef ref) {
    final status = (order['orderStatus'] ?? order['status'] ?? 'pending') as String;
    final createdAtStr = order['createdAt']?.toString() ?? '';
    final createdAt = DateTime.tryParse(createdAtStr) ?? DateTime.now();
    final isWithinOneDay = DateTime.now().difference(createdAt).inHours < 24;
    final showCancelButton = ['pending', 'confirmed'].contains(status) && isWithinOneDay;

    if (!showCancelButton) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: OutlinedButton(
          onPressed: () => _showCancelConfirmationDialog(context, ref),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.danger, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
          ),
          child: Text(
            'Cancel Order',
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.danger,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  void _showCancelConfirmationDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        title: Text(
          'Cancel Order?',
          style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w800),
        ),
        content: Text(
          'Are you sure you want to cancel this order? This action cannot be undone.',
          style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              'No, Keep It',
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.text,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              try {
                await DioClient().put(
                  ApiConstants.orderCancel(order['_id'] ?? order['id'] ?? '')
                );
                
                // Invalidate providers to refresh detail screen & list screen
                ref.invalidate(orderDetailProvider(orderId));
                ref.invalidate(allOrdersProvider);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Order cancelled successfully ✅'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to cancel: $e'),
                      backgroundColor: AppColors.danger,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
            ),
            child: Text(
              'Yes, Cancel',
              style: AppTextStyles.bodySm.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header Card ──
  Widget _buildHeaderCard(BuildContext context, String status) {
    final paymentRaw = order['payment'];
    final paymentStatus = order['paymentStatus'] ??
        (paymentRaw is Map ? paymentRaw['status'] : null);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${order['orderNumber'] ?? ''}',
                      style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Placed on ${_formatDate(order['createdAt'] ?? '')}',
                      style: AppTextStyles.bodyXs.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              _statusBadge(status),
            ],
          ),
          const SizedBox(height: 12),
          // Payment status
          if (paymentStatus != null) ...[
            Row(
              children: [
                _paymentBadge(paymentStatus),
                if (order['paymentMethod'] == 'cod') ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    ),
                    child: Text(
                      '💵 COD',
                      style: AppTextStyles.bodyXs.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ],
            ),
          ] else if (order['paymentMethod'] == 'cod') ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
              child: Text(
                '💵 Cash on Delivery',
                style: AppTextStyles.bodyXs.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Gift Options Card ──
  Widget _buildGiftCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🎁 Gift Options',
            style: AppTextStyles.bodySm.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.goldDark,
            ),
          ),
          const SizedBox(height: 8),
          if (order['giftWrap'] == true)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '🎀 Gift wrapping included',
                style: AppTextStyles.bodyXs.copyWith(color: AppColors.textMuted),
              ),
            ),
          if (order['giftMessage'] != null &&
              order['giftMessage'].toString().isNotEmpty)
            Text(
              '💌 Message: "${order['giftMessage']}"',
              style: AppTextStyles.bodyXs.copyWith(color: AppColors.textMuted),
            ),
          if (order['deliveryDate'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '📅 Preferred delivery: ${_formatDate(order['deliveryDate'])}',
                style: AppTextStyles.bodyXs.copyWith(color: AppColors.textMuted),
              ),
            ),
        ],
      ),
    );
  }

  // ── Order Tracking Card ──
  Widget _buildTrackingCard(String status) {
    final isDelivered = status == 'delivered';
    final storeOrders = order['storeOrders'] as List<dynamic>?;
    final isShipped = isDelivered ||
        (storeOrders?.any((so) =>
                so['status'] == 'shipped' || so['status'] == 'delivered') ??
            false);
    final isConfirmed = isShipped || status == 'confirmed';

    final steps = [
      ('Placed', Icons.description_outlined, true),
      ('Confirmed', Icons.settings_outlined, isConfirmed),
      ('Shipped', Icons.local_shipping_outlined, isShipped),
      ('Delivered', Icons.card_giftcard_outlined, isDelivered),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Tracking',
            style: AppTextStyles.bodySm.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(steps.length, (index) {
              final (label, icon, isActive) = steps[index];
              final isCompleted = isActive &&
                  (index < steps.length - 1 ? steps[index + 1].$3 : isDelivered);
              final isCurrent = isActive && !isCompleted;

              return Expanded(
                child: Column(
                  children: [
                    // Connector + Circle
                    Row(
                      children: [
                        // Left connector
                        if (index > 0)
                          Expanded(
                            child: Container(
                              height: 2,
                              color: isActive
                                  ? AppColors.primary
                                  : AppColors.border,
                            ),
                          )
                        else
                          const Expanded(child: SizedBox()),

                        // Circle
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCompleted || isCurrent
                                ? AppColors.primary
                                : AppColors.bgElevated,
                            border: Border.all(
                              color: isActive
                                  ? AppColors.primary
                                  : AppColors.border,
                              width: 2,
                            ),
                            boxShadow: isCurrent
                                ? [
                                    BoxShadow(
                                      color:
                                          AppColors.primary.withValues(alpha: 0.25),
                                      blurRadius: 10,
                                    )
                                  ]
                                : null,
                          ),
                          child: Icon(
                            isCompleted ? Icons.check : icon,
                            size: 14,
                            color: isCompleted || isCurrent
                                ? Colors.white
                                : AppColors.textMuted,
                          ),
                        ),

                        // Right connector
                        if (index < steps.length - 1)
                          Expanded(
                            child: Container(
                              height: 2,
                              color: steps[index + 1].$3
                                  ? AppColors.primary
                                  : AppColors.border,
                            ),
                          )
                        else
                          const Expanded(child: SizedBox()),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      label,
                      style: AppTextStyles.bodyXs.copyWith(
                        fontWeight:
                            isCurrent ? FontWeight.w700 : FontWeight.w500,
                        color: isActive
                            ? (isCurrent ? AppColors.primary : AppColors.text)
                            : AppColors.textMuted,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── Cancelled Banner ──
  Widget _buildCancelledBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.cancel_outlined, color: AppColors.danger, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Cancelled',
                  style: AppTextStyles.bodySm.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.danger,
                  ),
                ),
                Text(
                  'This order has been cancelled.',
                  style: AppTextStyles.bodyXs.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Items Section ──
  Widget _buildItemsSection(BuildContext context) {
    final storeOrders = order['storeOrders'] as List<dynamic>?;

    if (storeOrders != null && storeOrders.isNotEmpty) {
      return Column(
        children: storeOrders.map<Widget>((so) {
          final storeField = so['store'];
          final storeName = (storeField is Map) ? (storeField['storeName'] ?? 'Store') : 'Store';
          final storeStatus = (so['status'] ?? '').toString();
          final items = (so['items'] ?? so['orderItems'] ?? []) as List<dynamic>;
          final trackingNumber = so['trackingNumber'];

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                // Store header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.bgElevated,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppTheme.radiusLg),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text('🏪 ', style: TextStyle(fontSize: 16)),
                          Text(
                            storeName,
                            style: AppTextStyles.bodySm
                                .copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          if (trackingNumber != null) ...[
                            Text(
                              'Tracking: $trackingNumber',
                              style: AppTextStyles.bodyXs
                                  .copyWith(color: AppColors.textMuted),
                            ),
                            const SizedBox(width: 8),
                          ],
                          _statusBadge(storeStatus),
                        ],
                      ),
                    ],
                  ),
                ),

                // Items
                ...items.map<Widget>((item) => _buildItemRow(item, context)),
              ],
            ),
          );
        }).toList(),
      );
    }

    // Fallback: orderItems directly on the order
    final items = (order['items'] ?? order['orderItems'] ?? []) as List<dynamic>;
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.bgElevated,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppTheme.radiusLg),
              ),
            ),
            child: Row(
              children: [
                const Text('📦 ', style: TextStyle(fontSize: 16)),
                Text(
                  'Order Items',
                  style: AppTextStyles.bodySm.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          ...items.map<Widget>((item) => _buildItemRow(item, context)),
        ],
      ),
    );
  }

  Widget _buildItemRow(dynamic item, BuildContext context) {
    final product = item['product'];
    final productMap = (product is Map) ? product : null;
    final images = productMap?['images'];
    // Product.images is [String] (plain URLs), not [{url}] objects
    final imageUrl = item['image'] ??
        ((images is List && images.isNotEmpty)
            ? (images[0] is String ? images[0] : (images[0] is Map ? images[0]['url'] : null))
            : null);
    final name = item['name'] ?? item['productName'] ?? productMap?['name'] ?? 'Item';
    final qty = item['quantity'] ?? 1;
    final price = double.tryParse('${item['price']}') ?? 0;
    final slug = productMap?['slug'];

    return InkWell(
      onTap: slug != null ? () => context.push('/product/$slug') : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              child: imageUrl != null
                  ? CachedImage(
                      imageUrl: imageUrl,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 64,
                      height: 64,
                      color: AppColors.bgElevated,
                      child: const Center(
                        child: Text('🎁', style: TextStyle(fontSize: 24)),
                      ),
                    ),
            ),
            const SizedBox(width: 14),

            // Name + Qty
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.bodySm.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Qty: $qty',
                    style: AppTextStyles.bodyXs.copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),

            // Price
            Text(
              Formatters.price(price * qty),
              style: AppTextStyles.bodySm.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  // ── Price Breakdown ──
  Widget _buildPriceBreakdown() {
    final subtotal = double.tryParse('${order['itemsTotal'] ?? order['subtotal'] ?? 0}') ?? 0;
    final shipping = double.tryParse('${order['shippingCharge'] ?? order['shippingFee'] ?? 0}') ?? 0;
    final giftWrapFee = double.tryParse('${order['giftWrapFee'] ?? 0}') ?? 0;
    final discount = double.tryParse('${order['discount'] ?? 0}') ?? 0;
    final total = double.tryParse('${order['totalAmount'] ?? order['total'] ?? 0}') ?? 0;
    final gstAmount = double.tryParse('${order['gstAmount']}') ?? (total - subtotal - shipping - giftWrapFee + discount);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price Breakdown',
            style: AppTextStyles.bodySm.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          _priceRow('Subtotal', Formatters.price(subtotal)),
          if (gstAmount > 0.5)
            _priceRow('GST (18%)', Formatters.price(gstAmount)),
          _priceRow(
            'Shipping',
            shipping == 0 ? 'FREE' : Formatters.price(shipping),
            valueColor: shipping == 0 ? AppColors.success : null,
          ),
          if (giftWrapFee > 0)
            _priceRow('Gift Wrap', Formatters.price(giftWrapFee)),
          if (discount > 0)
            _priceRow(
              'Coupon Discount',
              '-${Formatters.price(discount)}',
              valueColor: AppColors.success,
            ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.w800),
              ),
              Text(
                Formatters.price(total),
                style: AppTextStyles.h4.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyXs.copyWith(color: AppColors.textMuted),
          ),
          Text(
            value,
            style: AppTextStyles.bodyXs.copyWith(
              color: valueColor ?? AppColors.text,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── Delivery Address ──
  Widget _buildAddressCard() {
    final address = order['shippingAddress'] ?? order['address'];
    if (address == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delivery Address',
            style: AppTextStyles.bodySm.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Text(
            address['fullName'] ?? address['name'] ?? '',
            style: AppTextStyles.bodySm.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            address['addressLine'] ?? address['line1'] ?? '',
            style: AppTextStyles.bodyXs.copyWith(color: AppColors.textMuted),
          ),
          Text(
            '${address['city'] ?? ''}, ${address['state'] ?? ''} ${address['pincode'] ?? ''}',
            style: AppTextStyles.bodyXs.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 4),
          Text(
            '📞 ${address['phone'] ?? ''}',
            style: AppTextStyles.bodyXs.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──
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
        status.isNotEmpty
            ? '${status[0].toUpperCase()}${status.substring(1)}'
            : '',
        style: AppTextStyles.bodyXs.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _paymentBadge(dynamic payment) {
    // payment can be a String like "paid" or a Map like {status: "captured"}
    final payStatus = (payment is String)
        ? payment
        : (payment is Map ? (payment['status'] ?? '') : '');
    final isPaid = payStatus == 'paid' || payStatus == 'captured';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (isPaid ? AppColors.success : AppColors.warning)
            .withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Text(
        isPaid ? '✓ Paid' : '⏳ Payment Pending',
        style: AppTextStyles.bodyXs.copyWith(
          color: isPaid ? AppColors.success : AppColors.warning,
          fontWeight: FontWeight.w600,
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
}
