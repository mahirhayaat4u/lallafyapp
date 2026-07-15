import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/cached_image.dart';
import '../../core/widgets/app_button.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';

/// Cart Screen — mirrors CartPage.tsx
///
/// Items grouped by store → Order summary → Checkout CTA
class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final auth = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Cart (${cart.totalItems})'),
        actions: [
          if (!cart.isEmpty)
            TextButton(
              onPressed: () {
                ref.read(cartProvider.notifier).clearCart();
              },
              child: Text(
                '🗑️ Clear',
                style: AppTextStyles.bodyXs.copyWith(
                  color: AppColors.danger,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: cart.isEmpty
          ? _buildEmptyCart(context)
          : _buildCartContent(context, ref, cart, auth),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🛒', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text('Your cart is empty', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Text(
              'Add some gifts to your cart and they\'ll show up here.',
              style:
                  AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Start Shopping',
              onPressed: () => context.push('/shop'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartContent(
    BuildContext context,
    WidgetRef ref,
    CartState cart,
    dynamic auth,
  ) {
    return Column(
      children: [
        // Cart items (scrollable)
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final entry in cart.groupedByStore.entries) ...[
                _StoreGroup(
                  storeId: entry.key,
                  storeName: entry.value.first.storeName,
                  items: entry.value,
                  onUpdateQty: (productId, qty) {
                    ref.read(cartProvider.notifier).updateQty(productId, qty);
                  },
                  onRemove: (productId) {
                    ref.read(cartProvider.notifier).removeItem(productId);
                  },
                  onItemTap: (slug) => context.push('/product/$slug'),
                ),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),

        // Order summary (pinned at bottom)
        _OrderSummary(
          cart: cart,
          isLoggedIn: auth.isAuthenticated,
          onCheckout: () {
            if (auth.isAuthenticated) {
              context.push('/checkout');
            } else {
              context.push('/login');
            }
          },
          onContinueShopping: () => context.push('/shop'),
        ),
      ],
    );
  }
}

/// Store group card with header + items
class _StoreGroup extends StatelessWidget {
  final String storeId;
  final String storeName;
  final List items;
  final Function(String productId, int qty) onUpdateQty;
  final Function(String productId) onRemove;
  final Function(String slug) onItemTap;

  const _StoreGroup({
    required this.storeId,
    required this.storeName,
    required this.items,
    required this.onUpdateQty,
    required this.onRemove,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Store header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppColors.bgElevated,
            child: Row(
              children: [
                const Text('🏪', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(
                  storeName,
                  style: AppTextStyles.bodySm
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.bgSurface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  ),
                  child: Text(
                    '${items.length} item${items.length > 1 ? 's' : ''}',
                    style: AppTextStyles.bodyXs
                        .copyWith(color: AppColors.textMuted),
                  ),
                ),
              ],
            ),
          ),
          // Items
          for (final item in items)
            _CartItemRow(
              item: item,
              onUpdateQty: onUpdateQty,
              onRemove: onRemove,
              onTap: () => onItemTap(item.slug),
            ),
        ],
      ),
    );
  }
}

/// Individual cart item row
class _CartItemRow extends StatelessWidget {
  final dynamic item;
  final Function(String, int) onUpdateQty;
  final Function(String) onRemove;
  final VoidCallback onTap;

  const _CartItemRow({
    required this.item,
    required this.onUpdateQty,
    required this.onRemove,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          GestureDetector(
            onTap: onTap,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              child: item.imageUrl != null
                  ? CachedImage(
                      imageUrl: item.imageUrl!,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 72,
                      height: 72,
                      color: AppColors.bgElevated,
                      child: const Center(
                          child: Text('🎁',
                              style: TextStyle(fontSize: 24))),
                    ),
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: onTap,
                  child: Text(
                    item.name,
                    style: AppTextStyles.bodySm
                        .copyWith(fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      Formatters.price(item.effectivePrice),
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (item.hasDiscount) ...[
                      const SizedBox(width: 6),
                      Text(
                        Formatters.price(item.price),
                        style: AppTextStyles.bodyXs.copyWith(
                          color: AppColors.textSubtle,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                // Qty stepper + line total
                Row(
                  children: [
                    _QtyStepperSmall(
                      qty: item.quantity,
                      onMinus: () =>
                          onUpdateQty(item.productId, item.quantity - 1),
                      onPlus: () =>
                          onUpdateQty(item.productId, item.quantity + 1),
                    ),
                    const Spacer(),
                    Text(
                      Formatters.price(item.lineTotal),
                      style: AppTextStyles.bodySm
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Remove button
          GestureDetector(
            onTap: () => onRemove(item.productId),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(Icons.close_rounded,
                  size: 18, color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small qty stepper for cart rows
class _QtyStepperSmall extends StatelessWidget {
  final int qty;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const _QtyStepperSmall({
    required this.qty,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _btn(Icons.remove, onMinus),
          Container(
            width: 32,
            alignment: Alignment.center,
            child: Text(
              '$qty',
              style: AppTextStyles.bodyXs
                  .copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          _btn(Icons.add, onPlus),
        ],
      ),
    );
  }

  Widget _btn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        child: Icon(icon, size: 14, color: AppColors.text),
      ),
    );
  }
}

/// Order summary pinned at bottom
class _OrderSummary extends StatelessWidget {
  final CartState cart;
  final bool isLoggedIn;
  final VoidCallback onCheckout;
  final VoidCallback onContinueShopping;

  const _OrderSummary({
    required this.cart,
    required this.isLoggedIn,
    required this.onCheckout,
    required this.onContinueShopping,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Subtotal
          _summaryRow(
              'Subtotal (${cart.totalItems} items)',
              Formatters.price(cart.subtotal)),
          const SizedBox(height: 6),
          // Shipping
          _summaryRow(
            'Shipping',
            cart.shipping == 0 ? 'FREE' : Formatters.price(cart.shipping),
            valueColor: cart.shipping == 0 ? AppColors.success : null,
          ),
          // Free shipping hint
          if (cart.shipping > 0) ...[
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.bgElevated,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Text(
                '🚚 Add ${Formatters.price(cart.freeShippingRemaining)} more for free shipping!',
                style: AppTextStyles.bodyXs
                    .copyWith(color: AppColors.textMuted),
              ),
            ),
          ],
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),
          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total',
                  style:
                      AppTextStyles.h4.copyWith(fontWeight: FontWeight.w800)),
              Text(
                Formatters.price(cart.total),
                style: AppTextStyles.h4.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Checkout button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: AppButton(
              label: isLoggedIn
                  ? 'Proceed to Checkout →'
                  : 'Login to Continue →',
              onPressed: onCheckout,
              isFullWidth: true,
            ),
          ),
          const SizedBox(height: 8),
          // Continue shopping
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: onContinueShopping,
              child: Text(
                '← Continue Shopping',
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style:
                AppTextStyles.bodySm.copyWith(color: AppColors.textMuted)),
        Text(
          value,
          style: AppTextStyles.bodySm.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
