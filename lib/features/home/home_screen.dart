import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/error_widget.dart';
import '../../core/widgets/app_drawer.dart';
import '../../providers/auth_provider.dart';
import '../../providers/homepage_provider.dart';
import '../../providers/cart_provider.dart';
import '../../models/category.dart';
import '../../models/homepage_card.dart';
import '../../models/age_group.dart';

import 'widgets/banner_carousel.dart';
import 'widgets/category_circles.dart';
import 'widgets/homepage_section.dart';
import 'widgets/product_card.dart';
import 'widgets/birthday_special_section.dart';
import 'widgets/best_seller_section.dart';
import 'widgets/magic_of_gifting_section.dart';
import 'widgets/my_first_year_section.dart';
import 'widgets/trending_toys_section.dart';
import 'widgets/skill_development_section.dart';
import 'widgets/customer_review_section.dart';
import 'widgets/why_trust_lallafy_section.dart';
import 'widgets/faq_section.dart';
import 'widgets/musical_toys_section.dart';
import 'widgets/occasion_tabs_section.dart';
import 'widgets/gifting_stories_section.dart';
import 'widgets/relationship_section.dart';

/// Home Screen — The real homepage with API-driven content
///
/// 💡 Mirrors HomePage.tsx layout:
/// 1. Categories quicklinks
/// 2. Hero banner carousel
/// 3. Birthday Special (banner + grid)
/// 4. Featured products
/// 5. Flower cards section
/// 6. Occasion Tabs (tabbed product carousel)
/// 7. Gifting Stories (Instagram-style)
/// 8. Relationship cards section
/// 9. Luxury cards section
/// 10. Personalize cards section
/// 11. Combo cards section
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // Animation controller for smooth curve movement
  late AnimationController _curveAnimController;
  late Animation<double> _curveAnimation;

  // Track tab positions: key = tab index, value = (left, width)
  final Map<int, _TabMetrics> _tabMetrics = {};
  double _currentCurveLeft = 0;
  double _currentCurveWidth = 80;
  double _targetCurveLeft = 0;
  double _targetCurveWidth = 80;

  // ScrollController for the tab ListView
  final ScrollController _tabScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _curveAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _curveAnimation = CurvedAnimation(
      parent: _curveAnimController,
      curve: Curves.easeInOut,
    );
    _curveAnimController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _curveAnimController.dispose();
    _tabScrollController.dispose();
    super.dispose();
  }

  /// Animate curve to a specific tab
  void _animateToTab(int index, List<Category> categories) {
    final metrics = _tabMetrics[index];
    if (metrics == null) return;

    _currentCurveLeft = _animatedCurveLeft;
    _currentCurveWidth = _animatedCurveWidth;
    _targetCurveLeft = metrics.left;
    _targetCurveWidth = metrics.width;

    _curveAnimController.reset();
    _curveAnimController.forward();

    // Update selected index in provider
    ref.read(selectedCategoryIndexProvider.notifier).state = index;

    // Auto-scroll the tab into view
    _scrollTabIntoView(index);
  }

  void _scrollTabIntoView(int index) {
    final metrics = _tabMetrics[index];
    if (metrics == null || !_tabScrollController.hasClients) return;

    final viewportWidth = _tabScrollController.position.viewportDimension;
    final scrollOffset = _tabScrollController.offset;
    final tabLeft = metrics.left;
    final tabRight = metrics.left + metrics.width;

    if (tabLeft < scrollOffset) {
      _tabScrollController.animateTo(
        tabLeft,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (tabRight > scrollOffset + viewportWidth) {
      _tabScrollController.animateTo(
        tabRight - viewportWidth + 24,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  double get _animatedCurveLeft {
    if (!_curveAnimController.isAnimating && _curveAnimController.isCompleted) {
      return _targetCurveLeft;
    }
    return _currentCurveLeft +
        (_targetCurveLeft - _currentCurveLeft) * _curveAnimation.value;
  }

  double get _animatedCurveWidth {
    if (!_curveAnimController.isAnimating && _curveAnimController.isCompleted) {
      return _targetCurveWidth;
    }
    return _currentCurveWidth +
        (_targetCurveWidth - _currentCurveWidth) * _curveAnimation.value;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final cartItems = ref.watch(cartProvider).totalItems;
    final selectedIndex = ref.watch(selectedCategoryIndexProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.bg,
      drawer: const AppDrawer(),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.invalidate(bannersProvider);
            ref.invalidate(categoriesProvider);
            ref.invalidate(featuredProductsProvider);
            ref.invalidate(flowerCardsProvider);
            ref.invalidate(relationshipCardsProvider);
            ref.invalidate(luxuryCardsProvider);
            ref.invalidate(personalizeCardsProvider);
            ref.invalidate(comboCardsProvider);
            ref.invalidate(occasionTabsProvider);
            ref.invalidate(giftingStoriesProvider);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── Sticky Header ──
              SliverToBoxAdapter(
                child: _buildHeader(context, ref, authState, cartItems, categoriesAsync, selectedIndex),
              ),

              // ── Body Sections ──
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),

                    // ── 1. Hero banner carousel (Top) ──
                    _BannersSection(),

                    const SizedBox(height: 16),

                    // ── 2. Shop by Category (Dynamic Age Groups from backend) ──
                    const _ShopByCategorySection(),

                    const SizedBox(height: 24),

                    // ── 3. Shop by Price ──
                    const _ShopByPriceSection(),

                    const SizedBox(height: 24),

              // ── 4. Shop by Category (Root categories from DB) ──
              const BirthdaySpecialSection(),

              const SizedBox(height: 24),

              // ── 5. Best Sellers Section (from BestSellerCarousal.jsx) ──
              const BestSellerSection(),

              const SizedBox(height: 24),

              // ── 6. Magic of Gifting Section (from MagicOfGifting.jsx / Admin SectionBanner) ──
              const MagicOfGiftingSection(),

              const SizedBox(height: 24),

              // ── 7. My First Toy Section (from Myfirstyear.jsx / Admin SectionBanner / ageGroup=0–1 Years) ──
              const MyFirstYearSection(),

              const SizedBox(height: 24),

              // ── 8. Trending Toys Section (from TrendingToys.jsx / Admin SectionBanner / section=trending) ──
              const TrendingToysSection(),

              const SizedBox(height: 24),

              // ── 9. Skill Development Section (from SkillDevelopment.jsx / Admin SectionBanner / section=skill) ──
              const SkillDevelopmentSection(),

              const SizedBox(height: 24),

              // ── 10. Musical Toys Section (from MusicalToys.jsx / Admin SectionBanner / section=musical) ──
              const MusicalToysSection(),

              const SizedBox(height: 24),

              // ── 11. Customer Reviews Section (from CustomerReview.jsx / GET /api/reviews/homepage) ──
              const CustomerReviewSection(),

              const SizedBox(height: 24),

              // ── 12. Why Trust Lallafy? Section (from Home.jsx) ──
              const WhyTrustLallafySection(),

              const SizedBox(height: 24),

              // ── 13. FAQ Section (from FAQ.jsx / FaqSection) ──
              const FaqSection(),

              const SizedBox(height: 24),

              // ── 6. Featured / Trending Products ──
              _FeaturedProductsSection(),

              const SizedBox(height: 32),

                    // ── Old components commented out (to be updated according to Lallafy) ──
                    /*
                    // ── 5. Flower Cards ──
                    _HomepageCardsSection(
                      provider: flowerCardsProvider,
                      label: 'Fresh Blooms',
                      title: 'Beautiful Flower Arrangements',
                      subtitle: 'Hand-picked flowers for every occasion',
                    ),

                    const SizedBox(height: 32),

                    // ── 6. Occasion Tabs ──
                    const OccasionTabsSection(),

                    const SizedBox(height: 32),

                    // ── 7. Gifting Stories ──
                    const GiftingStoriesSection(),

                    const SizedBox(height: 32),

                    // ── 8. Relationship Cards ──
                    const RelationshipSection(),

                    const SizedBox(height: 32),

                    // ── 9. Luxury Cards ──
                    _HomepageCardsSection(
                      provider: luxuryCardsProvider,
                      label: 'Premium Collection',
                      title: 'Explore Luxury Gifts',
                      subtitle: 'Curated premium selections',
                      cardHeight: 220,
                    ),

                    const SizedBox(height: 32),

                    // ── 10. Personalize Cards ──
                    _HomepageCardsSection(
                      provider: personalizeCardsProvider,
                      label: 'Make It Special',
                      title: 'Personalized Gifts',
                      subtitle: 'Add a personal touch',
                    ),

                    const SizedBox(height: 32),

                    // ── 11. Combo Cards ──
                    _HomepageCardsSection(
                      provider: comboCardsProvider,
                      label: 'Gift Together',
                      title: 'Combo Gift Sets',
                      subtitle: 'More value, more joy',
                    ),
                    */

                    const SizedBox(height: 30),

              // ── Footer ──
              _buildFooter(context),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    ),
  ),
),
);
  }


  Widget _buildHeader(BuildContext context, WidgetRef ref, dynamic authState, int cartItems, AsyncValue<List<Category>> categoriesAsync, int selectedIndex) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Row 1: Hamburger Menu (Left) | Centered Logo | Wishlist & Cart (Right) ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Hamburger Menu Icon
                IconButton(
                  icon: const Icon(Icons.menu_rounded, color: Colors.black87, size: 28),
                  onPressed: () {
                    _scaffoldKey.currentState?.openDrawer();
                  },
                ),

                // Centered Logo
                Image.asset(
                  'assets/images/lallafy.png',
                  height: 46,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Text(
                      'Lallafy',
                      style: AppTextStyles.h2.copyWith(
                        color: const Color(0xFFE91E63),
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),

                // Right Actions: Wishlist & Cart
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Wishlist Icon
                    IconButton(
                      icon: const Icon(Icons.favorite_border_rounded, color: Colors.black87, size: 25),
                      onPressed: () => context.push('/wishlist'),
                    ),

                    // Cart Icon with Pink Badge
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black87, size: 25),
                          onPressed: () => context.go('/cart'),
                        ),
                        if (cartItems > 0)
                          Positioned(
                            right: 4,
                            top: 4,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: Color(0xFFE91E63),
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 17,
                                minHeight: 17,
                              ),
                              child: Text(
                                '$cartItems',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // --- Row 2: Search Bar with Pink Rounded Right Button ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: () => context.push('/search'),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Search for toys, gifts & more...',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Pink Search Button
                    Container(
                      height: 48,
                      width: 52,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE91E63),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(23),
                          bottomRight: Radius.circular(23),
                        ),
                      ),
                      child: const Icon(
                        Icons.search_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Widget _buildAnimatedTabBar(BuildContext context, List<Category> categories, int selectedIndex) {
    // Clamp selectedIndex to valid range
    final safeIndex = selectedIndex.clamp(0, categories.length - 1);

    return SizedBox(
      height: 38,
      child: Stack(
        children: [
          // Bottom Pink Line (stays fixed under the scroll view)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 1.5,
              color: const Color(0xFFEF476F),
            ),
          ),

          // Scrollable area (spans full screen width)
          Positioned.fill(
            child: SingleChildScrollView(
              controller: _tabScrollController,
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Animated Curve Indicator (inside scroll view so it scrolls with the tabs)
                  Positioned(
                    bottom: 0,
                    left: _animatedCurveLeft,
                    child: SizedBox(
                      width: _animatedCurveWidth,
                      height: 38,
                      child: CustomPaint(
                        painter: TabCurvePainter(
                          strokeColor: const Color(0xFFEF476F),
                          fillColor: Colors.white,
                          R: 24,
                          strokeWidth: 1.5,
                        ),
                      ),
                    ),
                  ),

                  // Tab items Row with end padding
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(categories.length, (index) {
                        final cat = categories[index];
                        final isActive = index == safeIndex;
                        return _TabMeasurer(
                          index: index,
                          onMeasured: (left, width) {
                            final newMetrics = _TabMetrics(left: left, width: width);
                            if (_tabMetrics[index] != newMetrics) {
                              _tabMetrics[index] = newMetrics;
                              // Set initial position for first tab
                              if (index == safeIndex && !_curveAnimController.isCompleted && !_curveAnimController.isAnimating) {
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  if (mounted) {
                                    setState(() {
                                      _currentCurveLeft = left;
                                      _currentCurveWidth = width;
                                      _targetCurveLeft = left;
                                      _targetCurveWidth = width;
                                    });
                                  }
                                });
                              }
                            }
                          },
                          child: GestureDetector(
                            onTap: () => _animateToTab(index, categories),
                            child: Container(
                              margin: const EdgeInsets.only(right: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              alignment: Alignment.center,
                              child: Text(
                                cat.name.toUpperCase(),
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1.2,
                                  color: isActive
                                      ? const Color(0xFF0F172A)
                                      : const Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.pagePadding),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
      ),
      child: Column(
        children: [
          Image.asset(
            'assets/images/giftswale.jpg',
            height: 48,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.card_giftcard_rounded,
              size: 32,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text('GiftsWale', style: AppTextStyles.h3),
          const SizedBox(height: 4),
          Text(
            'Gift Your Loved Ones ❤️',
            style:
                AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

// ─── Tab Metrics Helper ─────────────────────────────────────────

/// Stores the measured position and width of a tab
class _TabMetrics {
  final double left;
  final double width;

  const _TabMetrics({required this.left, required this.width});

  @override
  bool operator ==(Object other) =>
      other is _TabMetrics && other.left == left && other.width == width;

  @override
  int get hashCode => Object.hash(left, width);
}

/// Measures a tab's position after layout and reports it
class _TabMeasurer extends StatefulWidget {
  final int index;
  final void Function(double left, double width) onMeasured;
  final Widget child;

  const _TabMeasurer({
    required this.index,
    required this.onMeasured,
    required this.child,
  });

  @override
  State<_TabMeasurer> createState() => _TabMeasurerState();
}

class _TabMeasurerState extends State<_TabMeasurer> {
  final GlobalKey _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  @override
  void didUpdateWidget(covariant _TabMeasurer oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  void _measure() {
    final renderBox = _key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    // Get position relative to the Stack (the tab bar)
    final stackRenderBox = context.findAncestorRenderObjectOfType<RenderStack>();
    if (stackRenderBox == null) return;

    final offset = renderBox.localToGlobal(Offset.zero, ancestor: stackRenderBox);
    widget.onMeasured(offset.dx, renderBox.size.width);
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: _key,
      child: widget.child,
    );
  }
}

// ─── Private Section Widgets ─────────────────────────────────────

/// Shows subcategories (children) of the selected parent category
class _SubcategoriesSection extends ConsumerWidget {
  final int selectedIndex;

  const _SubcategoriesSection({required this.selectedIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return categoriesAsync.when(
      data: (categories) {
        if (categories.isEmpty) return const SizedBox.shrink();
        final safeIndex = selectedIndex.clamp(0, categories.length - 1);
        final parentCategory = categories[safeIndex];
        final children = parentCategory.children;

        if (children.isEmpty) {
          // No subcategories — show nothing or a subtle message
          return const SizedBox.shrink();
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
              child: child,
            ),
          ),
          child: CategoryCircles(
            key: ValueKey(parentCategory.id),
            categories: children,
            onCategoryTap: (slug) {
              context.push('/shop?category=$slug');
            },
          ),
        );
      },
      loading: () => const SizedBox(
        height: 110,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}


class _BannersSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bannersAsync = ref.watch(bannersProvider);

    return bannersAsync.when(
      data: (banners) => BannerCarousel(
        banners: banners,
        onBannerTap: (link) {
          context.push(link ?? '/shop');
        },
      ),
      loading: () => Container(
        height: 180,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.bgElevated,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 2,
          ),
        ),
      ),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _FeaturedProductsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(featuredProductsProvider);

    return productsAsync.when(
      data: (products) {
        if (products.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.pagePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TRENDING NOW',
                    style: AppTextStyles.sectionLabel,
                  ),
                  const SizedBox(height: 4),
                  Text('Featured Gifts', style: AppTextStyles.h2),
                  const SizedBox(height: 4),
                  Text(
                    'Most loved by our customers',
                    style: AppTextStyles.bodySm
                        .copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.pagePadding),
                itemCount: products.length,
                separatorBuilder: (_, _) => const SizedBox(width: 14),
                itemBuilder: (context, index) => ProductCard(
                  product: products[index],
                  onTap: () {
                    context.push('/product/${products[index].id}');
                  },
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox(
        height: 300,
        child: LoadingWidget(message: 'Loading gifts...'),
      ),
      error: (err, _) => ErrorDisplayWidget(
        message: err.toString(),
        onRetry: () => ref.invalidate(featuredProductsProvider),
      ),
    );
  }
}

class _HomepageCardsSection extends ConsumerWidget {
  final FutureProvider<List<HomepageCard>> provider;
  final String label;
  final String title;
  final String? subtitle;
  final double cardHeight;

  const _HomepageCardsSection({
    required this.provider,
    required this.label,
    required this.title,
    this.subtitle,
    this.cardHeight = 200,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsAsync = ref.watch(provider);

    return cardsAsync.when(
      data: (cards) {
        if (cards.isEmpty) return const SizedBox.shrink();
        return HomepageSection(
          label: label,
          title: title,
          subtitle: subtitle,
          cards: cards,
          cardHeight: cardHeight,
          onCardTap: (link, cardTitle) {
            String route = link;
            if (route.startsWith('/shop')) {
              final uri = Uri.parse(route);
              final queryParams = Map<String, String>.from(uri.queryParameters);
              queryParams['title'] = cardTitle;
              route = Uri(path: uri.path, queryParameters: queryParams).toString();
            }
            context.push(route);
          },
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _AnimatedSearchHint extends StatefulWidget {
  const _AnimatedSearchHint();

  @override
  State<_AnimatedSearchHint> createState() => _AnimatedSearchHintState();
}

class _AnimatedSearchHintState extends State<_AnimatedSearchHint> {
  final List<String> _hints = [
    'Search for gifts...',
    'Search for flowers...',
    'Search for cakes...'
  ];
  int _currentIndex = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 2500), (timer) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _hints.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.4),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            )),
            child: child,
          ),
        );
      },
      child: Align(
        key: ValueKey<int>(_currentIndex),
        alignment: Alignment.centerLeft,
        child: Text(
          _hints[_currentIndex],
          style: AppTextStyles.body.copyWith(
            color: const Color(0xFF5E5E6A),
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class TabCurvePainter extends CustomPainter {
  final Color strokeColor;
  final Color fillColor;
  final double strokeWidth;
  final double R;

  TabCurvePainter({
    required this.strokeColor,
    required this.fillColor,
    this.strokeWidth = 1.5,
    this.R = 24,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double strokeW = strokeWidth;
    final double bottomY = size.height - strokeW / 2; // 37.25 (exact center of the 1.5px baseline)
    final double topY = strokeW / 2; // 0.75 (exact center of the 1.5px top stroke)
    final double W = size.width - 2 * R;

    // 1. Draw the fill for the active tab curve to mask the pink line beneath it
    final fillPath = Path();
    fillPath.moveTo(0, size.height); // Start at bottom-left corner of this curve's bounding box
    
    // Left side: baseline -> top
    fillPath.cubicTo(
      R * 0.55, bottomY,
      R * 0.15, topY,
      R, topY,
    );
    
    // Flat top
    fillPath.lineTo(R + W, topY);
    
    // Right side: top -> baseline
    fillPath.cubicTo(
      R + W + R * 0.85, topY,
      R + W + R * 0.45, bottomY,
      2 * R + W, bottomY, // which is size.width
    );
    
    // Bottom-right corner of this curve's bounding box
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill,
    );

    // 2. Draw the stroke for the curve
    final strokePath = Path();
    strokePath.moveTo(0, bottomY);
    
    // Left side
    strokePath.cubicTo(
      R * 0.55, bottomY,
      R * 0.15, topY,
      R, topY,
    );
    
    // Flat top
    strokePath.lineTo(R + W, topY);
    
    // Right side
    strokePath.cubicTo(
      R + W + R * 0.85, topY,
      R + W + R * 0.45, bottomY,
      2 * R + W, bottomY,
    );

    canvas.drawPath(
      strokePath,
      Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant TabCurvePainter oldDelegate) {
    return oldDelegate.strokeColor != strokeColor ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.R != R;
  }
}

// ─── Shop by Category Section (Dynamic Age Groups from backend) ────────────
class _ShopByCategorySection extends ConsumerWidget {
  const _ShopByCategorySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ageGroupsAsync = ref.watch(ageGroupsProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Shop by Category',
                style: AppTextStyles.h2.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
              GestureDetector(
                onTap: () => context.go('/categories'),
                child: Row(
                  children: [
                    Text(
                      'View All',
                      style: AppTextStyles.caption.copyWith(
                        color: const Color(0xFFE91E63),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Color(0xFFE91E63),
                      size: 14,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ageGroupsAsync.when(
            data: (ageGroups) => _buildAgeGrid(context, ageGroups),
            loading: () => const SizedBox(
              height: 110,
              child: Center(child: CircularProgressIndicator(color: Color(0xFFE91E63), strokeWidth: 2)),
            ),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildAgeGrid(BuildContext context, List<AgeGroup> ageGroups) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: ageGroups.take(4).map((item) {
        final bg = _parseColor(item.bgColor, fallback: const Color(0xFFF3F4F6));
        final border = _parseColor(item.borderColor, fallback: const Color(0xFF9CA3AF));
        final textCol = _parseColor(item.textColor, fallback: const Color(0xFF1F2937));

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: GestureDetector(
              onTap: () => context.push('/shop?ageGroup=${Uri.encodeComponent(item.label)}'),
              child: SizedBox(
                height: 96,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.topCenter,
                  children: [
                    // Card Container (positioned lower so top avatar floats over top border)
                    Positioned.fill(
                      top: 22,
                      child: Container(
                        padding: const EdgeInsets.only(top: 36, bottom: 8, left: 2, right: 2),
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: border, width: 1.5),
                        ),
                        child: Text(
                          item.label,
                          style: TextStyle(
                            color: textCol,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    // Floating Avatar Circle (Overflows top edge of box)
                    Positioned(
                      top: 0,
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: item.image != null && item.image!.isNotEmpty
                              ? ClipOval(
                                  child: Image.network(
                                    item.image!,
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Text(item.emoji, style: const TextStyle(fontSize: 24)),
                                  ),
                                )
                              : Text(item.emoji, style: const TextStyle(fontSize: 24)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _parseColor(String hexString, {required Color fallback}) {
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return fallback;
    }
  }
}

// ─── Shop by Price Section ──────────────────────────────────────────────────
class _ShopByPriceSection extends StatelessWidget {
  const _ShopByPriceSection();

  static const _priceItems = [
    (label: '₹0-₹250', min: 0, max: 250, icon: Icons.savings_outlined, border: Color(0xFF2D6A4F), bg: Color(0xFFD4EDDA), text: Color(0xFF2D6A4F)),
    (label: '₹250-₹500', min: 250, max: 500, icon: Icons.bolt_rounded, border: Color(0xFFC2185B), bg: Color(0xFFFFE0E6), text: Color(0xFFC2185B)),
    (label: '₹500-₹1000', min: 500, max: 1000, icon: Icons.card_giftcard_rounded, border: Color(0xFF1565C0), bg: Color(0xFFD6EAFF), text: Color(0xFF1565C0)),
    (label: '₹1000+', min: 1000, max: 999999, icon: Icons.diamond_outlined, border: Color(0xFF7B1FA2), bg: Color(0xFFF3E5F5), text: Color(0xFF7B1FA2)),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shop by Price',
            style: AppTextStyles.h2.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _priceItems.map((item) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: GestureDetector(
                    onTap: () => context.push('/shop?minPrice=${item.min}&maxPrice=${item.max}'),
                    child: SizedBox(
                      height: 96,
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.topCenter,
                        children: [
                          // Card Container (positioned lower so top avatar floats over top border)
                          Positioned.fill(
                            top: 22,
                            child: Container(
                              padding: const EdgeInsets.only(top: 36, bottom: 8, left: 2, right: 2),
                              decoration: BoxDecoration(
                                color: item.bg,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: item.border, width: 1.5),
                              ),
                              child: Text(
                                item.label,
                                style: TextStyle(
                                  color: item.text,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          // Floating Icon Circle (Overflows top edge of box)
                          Positioned(
                            top: 0,
                            child: Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Icon(
                                item.icon,
                                color: item.text,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

