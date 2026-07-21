import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/cached_image.dart';
import '../../../models/banner.dart' as models;

/// Hero Banner Carousel — mirrors the hero section from HomePage.tsx
class BannerCarousel extends StatefulWidget {
  final List<models.Banner> banners;
  final Function(String link)? onBannerTap;

  const BannerCarousel({
    super.key,
    required this.banners,
    this.onBannerTap,
  });

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: widget.banners.length,
          itemBuilder: (context, index, realIndex) {
            final banner = widget.banners[index];
            return _buildBannerCard(banner);
          },
          options: CarouselOptions(
            height: 180,
            viewportFraction: 0.92,
            enlargeCenterPage: true,
            enlargeFactor: 0.15,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayAnimationDuration: const Duration(milliseconds: 600),
            autoPlayCurve: Curves.easeInOutCubic,
            onPageChanged: (index, reason) {
              setState(() => _currentIndex = index);
            },
          ),
        ),
        const SizedBox(height: 14),
        // Dot indicators
        AnimatedSmoothIndicator(
          activeIndex: _currentIndex,
          count: widget.banners.length,
          effect: ExpandingDotsEffect(
            dotWidth: 7,
            dotHeight: 7,
            activeDotColor: AppColors.primary,
            dotColor: AppColors.bgElevated,
            spacing: 5,
            expansionFactor: 3,
          ),
        ),
      ],
    );
  }

  Widget _buildBannerCard(models.Banner banner) {
    final bgColor = _parseColor(banner.bgColor);

    return GestureDetector(
      onTap: () {
        if (banner.link != null && widget.onBannerTap != null) {
          widget.onBannerTap!(banner.link!);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          boxShadow: AppColors.shadowSm,
        ),
        clipBehavior: Clip.antiAlias,
        child: banner.isImageOnly
            ? _buildImageOnlyBanner(banner)
            : _buildTextImageBanner(banner, bgColor),
      ),
    );
  }

  Widget _buildImageOnlyBanner(models.Banner banner) {
    return CachedImage(
      imageUrl: banner.imageUrl,
      width: double.infinity,
      height: 180,
      fit: BoxFit.fill,
    );
  }

  Widget _buildTextImageBanner(models.Banner banner, Color bgColor) {
    final textColor = _parseColor(banner.textColor ?? '#1b1b1b');
    final btnColor = _parseColor(banner.buttonColor ?? '#516f2c');
    final btnTextColor = _parseColor(banner.btnTextColor ?? '#ffffff');

    return Row(
      children: [
        // Left half — text content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (banner.label != null) ...[
                  Text(
                    banner.label!,
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: textColor.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                Text(
                  banner.title ?? '',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                    color: textColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (banner.subtitle != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    banner.subtitle!,
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 11,
                      color: textColor.withValues(alpha: 0.75),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (banner.buttonText != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 7),
                    decoration: BoxDecoration(
                      color: btnColor,
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusFull),
                    ),
                    child: Text(
                      banner.buttonText!,
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: btnTextColor,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        // Right half — image
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: CachedImage(
              imageUrl: banner.imageUrl,
              height: 180,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }

  Color _parseColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }
}
