import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/app_button.dart';

/// Addresses provider
final addressesProvider = FutureProvider<List<dynamic>>((ref) async {
  final response = await DioClient().get(ApiConstants.addresses);
  final data = response.data;
  final rawAddresses = data['addresses'] ??
      (data['data'] is Map ? data['data']['addresses'] : null) ??
      data['data'] ??
      [];
  return rawAddresses as List<dynamic>;
});

class AddressesScreen extends ConsumerStatefulWidget {
  const AddressesScreen({super.key});

  @override
  ConsumerState<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends ConsumerState<AddressesScreen> {
  bool _actionLoading = false;

  Future<void> _deleteAddress(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Address'),
        content: const Text('Are you sure you want to delete this address?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _actionLoading = true);
    try {
      await DioClient().delete(ApiConstants.address(id));
      ref.invalidate(addressesProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Address deleted!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _actionLoading = false);
    }
  }

  Future<void> _setDefaultAddress(String id) async {
    setState(() => _actionLoading = true);
    try {
      await DioClient().put(ApiConstants.addressDefault(id));
      ref.invalidate(addressesProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Default address updated!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _actionLoading = false);
    }
  }

  void _openAddressForm({dynamic address}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddressFormBottomSheet(
        address: address,
        onSaved: () => ref.invalidate(addressesProvider),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final addressesAsync = ref.watch(addressesProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
        ),
        title: const Text('Saved Addresses'),
        actions: [
          IconButton(
            onPressed: () => _openAddressForm(),
            icon: const Icon(Icons.add_rounded, size: 26, color: AppColors.primary),
          ),
        ],
      ),
      body: Stack(
        children: [
          addressesAsync.when(
            data: (addresses) {
              if (addresses.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('📍', style: TextStyle(fontSize: 64)),
                        const SizedBox(height: 16),
                        Text('No Addresses Saved', style: AppTextStyles.h3),
                        const SizedBox(height: 8),
                        Text(
                          'Add your delivery addresses to checkout faster.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 24),
                        AppButton(
                          label: 'Add Address',
                          onPressed: () => _openAddressForm(),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: addresses.length,
                itemBuilder: (context, index) {
                  final addr = addresses[index];
                  final isDefault = addr['isDefault'] == true;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      border: Border.all(
                        color: isDefault ? AppColors.primary : AppColors.border,
                        width: isDefault ? 1.5 : 1.0,
                      ),
                      boxShadow: isDefault ? AppColors.shadowSm : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              addr['name'] ?? '',
                              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
                            ),
                            if (isDefault)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                                ),
                                child: Text(
                                  'Default',
                                  style: AppTextStyles.bodyXs.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          addr['line1'] ?? '',
                          style: AppTextStyles.bodySm,
                        ),
                        Text(
                          '${addr['city'] ?? ''}, ${addr['state'] ?? ''} - ${addr['pincode'] ?? ''}',
                          style: AppTextStyles.bodySm,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Phone: ${addr['phone'] ?? ''}',
                          style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (!isDefault) ...[
                              TextButton(
                                onPressed: () => _setDefaultAddress(addr['id']),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                child: Text(
                                  'Set as Default',
                                  style: AppTextStyles.bodyXs.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            TextButton.icon(
                              onPressed: () => _openAddressForm(address: addr),
                              icon: const Icon(Icons.edit_outlined, size: 14, color: AppColors.textMuted),
                              label: Text(
                                'Edit',
                                style: AppTextStyles.bodyXs.copyWith(
                                  color: AppColors.text,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: () => _deleteAddress(addr['id']),
                              icon: const Icon(Icons.delete_outline_rounded, size: 14, color: AppColors.danger),
                              label: Text(
                                'Delete',
                                style: AppTextStyles.bodyXs.copyWith(
                                  color: AppColors.danger,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            loading: () => const LoadingWidget(message: 'Loading addresses...'),
            error: (err, _) => Center(
              child: Text(
                'Failed to load addresses: $err',
                style: AppTextStyles.bodySm.copyWith(color: AppColors.danger),
              ),
            ),
          ),
          if (_actionLoading)
            Positioned.fill(
              child: Container(
                color: Colors.white24,
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AddressFormBottomSheet extends StatefulWidget {
  final dynamic address;
  final VoidCallback onSaved;

  const _AddressFormBottomSheet({this.address, required this.onSaved});

  @override
  State<_AddressFormBottomSheet> createState() => _AddressFormBottomSheetState();
}

class _AddressFormBottomSheetState extends State<_AddressFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _line1Ctrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _stateCtrl;
  late final TextEditingController _pincodeCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final addr = widget.address;
    _nameCtrl = TextEditingController(text: addr?['name'] ?? '');
    _phoneCtrl = TextEditingController(text: addr?['phone'] ?? '');
    _line1Ctrl = TextEditingController(text: addr?['line1'] ?? '');
    _cityCtrl = TextEditingController(text: addr?['city'] ?? '');
    _stateCtrl = TextEditingController(text: addr?['state'] ?? '');
    _pincodeCtrl = TextEditingController(text: addr?['pincode'] ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _line1Ctrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _pincodeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final data = {
        'name': _nameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'line1': _line1Ctrl.text.trim(),
        'city': _cityCtrl.text.trim(),
        'state': _stateCtrl.text.trim(),
        'pincode': _pincodeCtrl.text.trim(),
        'country': 'India',
      };

      if (widget.address != null) {
        // Edit existing
        final id = widget.address['id'];
        await DioClient().put(ApiConstants.address(id), data: data);
      } else {
        // Create new
        await DioClient().post(ApiConstants.addresses, data: data);
      }

      widget.onSaved();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.address != null ? 'Address updated!' : 'Address saved!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.address != null ? 'Edit Address' : 'Add New Address',
                    style: AppTextStyles.h3,
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _formField('Full Name', _nameCtrl, 'Name is required'),
              _formField('Phone', _phoneCtrl, 'Phone is required', keyboard: TextInputType.phone),
              _formField('Address Line 1', _line1Ctrl, 'Address is required'),
              Row(
                children: [
                  Expanded(child: _formField('City', _cityCtrl, 'Required')),
                  const SizedBox(width: 12),
                  Expanded(child: _formField('State', _stateCtrl, 'Required')),
                ],
              ),
              _formField('Pincode', _pincodeCtrl, 'Pincode is required', keyboard: TextInputType.number),
              const SizedBox(height: 24),
              AppButton(
                label: _saving ? 'Saving...' : 'Save Address',
                onPressed: _saving ? null : _submit,
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _formField(
    String label,
    TextEditingController ctrl,
    String? validationMsg, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyXs.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: ctrl,
            keyboardType: keyboard,
            style: AppTextStyles.bodySm,
            validator: (value) {
              if (validationMsg != null && (value == null || value.trim().isEmpty)) {
                return validationMsg;
              }
              return null;
            },
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
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
