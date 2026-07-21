import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/dio_client.dart';
import '../core/constants/api_constants.dart';

class GstSetting {
  final double percentage;
  final bool isIncluded;

  const GstSetting({
    this.percentage = 18.0,
    this.isIncluded = true,
  });

  factory GstSetting.fromJson(Map<String, dynamic> json) {
    return GstSetting(
      percentage: (json['gstPercentage'] as num?)?.toDouble() ?? 18.0,
      isIncluded: json['isGstIncluded'] as bool? ?? true,
    );
  }
}

/// Fetches global GST settings from backend
final gstSettingProvider = FutureProvider<GstSetting>((ref) async {
  try {
    final response = await DioClient().get('/api/settings');
    if (response.data != null && response.data['success'] == true) {
      return GstSetting.fromJson(response.data);
    }
  } catch (_) {
    // Fallback to default 18% GST (Included)
  }
  return const GstSetting(percentage: 18.0, isIncluded: true);
});
