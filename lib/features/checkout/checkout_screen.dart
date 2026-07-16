import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/cached_image.dart';
import '../../core/widgets/app_button.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../profile/addresses_screen.dart';

/// Checkout stepper labels
const _steps = ['Address', 'Payment'];

/// Checkout Screen — mirrors CheckoutPage.tsx
///
/// 3-step flow: Address → Gift Options → Payment
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  int _step = 0;
  String? _selectedAddressId;
  bool _giftWrap = false;
  String _giftMessage = '';
  String _couponCode = '';
  double _couponDiscount = 0;
  bool _couponLoading = false;
  bool _paying = false;
  String _paymentMethod = 'online'; // 'online' or 'cod'

  // New address form
  bool _showAddAddress = false;
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _line1Ctrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _pincodeCtrl = TextEditingController();

  // Razorpay instance
  late Razorpay _razorpay;
  Map<String, dynamic>? _pendingOrderData; // store for verify call

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _line1Ctrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _pincodeCtrl.dispose();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    // Verify payment with backend
    try {
      final verifyRes = await DioClient().post(
        ApiConstants.paymentsVerify,
        data: {
          'razorpay_order_id': response.orderId,
          'razorpay_payment_id': response.paymentId,
          'razorpay_signature': response.signature,
          'orderData': _pendingOrderData,
        },
      );

      if (verifyRes.data['success'] == true) {
        ref.read(cartProvider.notifier).clearCart();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment successful! Order placed 🎉'),
              backgroundColor: AppColors.success,
            ),
          );
          context.go('/orders');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Payment received but order issue. Payment ID: ${response.paymentId}. Contact support.',
              ),
              backgroundColor: AppColors.warning,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Payment successful! Payment ID: ${response.paymentId}. Order will be confirmed shortly.',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        context.go('/orders');
      }
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: ${response.message ?? 'Unknown error'}'),
          backgroundColor: AppColors.danger,
        ),
      );
      setState(() => _paying = false);
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('External wallet: ${response.walletName}'),
        ),
      );
    }
  }

  Future<void> _applyCoupon() async {
    if (_couponCode.trim().isEmpty) return;
    setState(() => _couponLoading = true);
    try {
      final response = await DioClient().post(
        ApiConstants.couponApply,
        data: {
          'code': _couponCode.trim().toUpperCase(),
          'subtotal': ref.read(cartProvider).subtotal,
        },
      );
      final discount = (response.data['discountAmount'] ??
              response.data['discount'] ??
              0)
          .toDouble();
      setState(() => _couponDiscount = discount);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Coupon applied! You save ${Formatters.price(discount)}'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid coupon code'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      setState(() => _couponLoading = false);
    }
  }

  Future<void> _saveAddress() async {
    try {
      await DioClient().post(
        ApiConstants.addresses,
        data: {
          'name': _nameCtrl.text,
          'phone': _phoneCtrl.text,
          'address': _line1Ctrl.text,
          'city': _cityCtrl.text,
          'state': _stateCtrl.text,
          'pincode': _pincodeCtrl.text,
          'country': 'India',
        },
      );
      ref.invalidate(addressesProvider);
      setState(() => _showAddAddress = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Address saved!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save address'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _handlePay() async {
    if (_selectedAddressId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a delivery address')),
      );
      return;
    }
    setState(() => _paying = true);

    final cart = ref.read(cartProvider);
    final cartItems = cart.items
        .map((i) => {'productId': i.productId, 'quantity': i.quantity})
        .toList();

    try {
      if (_paymentMethod == 'cod') {
        // Get the selected address details
        final addressesAsync = ref.read(addressesProvider);
        final addresses = addressesAsync.valueOrNull ?? [];
        final selectedAddr = addresses.firstWhere(
          (a) => (a['_id'] ?? a['id']) == _selectedAddressId,
          orElse: () => null,
        );

        if (selectedAddr == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Address not found')),
            );
          }
          return;
        }

        // Build items for backend createOrder
        final cart = ref.read(cartProvider);
        final orderItems = cart.items.map((i) => {
          'product': i.productId,
          'name': i.name,
          'price': i.effectivePrice,
          'quantity': i.quantity,
          'image': i.imageUrl ?? '',
        }).toList();

        // COD order using standard POST /orders
        await DioClient().post(
          ApiConstants.orders,
          data: {
            'items': orderItems,
            'shippingAddress': {
              'fullName': selectedAddr['name'] ?? '',
              'phone': selectedAddr['phone'] ?? '',
              'addressLine': selectedAddr['address'] ?? selectedAddr['line1'] ?? '',
              'city': selectedAddr['city'] ?? '',
              'state': selectedAddr['state'] ?? '',
              'pincode': selectedAddr['pincode'] ?? '',
            },
            'paymentMethod': 'cod',
          },
        );
        ref.read(cartProvider.notifier).clearCart();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order placed! Pay on delivery 🎉'),
              backgroundColor: AppColors.success,
            ),
          );
          context.go('/orders');
        }
      } else {
        // Online payment — Razorpay integration
        // Get selected address details
        final addressesAsync = ref.read(addressesProvider);
        final addresses = addressesAsync.valueOrNull ?? [];
        final selectedAddr = addresses.firstWhere(
          (a) => (a['_id'] ?? a['id']) == _selectedAddressId,
          orElse: () => null,
        );

        final cart = ref.read(cartProvider);
        final total = cart.items.fold<double>(
          0, (sum, i) => sum + i.effectivePrice * i.quantity,
        );

        // Build items matching website format
        final itemsForBackend = cart.items.map((i) => {
          '_id': i.productId,
          'name': i.name,
          'price': i.effectivePrice,
          'quantity': i.quantity,
          'images': [i.imageUrl ?? ''],
        }).toList();

        final shippingDetails = {
          'name': selectedAddr?['name'] ?? '',
          'phone': selectedAddr?['phone'] ?? '',
          'address': selectedAddr?['address'] ?? selectedAddr?['line1'] ?? '',
          'city': selectedAddr?['city'] ?? '',
          'state': selectedAddr?['state'] ?? '',
          'pincode': selectedAddr?['pincode'] ?? '',
        };

        // Get user ID from auth
        final authState = ref.read(authProvider);
        final userId = authState.user?.userId;

        // Step 1: Create Razorpay order via backend
        final orderRes = await DioClient().post(
          ApiConstants.paymentsCreate,
          data: {
            'amount': total,
            'items': itemsForBackend,
            'shippingDetails': shippingDetails,
            'userId': userId,
          },
        );

        final razorpayOrderId = orderRes.data['id'];
        final razorpayAmount = orderRes.data['amount'];

        // Store order data for verify callback
        _pendingOrderData = {
          'items': itemsForBackend,
          'totalAmount': total,
          'shippingDetails': shippingDetails,
          'userId': userId,
        };

        final razorpayKey = orderRes.data['keyId'] ?? 'rzp_test_TDJpb2HvvvomV0';
        final parsedAmount = (double.tryParse(razorpayAmount.toString()) ?? 0).round();

        // Step 2: Open Razorpay Checkout
        final options = {
          'key': razorpayKey,
          'amount': parsedAmount,
          'currency': 'INR',
          'order_id': razorpayOrderId,
          'name': 'Lallafy',
          'description': 'Order Payment',
          'prefill': {
            'name': selectedAddr?['name'] ?? '',
            'contact': selectedAddr?['phone'] ?? '',
          },
          'theme': {
            'color': '#3E6B48',
          },
        };

        _razorpay.open(options);
        // Payment result handled by _handlePaymentSuccess / _handlePaymentError callbacks
        return; // Don't set _paying = false here, callbacks handle it
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      setState(() => _paying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final total = cart.total;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
        ),
        title: const Text('Checkout'),
      ),
      body: Column(
        children: [
          // ── Step indicator ──
          _buildStepIndicator(),
          const Divider(height: 1),

          // ── Step content ──
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (_step == 0) _buildAddressStep(),
                if (_step == 1) _buildPaymentStep(total),
              ],
            ),
          ),

          // ── Bottom summary ──
          _buildBottomSummary(cart, total),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Row(
        children: List.generate(_steps.length * 2 - 1, (index) {
          if (index.isOdd) {
            // Connector line
            final stepIndex = index ~/ 2;
            return Expanded(
              child: Container(
                height: 2,
                color: stepIndex < _step
                    ? AppColors.primary
                    : AppColors.border,
              ),
            );
          }
          // Step circle
          final stepIndex = index ~/ 2;
          final isActive = stepIndex <= _step;
          final isDone = stepIndex < _step;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? AppColors.primary : AppColors.bgElevated,
                  border: Border.all(
                    color: isActive ? AppColors.primary : AppColors.border,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: isDone
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : Text(
                          '${stepIndex + 1}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color:
                                isActive ? Colors.white : AppColors.textMuted,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _steps[stepIndex],
                style: AppTextStyles.bodyXs.copyWith(
                  fontWeight:
                      stepIndex == _step ? FontWeight.w600 : FontWeight.w400,
                  color: stepIndex == _step
                      ? AppColors.text
                      : AppColors.textMuted,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // ── Step 0: Address ──
  Widget _buildAddressStep() {
    final addressesAsync = ref.watch(addressesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Delivery Address', style: AppTextStyles.h3),
        const SizedBox(height: 16),

        addressesAsync.when(
          data: (addresses) => Column(
            children: [
              ...addresses.map((a) => _addressCard(a)),
              const SizedBox(height: 12),
              if (!_showAddAddress)
                OutlinedButton.icon(
                  onPressed: () => setState(() => _showAddAddress = true),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add New Address'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusFull),
                    ),
                  ),
                ),
              if (_showAddAddress) _buildAddressForm(),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const Text('Failed to load addresses'),
        ),

        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: AppButton(
            label: 'Continue to Payment →',
            onPressed: _selectedAddressId != null
                ? () => setState(() => _step = 1)
                : null,
            isFullWidth: true,
          ),
        ),
      ],
    );
  }

  Widget _addressCard(dynamic a) {
    final addressId = a['_id'] ?? a['id'];
    final isSelected = _selectedAddressId == addressId;
    return GestureDetector(
      onTap: () => setState(() => _selectedAddressId = addressId),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: isSelected ? AppColors.primary : AppColors.textMuted,
              size: 22,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    a['name'] ?? '',
                    style: AppTextStyles.bodySm
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${a['address'] ?? a['line1'] ?? ''}, ${a['city'] ?? ''}, ${a['state'] ?? ''} ${a['pincode'] ?? ''}',
                    style: AppTextStyles.bodyXs
                        .copyWith(color: AppColors.textMuted),
                  ),
                  Text(
                    'Phone: ${a['phone']}',
                    style: AppTextStyles.bodyXs
                        .copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressForm() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add New Address', style: AppTextStyles.h4),
          const SizedBox(height: 16),
          _formField('Full Name', _nameCtrl),
          _formField('Phone', _phoneCtrl, keyboard: TextInputType.phone),
          _formField('Address Line 1', _line1Ctrl),
          Row(
            children: [
              Expanded(child: _formField('City', _cityCtrl)),
              const SizedBox(width: 12),
              Expanded(child: _formField('State', _stateCtrl)),
            ],
          ),
          _formField('Pincode', _pincodeCtrl,
              keyboard: TextInputType.number),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Save Address',
                  onPressed: _saveAddress,
                  isFullWidth: true,
                ),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: () => setState(() => _showAddAddress = false),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _formField(String label, TextEditingController ctrl,
      {TextInputType keyboard = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  AppTextStyles.bodyXs.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextField(
            controller: ctrl,
            keyboardType: keyboard,
            style: AppTextStyles.bodySm,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.bgSurface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                borderSide: BorderSide(color: AppColors.border),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 1: Gift Options ──
  Widget _buildGiftStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gift Options', style: AppTextStyles.h3),
        const SizedBox(height: 16),

        // Gift wrap toggle
        GestureDetector(
          onTap: () => setState(() => _giftWrap = !_giftWrap),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              border: Border.all(
                color: _giftWrap ? AppColors.primary : AppColors.border,
                width: _giftWrap ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            ),
            child: Row(
              children: [
                Icon(
                  _giftWrap
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                  color:
                      _giftWrap ? AppColors.primary : AppColors.textMuted,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('🎀 Gift Wrapping',
                          style: AppTextStyles.bodySm
                              .copyWith(fontWeight: FontWeight.w600)),
                      Text('Premium eco-friendly wrapping with ribbon',
                          style: AppTextStyles.bodyXs
                              .copyWith(color: AppColors.textMuted)),
                    ],
                  ),
                ),
                Text('+₹50',
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    )),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Gift message
        Text('Gift Message (optional)',
            style:
                AppTextStyles.bodyXs.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          maxLines: 3,
          onChanged: (v) => _giftMessage = v,
          style: AppTextStyles.bodySm,
          decoration: InputDecoration(
            hintText: 'Write a heartfelt message...',
            hintStyle:
                AppTextStyles.bodyXs.copyWith(color: AppColors.textMuted),
            filled: true,
            fillColor: AppColors.bgSurface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              borderSide: BorderSide(color: AppColors.border),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Coupon code
        Text('Coupon Code',
            style:
                AppTextStyles.bodyXs.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: (v) => _couponCode = v.toUpperCase(),
                style: AppTextStyles.bodySm,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'Enter coupon code',
                  hintStyle: AppTextStyles.bodyXs
                      .copyWith(color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.bgSurface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: _couponLoading ? null : _applyCoupon,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppTheme.radiusMd),
                  ),
                ),
                child: Text(_couponLoading ? '...' : 'Apply'),
              ),
            ),
          ],
        ),
        if (_couponDiscount > 0) ...[
          const SizedBox(height: 6),
          Text(
            '✓ Discount applied: ${Formatters.price(_couponDiscount)}',
            style:
                AppTextStyles.bodyXs.copyWith(color: AppColors.success),
          ),
        ],

        const SizedBox(height: 32),
        Row(
          children: [
            OutlinedButton(
              onPressed: () => setState(() => _step = 0),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppTheme.radiusFull),
                ),
              ),
              child: const Text('← Back'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppButton(
                label: 'Continue to Payment →',
                onPressed: () => setState(() => _step = 2),
                isFullWidth: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Step 2: Payment ──
  Widget _buildPaymentStep(double total) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Payment Method', style: AppTextStyles.h3),
        const SizedBox(height: 16),

        // Online payment option
        _paymentOption(
          label: 'Pay Online',
          subtitle: 'UPI, Credit/Debit Card, Net Banking',
          value: 'online',
          color: AppColors.primary,
        ),
        const SizedBox(height: 10),
        _paymentOption(
          label: 'Cash on Delivery',
          subtitle: 'Pay when your order is delivered',
          value: 'cod',
          color: AppColors.success,
        ),
        const SizedBox(height: 16),

        // Info text
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.bgElevated,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          child: Text(
            _paymentMethod == 'online'
                ? '🔒 Your payment info is encrypted and processed securely by Cashfree.'
                : '💡 Pay the delivery person when your order arrives. Please keep exact change ready.',
            style:
                AppTextStyles.bodyXs.copyWith(color: AppColors.textMuted),
          ),
        ),
        const SizedBox(height: 16),

        // Security badges
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['PCI DSS', '256-bit SSL', 'Secure'].map((badge) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.08),
                border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.15)),
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
              child: Text(
                '✓ $badge',
                style: AppTextStyles.bodyXs.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 32),
        Row(
          children: [
            OutlinedButton(
              onPressed: () => setState(() => _step = 0),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppTheme.radiusFull),
                ),
              ),
              child: const Text('← Back'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppButton(
                label: _paying
                    ? 'Processing...'
                    : _paymentMethod == 'cod'
                        ? 'Place Order — ${Formatters.price(total)}'
                        : 'Pay ${Formatters.price(total)}',
                onPressed: _paying ? null : _handlePay,
                isFullWidth: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _paymentOption({
    required String label,
    required String subtitle,
    required String value,
    required Color color,
  }) {
    final isSelected = _paymentMethod == value;
    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.06)
              : AppColors.bgCard,
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? color : AppColors.border,
                  width: isSelected ? 6 : 2,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: AppTextStyles.bodySm
                          .copyWith(fontWeight: FontWeight.w700)),
                  Text(subtitle,
                      style: AppTextStyles.bodyXs
                          .copyWith(color: AppColors.textMuted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSummary(CartState cart, double total) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mini cart preview
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: cart.items.length > 4 ? 5 : cart.items.length,
              separatorBuilder: (_, _) => const SizedBox(width: 6),
              itemBuilder: (_, i) {
                if (i == 4 && cart.items.length > 4) {
                  return Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.bgElevated,
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    child: Center(
                      child: Text(
                        '+${cart.items.length - 4}',
                        style: AppTextStyles.bodyXs
                            .copyWith(color: AppColors.textMuted),
                      ),
                    ),
                  );
                }
                final item = cart.items[i];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  child: item.imageUrl != null
                      ? CachedImage(
                          imageUrl: item.imageUrl!,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 40,
                          height: 40,
                          color: AppColors.bgElevated,
                          child: const Center(
                              child: Text('🎁',
                                  style: TextStyle(fontSize: 14))),
                        ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total',
                  style: AppTextStyles.bodySm
                      .copyWith(fontWeight: FontWeight.w600)),
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
}
