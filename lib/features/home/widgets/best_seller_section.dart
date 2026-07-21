import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/cached_image.dart';
import '../../../models/product.dart';
import '../../../providers/homepage_provider.dart';

/// Best Seller Carousel Section — mirrors BestSellerCarousal.jsx from lallafy.com
class BestSellerSection extends ConsumerWidget {
  const BestSellerSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bestSellersAsync = ref.watch(bestSellersProvider);

    return bestSellersAsync.when(
      data: (products) {
        if (products.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: AppTextStyles.h2.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF1A1C23),
                          letterSpacing: -0.5,
                        ),
                        children: const [
                          TextSpan(text: 'Best '),
                          TextSpan(
                            text: 'Sellers',
                            style: TextStyle(color: Color(0xFFFF448C)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Our most loved products that parents and kids are raving about.',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Product Cards Horizontal Scroll ──
              SizedBox(
                height: 340,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  clipBehavior: Clip.none,
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    return _buildBestSellerCard(context, products, index);
                  },
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildBestSellerCard(BuildContext context, List<Product> products, int index) {
    final product = products[index];
    final imageUrl = product.images.isNotEmpty ? product.images.first : '';
    final hasVideo = product.bestSellerVideo != null && product.bestSellerVideo!.isNotEmpty;

    return GestureDetector(
      onTap: () {
        _showVideoModal(context, products, index);
      },
      child: Container(
        width: 210,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // Top Media / Video / Image Area with Best Seller Badge
            SizedBox(
              height: 240,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Product Video or Main Image (Auto-plays by default)
                  if (hasVideo)
                    _AutoLoopVideoPlayer(
                      videoUrl: product.bestSellerVideo!,
                      fallbackImageUrl: imageUrl,
                    )
                  else
                    CachedImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                    ),

                  // "BEST SELLER" Badge top left
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF448C),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF448C).withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Text(
                        'BEST SELLER',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ),

                  // Play Icon Indicator if video is present
                  if (hasVideo)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Circular Thumbnail on the divider
            Transform.translate(
              offset: const Offset(0, -22),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: CachedImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // Title & Price Section
            Transform.translate(
              offset: const Offset(0, -18),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1C23),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '₹${product.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1A1C23),
                          ),
                        ),
                        if (product.originalPrice > product.price) ...[
                          const SizedBox(width: 6),
                          Text(
                            '₹${product.originalPrice.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade400,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVideoModal(BuildContext context, List<Product> products, int initialIndex) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _VideoPlayerModal(
        products: products,
        initialIndex: initialIndex,
      ),
    );
  }
}

/// Auto-playing muted looping video player widget for Bestseller product clips
class _AutoLoopVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String fallbackImageUrl;

  const _AutoLoopVideoPlayer({
    required this.videoUrl,
    required this.fallbackImageUrl,
  });

  @override
  State<_AutoLoopVideoPlayer> createState() => _AutoLoopVideoPlayerState();
}

class _AutoLoopVideoPlayerState extends State<_AutoLoopVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      String cleanUrl = widget.videoUrl.trim();
      if (cleanUrl.startsWith('http://')) {
        cleanUrl = cleanUrl.replaceFirst('http://', 'https://');
      }
      final uri = Uri.parse(cleanUrl);
      _controller = VideoPlayerController.networkUrl(uri);
      await _controller!.initialize();
      await _controller!.setVolume(0); // Mute for autoplay on home card
      await _controller!.setLooping(true);
      await _controller!.play();
      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (e) {
      debugPrint("Best seller video player init error ($e) for ${widget.videoUrl}");
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialized && _controller != null && _controller!.value.isInitialized) {
      return SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            width: _controller!.value.size.width,
            height: _controller!.value.size.height,
            child: VideoPlayer(_controller!),
          ),
        ),
      );
    }
    return CachedImage(
      imageUrl: widget.fallbackImageUrl,
      fit: BoxFit.cover,
    );
  }
}

/// Interactive Slidable Video Modal Popup for Best Seller Product previews (Reels style)
class _VideoPlayerModal extends StatefulWidget {
  final List<Product> products;
  final int initialIndex;

  const _VideoPlayerModal({
    required this.products,
    required this.initialIndex,
  });

  @override
  State<_VideoPlayerModal> createState() => _VideoPlayerModalState();
}

