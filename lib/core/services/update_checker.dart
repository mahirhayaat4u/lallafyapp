import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/api_constants.dart';
import '../constants/app_constants.dart';
import '../network/dio_client.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

/// In-App Update Checker
///
/// Checks the backend for the latest app version on startup.
/// If a newer version is available, shows a dialog prompting the user
/// to download the updated APK from GitHub Releases.
class UpdateChecker {
  UpdateChecker._();

  /// Check for updates and show dialog if needed
  static Future<void> check(BuildContext context) async {
    try {
      final response = await DioClient().get(ApiConstants.appVersion);
      final data = response.data['data'];

      if (data == null) return;

      final latestVersion = data['latestVersion'] as String? ?? '';
      final minVersion = data['minVersion'] as String? ?? '';
      final downloadUrl = data['downloadUrl'] as String? ?? '';
      final changelog = data['changelog'] as String? ?? '';
      final forceUpdate = data['forceUpdate'] as bool? ?? false;

      if (latestVersion.isEmpty || downloadUrl.isEmpty) return;

      final currentVersion = AppConstants.appVersion;

      // Compare versions
      final needsUpdate = _isNewer(latestVersion, currentVersion);
      final isBelowMin = _isNewer(minVersion, currentVersion);

      if (!needsUpdate) return;

      // Must update (below minimum version or force flag)
      if (isBelowMin || forceUpdate) {
        if (context.mounted) {
          _showUpdateDialog(
            context,
            latestVersion: latestVersion,
            changelog: changelog,
            downloadUrl: downloadUrl,
            isForced: true,
          );
        }
        return;
      }

      // Optional update
      if (context.mounted) {
        _showUpdateDialog(
          context,
          latestVersion: latestVersion,
          changelog: changelog,
          downloadUrl: downloadUrl,
          isForced: false,
        );
      }
    } catch (_) {
      // Silently fail — don't block app if version check fails
    }
  }

  /// Compare two semantic versions: returns true if [a] is newer than [b]
  static bool _isNewer(String a, String b) {
    if (a.isEmpty || b.isEmpty) return false;
    final aParts = a.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final bParts = b.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    // Pad to same length
    while (aParts.length < 3) aParts.add(0);
    while (bParts.length < 3) bParts.add(0);

    for (int i = 0; i < 3; i++) {
      if (aParts[i] > bParts[i]) return true;
      if (aParts[i] < bParts[i]) return false;
    }
    return false; // Equal
  }

  /// Show the update dialog
  static void _showUpdateDialog(
    BuildContext context, {
    required String latestVersion,
    required String changelog,
    required String downloadUrl,
    required bool isForced,
  }) {
    showDialog(
      context: context,
      barrierDismissible: !isForced,
      builder: (ctx) => PopScope(
        canPop: !isForced,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          ),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.system_update_rounded,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  isForced ? 'Update Required' : 'Update Available',
                  style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),

                // Version info
                Text(
                  'Version $latestVersion is available',
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 12),

                // Changelog
                if (changelog.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.bgSurface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    child: Text(
                      changelog,
                      style: AppTextStyles.bodyXs.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Update button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _openDownloadUrl(downloadUrl),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusFull),
                      ),
                    ),
                    child: const Text(
                      'Update Now',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),

                // Skip button (only for optional updates)
                if (!isForced) ...[
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text(
                      'Maybe Later',
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Open the APK download URL in browser
  static Future<void> _openDownloadUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
