import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/cached_image.dart';
import '../../core/widgets/loading_widget.dart';
import '../../models/product.dart';
import '../../models/cart_item.dart';
import '../../providers/cart_provider.dart';
import '../../providers/homepage_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../providers/auth_provider.dart';

/// Full-screen vertical swipeable Product Reels / Videos Screen
class ReelsScreen extends ConsumerStatefulWidget {
  const ReelsScreen({super.key});

  @override
  ConsumerState<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends ConsumerState<ReelsScreen> {
  late PageController _pageController;
  int _currentIndex = 0;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
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
    final bestSellersAsync = ref.watch(bestSellersProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      body: bestSellersAsync.when(
        data: (allProducts) {
          // Filter products that have a bestseller video clip
          final videoProducts = allProducts
              .where((p) =>
                  p.bestSellerVideo != null &&
                  p.bestSellerVideo!.trim().isNotEmpty)
              .toList();

          final displayList =
              videoProducts.isNotEmpty ? videoProducts : allProducts;

          if (displayList.isEmpty) {
            return const Center(
              child: Text(
                'No Reels Available Right Now 🎬',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            );
          }

          return Stack(
            children: [
              // Vertical PageView Reels Feed
              PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                itemCount: displayList.length,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                itemBuilder: (context, index) {
                  return _SingleReelPage(
                    product: displayList[index],
                    isActive: index == _currentIndex,
                    isMuted: _isMuted,
                    onToggleMute: _toggleMute,
                    totalCount: displayList.length,
                    currentIndex: index,
                  );
                },
              ),

              // Top Title Overlay
              SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go('/home');
                              }
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                color: Colors.black45,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white24),
                              ),
                              child: const Icon(
                                Icons.arrow_back_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF448C),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Lallafy Reels',
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),

                      // Mute / Unmute Button
                      IconButton(
                        onPressed: _toggleMute,
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Icon(
                            _isMuted
                                ? Icons.volume_off_rounded
                                : Icons.volume_up_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const LoadingWidget(message: 'Loading Reels...'),
        error: (_, __) => const Center(
          child: Text(
            'Failed to load Reels',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

/// Single Reel Page Item
class _SingleReelPage extends ConsumerStatefulWidget {
  final Product product;
  final bool isActive;
  final bool isMuted;
  final VoidCallback onToggleMute;
  final int totalCount;
  final int currentIndex;

  const _SingleReelPage({
    required this.product,
    required this.isActive,
    required this.isMuted,
    required this.onToggleMute,
    required this.totalCount,
    required this.currentIndex,
  });

  @override
  ConsumerState<_SingleReelPage> createState() => _SingleReelPageState();
}

class _SingleReelPageState extends ConsumerState<_SingleReelPage>
    with WidgetsBindingObserver {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isDisposing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.isActive) {
      _initVideo();
    }
  }

  @override
  void didUpdateWidget(covariant _SingleReelPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isActive && !oldWidget.isActive) {
      if (_controller == null) {
        _initVideo();
      } else if (_isInitialized) {
        _controller!.play();
      }
    } else if (!widget.isActive && oldWidget.isActive) {
      _controller?.pause();
    }

    if (widget.isMuted != oldWidget.isMuted && _controller != null) {
      _controller!.setVolume(widget.isMuted ? 0.0 : 1.0);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _controller?.pause();
    } else if (state == AppLifecycleState.resumed && widget.isActive) {
      _controller?.play();
    }
  }

  Future<void> _initVideo() async {
    if (_isDisposing || _controller != null) return;
    try {
      final videoUrl = widget.product.bestSellerVideo;
      if (videoUrl == null || videoUrl.trim().isEmpty) return;

      String cleanUrl = videoUrl.trim();
      if (cleanUrl.startsWith('http://')) {
        cleanUrl = cleanUrl.replaceFirst('http://', 'https://');
      }

      final uri = Uri.parse(cleanUrl);
      final controller = VideoPlayerController.networkUrl(uri);
      _controller = controller;

      await controller.initialize();
      if (!mounted || _isDisposing) {
        controller.dispose();
        return;
      }

      await controller.setVolume(widget.isMuted ? 0.0 : 1.0);
      await controller.setLooping(true);

      if (widget.isActive) {
        await controller.play();
      }

      if (mounted && !_isDisposing) {
        setState(() => _isInitialized = true);
      }
    } catch (e) {
      debugPrint("Reel video error: $e");
    }
  }

  @override
  void dispose() {
    _isDisposing = true;
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }

  Future<void> _openProductDetails(BuildContext context, String productId) async {
    _controller?.pause();
    if (mounted) setState(() {});
    await context.push('/product/$productId');
    if (mounted && widget.isActive) {
      _controller?.play();
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final imageUrl = product.images.isNotEmpty ? product.images.first : '';
    final wishlist = ref.watch(wishlistProvider);
    final isWishlisted = wishlist.isWishlisted(product.id);
    final isPaused = _isInitialized && _controller != null && !_controller!.value.isPlaying;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Video / Image Layer with Tap to Play / Pause
        GestureDetector(
          onTap: () {
            if (_controller != null && _isInitialized) {
              if (_controller!.value.isPlaying) {
                _controller!.pause();
              } else {
                _controller!.play();
              }
              setState(() {});
            }
          },
          child: _isInitialized &&
                  _controller != null &&
                  _controller!.value.isInitialized
              ? SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    clipBehavior: Clip.antiAlias,
                    child: SizedBox(
                      width: _controller!.value.size.width,
                      height: _controller!.value.size.height,
                      child: VideoPlayer(_controller!),
                    ),
                  ),
                )
              : CachedImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                ),
        ),

        // Gradient Overlay at Bottom
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black26,
                    Colors.transparent,
                    Colors.black87,
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
        ),

        // Center Play Icon Indicator when Video is Paused
        if (isPaused)
          Center(
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.55),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white38, width: 2),
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 54,
                ),
              ),
            ),
          ),

        // Right Floating Actions (Wishlist, Share)
        Positioned(
          right: 14,
          bottom: 110,
          child: Column(
            children: [
              // Wishlist Heart Button
              IconButton(
                onPressed: () {
                  final auth = ref.read(authProvider);
                  if (!auth.isAuthenticated) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please login to add to wishlist'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    context.push('/login');
                    return;
                  }
                  ref.read(wishlistProvider.notifier).toggle(product);
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isWishlisted
                            ? '${product.name} removed from wishlist'
                            : '${product.name} added to wishlist ❤️',
                      ),
                      backgroundColor: isWishlisted
                          ? Colors.grey
                          : const Color(0xFFFF448C),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                icon: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isWishlisted
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: isWishlisted
                        ? const Color(0xFFFF448C)
                        : Colors.white,
                    size: 24,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Share Button
              IconButton(
                onPressed: () {
                  Share.share(
                    'Check out ${product.name} on Lallafy!\nhttps://lallafy.com/product/${product.slug ?? product.id}',
                  );
                },
                icon: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.share_outlined,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Bottom Left Product Info & CTA Button
        Positioned(
          left: 16,
          right: 70,
          bottom: 100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Product Name (Tappable to view details)
              GestureDetector(
                onTap: () => _openProductDetails(context, product.id),
                child: Text(
                  product.name,
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(height: 6),

              // Price & Discount Row
              Row(
                children: [
                  Text(
                    '₹${product.sellingPrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFFF448C),
                    ),
                  ),
                  if (product.hasDiscount) ...[
                    const SizedBox(width: 8),
                    Text(
                      '₹${product.originalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white60,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF448C),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${product.discountPercent}% OFF',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 12),

              // View Product & Add to Cart Action Buttons
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => _openProductDetails(context, product.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF111827),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'View Details →',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(cartProvider.notifier).addItem(
                            CartItem(
                              productId: product.id,
                              name: product.name,
                              slug: product.slug,
                              price: product.originalPrice,
                              discountPrice: product.sellingPrice,
                              imageUrl: product.primaryImage,
                              storeName: product.storeName ?? 'Lallafy',
                              stock: product.stock,
                              quantity: 1,
                            ),
                          );
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${product.name} added to cart! 🛒'),
                          backgroundColor: const Color(0xFFFF448C),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF448C),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.shopping_cart_outlined, size: 15),
                        SizedBox(width: 4),
                        Text(
                          'Add',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