class _VideoPlayerModalState extends State<_VideoPlayerModal> {
  late PageController _pageController;
  late int _currentIndex;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentProduct = widget.products[_currentIndex];

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFF0F1117),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Top Drag Handle Bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white30,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Top Header Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF448C),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'BEST SELLER (${_currentIndex + 1}/${widget.products.length})',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    // Mute / Unmute Button
                    IconButton(
                      icon: Icon(
                        _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: _toggleMute,
                    ),
                    // Close Button
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white, size: 26),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Main Slidable Video PageView with Swipe Up Floating Badge
          Expanded(
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.vertical,
                  onPageChanged: (index) {
                    setState(() => _currentIndex = index);
                  },
                  itemCount: widget.products.length,
                  itemBuilder: (context, index) {
                    final product = widget.products[index];
                    final isCurrent = index == _currentIndex;
                    return _SingleVideoPage(
                      key: ValueKey(product.id),
                      product: product,
                      isCurrent: isCurrent,
                      isMuted: _isMuted,
                    );
                  },
                ),

                // Floating "Swipe Up 👆" indicator overlay
                if (_currentIndex < widget.products.length - 1)
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24, width: 1),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Swipe Up',
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.keyboard_arrow_up_rounded,
                            color: Color(0xFFFF448C),
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Bottom Product Info & View Product Navigation Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF181B24),
              border: Border(top: BorderSide(color: Colors.white10)),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedImage(
                    imageUrl: currentProduct.images.isNotEmpty ? currentProduct.images.first : '',
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentProduct.name,
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            '₹${currentProduct.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFFF448C),
                            ),
                          ),
                          if (currentProduct.originalPrice > currentProduct.price) ...[
                            const SizedBox(width: 6),
                            Text(
                              '₹${currentProduct.originalPrice.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 12,
                                color: Colors.white54,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.push('/product/${currentProduct.id}');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF448C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View Product',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_rounded, size: 16),
                    ],
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

/// Single Page Video Player inside the slidable modal
class _SingleVideoPage extends StatefulWidget {
  final Product product;
  final bool isCurrent;
  final bool isMuted;

  const _SingleVideoPage({
    super.key,
    required this.product,
    required this.isCurrent,
    required this.isMuted,
  });

  @override
  State<_SingleVideoPage> createState() => _SingleVideoPageState();
}

class _SingleVideoPageState extends State<_SingleVideoPage> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isPlaying = true;

  @override
  void initState() {
    super.initState();
    if (widget.isCurrent) {
      _initVideo();
    }
  }

  @override
  void didUpdateWidget(covariant _SingleVideoPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCurrent && !oldWidget.isCurrent) {
      if (_controller == null) {
        _initVideo();
      } else if (_isInitialized) {
        _controller!.play();
        setState(() => _isPlaying = true);
      }
    } else if (!widget.isCurrent && oldWidget.isCurrent) {
      _controller?.pause();
      setState(() => _isPlaying = false);
    }

    if (_controller != null && _isInitialized && widget.isMuted != oldWidget.isMuted) {
      _controller!.setVolume(widget.isMuted ? 0.0 : 1.0);
    }
  }

  Future<void> _initVideo() async {
    final videoUrl = widget.product.bestSellerVideo;
    if (videoUrl == null || videoUrl.isEmpty) return;

    try {
      String cleanUrl = videoUrl.trim();
      if (cleanUrl.startsWith('http://')) {
        cleanUrl = cleanUrl.replaceFirst('http://', 'https://');
      }
      final uri = Uri.parse(cleanUrl);
      _controller = VideoPlayerController.networkUrl(uri);
      await _controller!.initialize();
      await _controller!.setVolume(widget.isMuted ? 0.0 : 1.0);
      await _controller!.setLooping(true);
      if (widget.isCurrent) {
        await _controller!.play();
      }
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isPlaying = widget.isCurrent;
        });
      }
    } catch (e) {
      debugPrint("Single video init error ($e) for ${widget.product.name}");
    }
  }

  void _togglePlayPause() {
    if (_controller != null && _isInitialized) {
      if (_isPlaying) {
        _controller!.pause();
      } else {
        _controller!.play();
      }
      setState(() => _isPlaying = !_isPlaying);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.product.images.isNotEmpty ? widget.product.images.first : '';

    return Stack(
      alignment: Alignment.center,
      fit: StackFit.expand,
      children: [
        if (_isInitialized && _controller != null && _controller!.value.isInitialized)
          GestureDetector(
            onTap: _togglePlayPause,
            child: SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: _controller!.value.size.width,
                  height: _controller!.value.size.height,
                  child: VideoPlayer(_controller!),
                ),
              ),
            ),
          )
        else
          Stack(
            alignment: Alignment.center,
            fit: StackFit.expand,
            children: [
              CachedImage(imageUrl: imageUrl, fit: BoxFit.contain),
              const Center(
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    color: Color(0xFFFF448C),
                    strokeWidth: 3,
                  ),
                ),
              ),
            ],
          ),

        // Play / Pause Overlay Icon
        if (_isInitialized && !_isPlaying)
          GestureDetector(
            onTap: _togglePlayPause,
            child: Container(
              color: Colors.black38,
              child: const Center(
                child: Icon(
                  Icons.play_circle_fill_rounded,
                  color: Colors.white,
                  size: 64,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
