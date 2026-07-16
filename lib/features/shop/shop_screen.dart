import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/empty_state.dart' as widgets;
import '../../models/product.dart';
import '../../models/category.dart';
import '../../providers/homepage_provider.dart';
import '../../providers/cart_provider.dart';
import '../home/widgets/product_card.dart';

/// Shop filters state
class ShopFilters {
  final String? category;
  final String? subCategory;
  final String? ageGroup;
  final String? search;
  final String? tag;
  final String? occasion;
  final String? relation;
  final String? ids;
  final String? title;
  final double? minPrice;
  final double? maxPrice;
  final String sort;
  final int page;

  const ShopFilters({
    this.category,
    this.subCategory,
    this.ageGroup,
    this.search,
    this.tag,
    this.occasion,
    this.relation,
    this.ids,
    this.title,
    this.minPrice,
    this.maxPrice,
    this.sort = 'newest',
    this.page = 1,
  });

  ShopFilters copyWith({
    String? category,
    String? subCategory,
    String? ageGroup,
    String? search,
    String? tag,
    String? occasion,
    String? relation,
    String? ids,
    String? title,
    double? minPrice,
    double? maxPrice,
    String? sort,
    int? page,
    bool clearCategory = false,
    bool clearSubCategory = false,
    bool clearAgeGroup = false,
    bool clearSearch = false,
    bool clearTag = false,
    bool clearOccasion = false,
    bool clearRelation = false,
    bool clearIds = false,
    bool clearTitle = false,
    bool clearPrice = false,
  }) {
    return ShopFilters(
      category: clearCategory ? null : (category ?? this.category),
      subCategory: clearSubCategory ? null : (subCategory ?? this.subCategory),
      ageGroup: clearAgeGroup ? null : (ageGroup ?? this.ageGroup),
      search: clearSearch ? null : (search ?? this.search),
      tag: clearTag ? null : (tag ?? this.tag),
      occasion: clearOccasion ? null : (occasion ?? this.occasion),
      relation: clearRelation ? null : (relation ?? this.relation),
      ids: clearIds ? null : (ids ?? this.ids),
      title: clearTitle ? null : (title ?? this.title),
      minPrice: clearPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearPrice ? null : (maxPrice ?? this.maxPrice),
      sort: sort ?? this.sort,
      page: page ?? this.page,
    );
  }
}

/// Sort options matching the website
const _sortOptions = [
  ('newest', 'Newest First'),
  ('price_asc', 'Price: Low → High'),
  ('price_desc', 'Price: High → Low'),
  ('rating', 'Highest Rated'),
  ('popular', 'Most Popular'),
];

/// Shop state provider
final shopFiltersProvider =
    StateProvider<ShopFilters>((ref) => const ShopFilters());

/// Products provider — depends on filters
final shopProductsProvider = FutureProvider<List<Product>>((ref) {
  final filters = ref.watch(shopFiltersProvider);
  final repo = ref.read(homepageRepositoryProvider);
  // Map app sort values to backend enum values
  String? sortValue = filters.sort;
  if (sortValue == 'popular') sortValue = 'popularity';
  return repo.fetchProducts(
    category: filters.category,
    subCategory: filters.subCategory,
    ageGroup: filters.ageGroup,
    search: filters.search,
    tag: filters.tag,
    occasion: filters.occasion,
    relation: filters.relation,
    ids: filters.ids,
    minPrice: filters.minPrice,
    maxPrice: filters.maxPrice,
    page: filters.page,
    sort: sortValue,
  );
});

/// Shop Screen — mirrors ShopPage.tsx
class ShopScreen extends ConsumerStatefulWidget {
  final String? initialCategory;
  final String? initialSubCategory;
  final String? initialAgeGroup;
  final String? initialSearch;
  final String? initialTag;
  final String? initialOccasion;
  final String? initialRelation;
  final String? initialSort;
  final String? initialIds;
  final String? initialTitle;
  final double? initialMinPrice;
  final double? initialMaxPrice;

