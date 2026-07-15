import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../models/homepage_card.dart';
import '../../models/product.dart';
import '../../providers/homepage_provider.dart';

/// Redesigned Search Screen showing recent/trending categories, relationships, flowers,
/// and live search suggestions from the database.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  
  Timer? _debounce;
  List<Product> _suggestions = [];
  bool _isLoading = false;
  String _currentQuery = '';

  // Static fallback recipient/relationship data matching Header.tsx
  final List<Map<String, String>> _defaultRelationships = [
    {'name': 'Him', 'relation': 'him'},
    {'name': 'Her', 'relation': 'her'},
    {'name': 'Kids', 'relation': 'kids'},
    {'name': 'Friend', 'relation': 'friend'},
    {'name': 'Girlfriend', 'relation': 'girlfriend'},
    {'name': 'Boyfriend', 'relation': 'boyfriend'},
    {'name': 'Wife', 'relation': 'wife'},
    {'name': 'Husband', 'relation': 'husband'},
  ];

  final List<String> _popularQueries = [
    'Mango Cake',
    'Roses',
    'Personalized Mug',
    'Photo Frame',
    'Chocolate',
    'Teddy Bear',
    'Plants',
    'Cushion'
  ];

  @override
  void initState() {
    super.initState();
    // Auto focus the input field
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _currentQuery = query.trim();
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    if (_currentQuery.length < 2) {
      setState(() {
        _suggestions = [];
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    _debounce = Timer(const Duration(milliseconds: 300), () async {
      try {
        final products = await ref
            .read(homepageRepositoryProvider)
            .fetchProducts(search: _currentQuery, limit: 10);
        
        if (mounted) {
          setState(() {
            _suggestions = products;
            _isLoading = false;
          });
        }
      } catch (_) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    });
  }

  void _executeSearch(String query) {
    if (query.trim().isEmpty) return;
    context.push('/shop?search=${Uri.encodeComponent(query.trim())}');
  }

  @override
  Widget build(BuildContext context) {
    final flowerCardsAsync = ref.watch(flowerCardsProvider);
    final personalizeCardsAsync = ref.watch(personalizeCardsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.text),
          onPressed: () => context.pop(),
        ),
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9), // Light slate gray background
              borderRadius: BorderRadius.circular(22),
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              onChanged: _onSearchChanged,
              onSubmitted: _executeSearch,
              textInputAction: TextInputAction.search,
              cursorColor: AppColors.primary,
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 15,
                color: AppColors.text,
              ),
              decoration: InputDecoration(
                hintText: 'Search for cakes, flowers, gifts...',
                hintStyle: TextStyle(
                  fontFamily: 'Outfit',
                  color: Colors.grey.shade400,
                  fontSize: 15,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFFEF476F),
                  size: 22,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, color: Colors.grey, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 11),
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _searchController.text.trim().isNotEmpty
              ? _buildSuggestionsList()
              : _buildDefaultDropdownView(personalizeCardsAsync, flowerCardsAsync),
    );
  }

  Widget _buildSuggestionsList() {
    if (_suggestions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              'No products found',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF5E5E6A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching for something else',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 14,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _suggestions.length + 1,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        if (index == _suggestions.length) {
          // Bottom element: Click to search in shop screen
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: ElevatedButton.icon(
              onPressed: () => _executeSearch(_searchController.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFF0F2),
                foregroundColor: const Color(0xFFEF476F),
                elevation: 0,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.search_rounded, size: 18),
              label: Text(
                'Search for "${_searchController.text}"',
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }

        final product = _suggestions[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade100,
            ),
            clipBehavior: Clip.antiAlias,
            child: product.primaryImage.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: product.primaryImage,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: Colors.grey.shade100),
                    errorWidget: (context, url, error) => const Icon(Icons.card_giftcard_rounded, color: Colors.grey),
                  )
                : const Icon(Icons.card_giftcard_rounded, color: Colors.grey),
          ),
          title: Text(
            product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Outfit',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          subtitle: Text(
            product.categoryName ?? 'Gift Item',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 12,
              color: Colors.grey.shade400,
            ),
          ),
          trailing: Text(
            '₹${product.price.toStringAsFixed(0)}',
            style: const TextStyle(
              fontFamily: 'Outfit',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFFEF476F),
            ),
          ),
          onTap: () => context.push('/product/${product.slug}'),
        );
      },
    );
  }

  Widget _buildDefaultDropdownView(
    AsyncValue<List<HomepageCard>> personalizeAsync,
    AsyncValue<List<HomepageCard>> flowersAsync,
  ) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 1. Popular/Trending Queries ──
          const Text(
            'Trending Searches',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _popularQueries.map((query) {
              return GestureDetector(
                onTap: () {
                  _searchController.text = query;
                  _onSearchChanged(query);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    query,
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 13,
                      color: Color(0xFF5E5E6A),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 32),

          // ── 2. Recipients ("Shop For Everyone") ──
          const Text(
            'Shop For Everyone',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _defaultRelationships.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            itemBuilder: (context, index) {
              final rel = _defaultRelationships[index];
              return GestureDetector(
                onTap: () => context.push('/shop?relation=${rel['relation']}'),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0F2), // Premium soft pink
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        rel['relation'] == 'him' || rel['relation'] == 'boyfriend' || rel['relation'] == 'husband'
                            ? Icons.face_rounded
                            : Icons.face_3_rounded,
                        color: const Color(0xFFEF476F),
                        size: 24,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        rel['name']!,
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFBC3B5D),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 32),

          // ── 3. Trending Gifts (Personalize Cards) ──
          personalizeAsync.when(
            data: (cards) {
              if (cards.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Trending Gifts',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: cards.length,
                      itemBuilder: (context, index) {
                        final card = cards[index];
                        return GestureDetector(
                          onTap: () {
                            if (card.link != null && card.link!.isNotEmpty) {
                              context.push(card.link!);
                            }
                          },
                          child: Container(
                            width: 100,
                            margin: const EdgeInsets.only(right: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color: Colors.grey.shade100,
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: CachedNetworkImage(
                                      imageUrl: card.imageUrl,
                                      fit: BoxFit.cover,
                                      width: 100,
                                      placeholder: (context, url) => Container(color: Colors.grey.shade100),
                                      errorWidget: (context, url, error) => const Icon(Icons.card_giftcard_rounded, color: Colors.grey),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  card.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: 'Outfit',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.text,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // ── 4. Pick Their Fav Flowers (Flower Cards) ──
          flowersAsync.when(
            data: (cards) {
              if (cards.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pick Their Fav Flowers',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: cards.length,
                      itemBuilder: (context, index) {
                        final card = cards[index];
                        return GestureDetector(
                          onTap: () {
                            if (card.link != null && card.link!.isNotEmpty) {
                              context.push(card.link!);
                            }
                          },
                          child: Container(
                            width: 100,
                            margin: const EdgeInsets.only(right: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color: Colors.grey.shade100,
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: CachedNetworkImage(
                                      imageUrl: card.imageUrl,
                                      fit: BoxFit.cover,
                                      width: 100,
                                      placeholder: (context, url) => Container(color: Colors.grey.shade100),
                                      errorWidget: (context, url, error) => const Icon(Icons.card_giftcard_rounded, color: Colors.grey),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  card.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: 'Outfit',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.text,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