  const ShopScreen({
    super.key,
    this.initialCategory,
    this.initialSubCategory,
    this.initialAgeGroup,
    this.initialSearch,
    this.initialTag,
    this.initialOccasion,
    this.initialRelation,
    this.initialSort,
    this.initialIds,
    this.initialTitle,
    this.initialMinPrice,
    this.initialMaxPrice,
  });

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  @override
  void initState() {
    super.initState();
    // Apply initial filters from route parameters
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialCategory != null ||
          widget.initialSubCategory != null ||
          widget.initialAgeGroup != null ||
          widget.initialSearch != null ||
          widget.initialTag != null ||
          widget.initialOccasion != null ||
          widget.initialRelation != null ||
          widget.initialSort != null ||
          widget.initialIds != null ||
          widget.initialTitle != null ||
          widget.initialMinPrice != null ||
          widget.initialMaxPrice != null) {
        ref.read(shopFiltersProvider.notifier).state = ShopFilters(
          category: widget.initialCategory,
          subCategory: widget.initialSubCategory,
          ageGroup: widget.initialAgeGroup,
          search: widget.initialSearch,
          tag: widget.initialTag,
          occasion: widget.initialOccasion,
          relation: widget.initialRelation,
          ids: widget.initialIds,
          title: widget.initialTitle,
          minPrice: widget.initialMinPrice,
          maxPrice: widget.initialMaxPrice,
          sort: widget.initialSort ?? 'newest',
        );
      }
    });
  }

  @override
  void didUpdateWidget(ShopScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialCategory != oldWidget.initialCategory ||
        widget.initialSubCategory != oldWidget.initialSubCategory ||
        widget.initialAgeGroup != oldWidget.initialAgeGroup ||
        widget.initialSearch != oldWidget.initialSearch ||
        widget.initialTag != oldWidget.initialTag ||
        widget.initialOccasion != oldWidget.initialOccasion ||
        widget.initialRelation != oldWidget.initialRelation ||
        widget.initialSort != oldWidget.initialSort ||
        widget.initialIds != oldWidget.initialIds ||
        widget.initialTitle != oldWidget.initialTitle ||
        widget.initialMinPrice != oldWidget.initialMinPrice ||
        widget.initialMaxPrice != oldWidget.initialMaxPrice) {
      ref.read(shopFiltersProvider.notifier).state = ShopFilters(
        category: widget.initialCategory,
        subCategory: widget.initialSubCategory,
        ageGroup: widget.initialAgeGroup,
        search: widget.initialSearch,
        tag: widget.initialTag,
        occasion: widget.initialOccasion,
        relation: widget.initialRelation,
        ids: widget.initialIds,
        title: widget.initialTitle,
        minPrice: widget.initialMinPrice,
        maxPrice: widget.initialMaxPrice,
        sort: widget.initialSort ?? 'newest',
      );
    }
  }

  String _getShopTitle(ShopFilters filters, List<Category> categories) {
    if (filters.title != null && filters.title!.isNotEmpty) {
      return filters.title!;
    }
    if (filters.ageGroup != null && filters.ageGroup!.isNotEmpty) {
      return filters.ageGroup!;
    }
    if (filters.category != null) {
      final name = _getCategoryLabel(filters.category, categories);
      if (name != 'Category') return name;
    }
    if (filters.search != null && filters.search!.isNotEmpty) {
      return 'Search: ${filters.search}';
    }
    if (filters.occasion != null && filters.occasion!.isNotEmpty) {
      final occ = filters.occasion!;
      return '${occ[0].toUpperCase()}${occ.substring(1)} Gifts';
    }
    if (filters.relation != null && filters.relation!.isNotEmpty) {
      final rel = filters.relation!;
      return 'Gifts for ${rel[0].toUpperCase()}${rel.substring(1)}';
    }
    if (filters.tag != null && filters.tag!.isNotEmpty) {
      final t = filters.tag!;
      return '${t[0].toUpperCase()}${t.substring(1)}';
    }
    return 'Shop';
  }

  String _getSortLabel(String sort) {
    try {
      return _sortOptions.firstWhere((s) => s.$1 == sort).$2;
    } catch (_) {
      return 'Sort By';
    }
  }

  String _getCategoryLabel(String? slug, List<Category> categories) {
    if (slug == null) return 'Category';
    try {
      final parent = categories.firstWhere((c) => c.slug == slug, orElse: () => Category(id: '', name: '', slug: ''));
      if (parent.name.isNotEmpty) return parent.name;
      
      for (final cat in categories) {
        if (cat.children != null) {
          final child = cat.children!.firstWhere((c) => c.slug == slug, orElse: () => Category(id: '', name: '', slug: ''));
          if (child.name.isNotEmpty) return child.name;
        }
      }
      return slug;
    } catch (_) {
      return 'Category';
    }
  }

  void _showSortBottomSheet() {
    final filters = ref.read(shopFiltersProvider);
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Sort By', style: AppTextStyles.h3),
              const SizedBox(height: 16),
              ..._sortOptions.map((option) {
                final isSelected = filters.sort == option.$1;
                return InkWell(
                  onTap: () {
                    ref.read(shopFiltersProvider.notifier).state =
                        filters.copyWith(sort: option.$1, page: 1);
                    Navigator.pop(ctx);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          option.$2,
                          style: AppTextStyles.body.copyWith(
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected ? AppColors.primary : AppColors.text,
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showCategoryBottomSheet(List<Category> categories) {
    final filters = ref.read(shopFiltersProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Select Category', style: AppTextStyles.h3),
                      if (filters.category != null)
                        TextButton(
                          onPressed: () {
                            ref.read(shopFiltersProvider.notifier).state =
                                filters.copyWith(clearCategory: true, page: 1);
                            Navigator.pop(ctx);
                          },
                          child: Text(
                            'Clear',
                            style: AppTextStyles.bodySm.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: categories.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          final isSelected = filters.category == null;
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              'All Categories',
                              style: AppTextStyles.body.copyWith(
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                color: isSelected ? AppColors.primary : AppColors.text,
                              ),
                            ),
                            trailing: isSelected
                                ? const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20)
                                : null,
                            onTap: () {
                              ref.read(shopFiltersProvider.notifier).state =
                                  filters.copyWith(clearCategory: true, page: 1);
                              Navigator.pop(ctx);
                            },
                          );
                        }
                        
                        final category = categories[index - 1];
                        final isSelectedParent = filters.category == category.slug;
                        final hasChildren = category.children != null && category.children!.isNotEmpty;

                        if (hasChildren) {
                          final hasSelectedChild = category.children!.any((c) => c.slug == filters.category);
                          return ExpansionTile(
                            tilePadding: EdgeInsets.zero,
                            title: Text(
                              category.name,
                              style: AppTextStyles.body.copyWith(
                                fontWeight: hasSelectedChild || isSelectedParent
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: hasSelectedChild || isSelectedParent
                                    ? AppColors.primary
                                    : AppColors.text,
                              ),
                            ),
                            initiallyExpanded: hasSelectedChild,
                            childrenPadding: const EdgeInsets.only(left: 16),
                            children: category.children!.map((child) {
                              final isSelectedChild = filters.category == child.slug;
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  child.name,
                                  style: AppTextStyles.bodySm.copyWith(
                                    fontWeight: isSelectedChild ? FontWeight.w600 : FontWeight.w400,
                                    color: isSelectedChild ? AppColors.primary : AppColors.text,
                                  ),
                                ),
                                trailing: isSelectedChild
                                    ? const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 18)
                                    : null,
                                onTap: () {
                                  ref.read(shopFiltersProvider.notifier).state =
                                      filters.copyWith(category: child.slug, page: 1);
                                  Navigator.pop(ctx);
                                },
                              );
                            }).toList(),
                          );
                        } else {
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              category.name,
                              style: AppTextStyles.body.copyWith(
                                fontWeight: isSelectedParent ? FontWeight.w600 : FontWeight.w400,
                                color: isSelectedParent ? AppColors.primary : AppColors.text,
                              ),
                            ),
                            trailing: isSelectedParent
                                ? const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20)
                                : null,
                            onTap: () {
                              ref.read(shopFiltersProvider.notifier).state =
                                  filters.copyWith(category: category.slug, page: 1);
                              Navigator.pop(ctx);
                            },
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterPill({
    required BuildContext context,
    Widget? leading,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.border,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[
              leading,
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: AppTextStyles.bodySm.copyWith(
                color: isActive ? AppColors.primary : AppColors.text,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: isActive ? AppColors.primary : AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterRow(BuildContext context, ShopFilters filters, List<Category> categories) {
    final hasActiveGeneralFilter = filters.tag != null || 
        filters.occasion != null || 
        filters.relation != null || 
        filters.ids != null;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          _buildFilterPill(
            context: context,
            leading: Icon(
              Icons.tune_rounded, 
              size: 16, 
              color: hasActiveGeneralFilter ? AppColors.primary : AppColors.text,
            ),
            label: 'Filters',
            isActive: hasActiveGeneralFilter,
            onTap: _showFilters,
          ),
          const SizedBox(width: 8),
          _buildFilterPill(
            context: context,
            leading: Icon(
              Icons.swap_vert_rounded, 
              size: 16, 
              color: filters.sort != 'newest' ? AppColors.primary : AppColors.text,
            ),
            label: filters.sort == 'newest' ? 'Sort By' : _getSortLabel(filters.sort),
            isActive: filters.sort != 'newest',
            onTap: _showSortBottomSheet,
          ),
          const SizedBox(width: 8),
          _buildFilterPill(
            context: context,
            label: 'Price',
            isActive: false,
            onTap: _showFilters,
          ),
          const SizedBox(width: 8),
          _buildFilterPill(
            context: context,
            label: filters.category == null ? 'Category' : _getCategoryLabel(filters.category, categories),
            isActive: filters.category != null,
            onTap: () => _showCategoryBottomSheet(categories),
          ),
        ],
      ),
    );
  }

  void _showFilters() {
    final filters = ref.read(shopFiltersProvider);
    final categoriesAsync = ref.read(categoriesProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _FilterSheet(
        filters: filters,
        categories: categoriesAsync.valueOrNull ?? [],
        onApply: (newFilters) {
          ref.read(shopFiltersProvider.notifier).state = newFilters;
          Navigator.pop(ctx);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(shopProductsProvider);
    final filters = ref.watch(shopFiltersProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final cartItems = ref.watch(cartProvider).totalItems;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getShopTitle(filters, categoriesAsync.valueOrNull ?? []),
              style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            productsAsync.when(
              data: (products) => Text(
                '${products.length} items',
                style: AppTextStyles.bodyXs.copyWith(color: AppColors.textMuted),
              ),
              loading: () => Text(
                'Loading...',
                style: AppTextStyles.bodyXs.copyWith(color: AppColors.textMuted),
              ),
              error: (_, __) => Text(
                'Error',
                style: AppTextStyles.bodyXs.copyWith(color: AppColors.textMuted),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, size: 26),
            onPressed: () => context.push('/search'),
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined, size: 26),
                onPressed: () => context.go('/cart'),
              ),
              if (cartItems > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$cartItems',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
        centerTitle: false,
      ),
      body: Column(
        children: [
          // ── Horizontal Filter Row ──
          _buildFilterRow(context, filters, categoriesAsync.valueOrNull ?? []),

          // ── Active filter chips ──
          if (filters.category != null ||
              filters.sort != 'newest' ||
              filters.tag != null ||
              filters.occasion != null ||
              filters.relation != null ||
              filters.ids != null ||
              filters.search != null)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  if (filters.category != null)
                    _FilterChip(
                      label: _getCategoryLabel(filters.category, categoriesAsync.valueOrNull ?? []),
                      onRemove: () {
                        ref.read(shopFiltersProvider.notifier).state =
                            filters.copyWith(clearCategory: true, page: 1);
                      },
                    ),
                  if (filters.search != null)
                    _FilterChip(
                      label: 'Search: ${filters.search}',
                      onRemove: () {
                        ref.read(shopFiltersProvider.notifier).state =
                            filters.copyWith(clearSearch: true, page: 1);
                      },
                    ),
                  if (filters.tag != null)
                    _FilterChip(
                      label: 'Tag: ${filters.tag}',
                      onRemove: () {
                        ref.read(shopFiltersProvider.notifier).state =
                            filters.copyWith(clearTag: true, page: 1);
                      },
                    ),
                  if (filters.occasion != null)
                    _FilterChip(
                      label: 'Occasion: ${filters.occasion}',
                      onRemove: () {
                        ref.read(shopFiltersProvider.notifier).state =
                            filters.copyWith(clearOccasion: true, page: 1);
                      },
                    ),
                  if (filters.relation != null)
                    _FilterChip(
                      label: 'Relation: ${filters.relation}',
                      onRemove: () {
                        ref.read(shopFiltersProvider.notifier).state =
                            filters.copyWith(clearRelation: true, page: 1);
                      },
                    ),
                  if (filters.ids != null)
                    _FilterChip(
                      label: filters.title ?? 'Selected Items',
                      onRemove: () {
                        ref.read(shopFiltersProvider.notifier).state =
                            filters.copyWith(clearIds: true, clearTitle: true, page: 1);
                      },
                    ),
                  if (filters.sort != 'newest')
                    _FilterChip(
                      label: _sortOptions
                          .firstWhere((s) => s.$1 == filters.sort)
                          .$2,
                      onRemove: () {
                        ref.read(shopFiltersProvider.notifier).state =
                            filters.copyWith(sort: 'newest', page: 1);
                      },
                    ),
                ],
              ),
            ),

          // ── Products Grid ──
          Expanded(
            child: productsAsync.when(
              data: (products) {
                if (products.isEmpty) {
                  return widgets.EmptyStateWidget(
                    icon: Icons.shopping_bag_outlined,
                    title: 'No products found',
                    message: 'Try adjusting your filters or search',
                    actionLabel: 'Clear Filters',
                    onAction: () {
                      ref.read(shopFiltersProvider.notifier).state =
                          const ShopFilters();
                    },
                  );
                }
                return GridView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 4),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.66,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) => ProductCard(
                    product: products[index],
                    width: double.infinity,
                    onTap: () {
                      context.push('/product/${products[index].id}');
                    },
                  ),
                );
              },
              loading: () =>
                  const LoadingWidget(message: 'Finding gifts...'),
              error: (err, _) => Center(
                child: Text(
                  err.toString(),
                  style: AppTextStyles.bodySm
                      .copyWith(color: AppColors.danger),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Active filter chip
class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _FilterChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border:
            Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyXs.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close_rounded,
                size: 14, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

/// Filter Bottom Sheet
class _FilterSheet extends StatefulWidget {
  final ShopFilters filters;
  final List<Category> categories;
  final Function(ShopFilters) onApply;

  const _FilterSheet({
    required this.filters,
    required this.categories,
    required this.onApply,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late String _sort;
  late String? _category;
  bool _clearAll = false;

  @override
  void initState() {
    super.initState();
    _sort = widget.filters.sort;
    _category = widget.filters.category;
    _clearAll = false;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (context, scrollController) => Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Filter & Sort', style: AppTextStyles.h3),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _sort = 'newest';
                      _category = null;
                      _clearAll = true;
                    });
                  },
                  child: Text(
                    'Clear All',
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              children: [
                // Sort section
                Text('Sort By', style: AppTextStyles.h4),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _sortOptions.map((s) {
                    final isSelected = _sort == s.$1;
                    return GestureDetector(
                      onTap: () => setState(() => _sort = s.$1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.bgSurface,
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusFull),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.border,
                          ),
                        ),
                        child: Text(
                          s.$2,
                          style: AppTextStyles.bodyXs.copyWith(
                            color: isSelected ? Colors.white : AppColors.text,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 28),

                // Category section
                if (widget.categories.isNotEmpty) ...[
                  Text('Category', style: AppTextStyles.h4),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _categoryChip('All', null),
                      ...widget.categories
                          .map((c) => _categoryChip(c.name, c.slug)),
                    ],
                  ),
                ],
              ],
            ),
          ),
          // Apply button
          Padding(
            padding: EdgeInsets.fromLTRB(
                20, 8, 20, MediaQuery.of(context).padding.bottom + 16),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  widget.onApply(
                    _clearAll
                        ? ShopFilters(sort: _sort, category: _category)
                        : widget.filters.copyWith(
                            sort: _sort,
                            category: _category,
                            clearCategory: _category == null,
                            page: 1,
                          ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppTheme.radiusFull),
                  ),
                ),
                child: Text(
                  'Apply Filters',
                  style: AppTextStyles.bodySm.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryChip(String label, String? slug) {
    final isSelected = _category == slug;
    return GestureDetector(
      onTap: () => setState(() => _category = slug),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color:
              isSelected ? AppColors.primary : AppColors.bgSurface,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyXs.copyWith(
            color: isSelected ? Colors.white : AppColors.text,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
