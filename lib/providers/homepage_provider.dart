import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/banner.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../models/homepage_card.dart';
import '../models/occasion_tab.dart';
import '../models/gifting_story.dart';
import '../repositories/homepage_repository.dart';

/// Homepage Riverpod Providers
///
/// 💡 React Native equivalent: Each of these is like a useQuery hook:
///   const { data: banners } = useQuery(['banners'], getBanners)
///
/// Riverpod's FutureProvider auto-caches data and handles loading/error states.
/// ref.watch(bannersProvider) gives you `AsyncValue<List<Banner>>`
/// which can be .when(data: ..., loading: ..., error: ...)

final homepageRepositoryProvider = Provider<HomepageRepository>((ref) {
  return HomepageRepository();
});

/// Banners for hero carousel
final bannersProvider = FutureProvider<List<Banner>>((ref) {
  return ref.read(homepageRepositoryProvider).fetchBanners();
});

/// Category list for circle quicklinks
final categoriesProvider = FutureProvider<List<Category>>((ref) {
  return ref.read(homepageRepositoryProvider).fetchCategories();
});

/// Currently selected category tab index (for the animated tab bar)
final selectedCategoryIndexProvider = StateProvider<int>((ref) => 0);


/// Featured/trending products
final featuredProductsProvider = FutureProvider<List<Product>>((ref) {
  return ref.read(homepageRepositoryProvider).fetchFeaturedProducts();
});

/// Flower section cards
final flowerCardsProvider = FutureProvider<List<HomepageCard>>((ref) {
  return ref.read(homepageRepositoryProvider).fetchFlowerCards();
});

/// Relationship section cards
final relationshipCardsProvider = FutureProvider<List<HomepageCard>>((ref) {
  return ref.read(homepageRepositoryProvider).fetchRelationshipCards();
});

/// Luxury section cards
final luxuryCardsProvider = FutureProvider<List<HomepageCard>>((ref) async {
  try {
    final cards = await ref.read(homepageRepositoryProvider).fetchLuxuryCards();
    if (cards.isEmpty) return _staticLuxuryCards;
    return cards;
  } catch (_) {
    return _staticLuxuryCards;
  }
});

/// Personalize section cards
final personalizeCardsProvider = FutureProvider<List<HomepageCard>>((ref) async {
  try {
    final cards = await ref.read(homepageRepositoryProvider).fetchPersonalizeCards();
    if (cards.isEmpty) return _staticPersonalizeCards;
    return cards;
  } catch (_) {
    return _staticPersonalizeCards;
  }
});

/// Combo section cards
final comboCardsProvider = FutureProvider<List<HomepageCard>>((ref) async {
  try {
    final cards = await ref.read(homepageRepositoryProvider).fetchComboCards();
    if (cards.isEmpty) return _staticComboCards;
    return cards;
  } catch (_) {
    return _staticComboCards;
  }
});

/// Occasion tabs for "Tailored For Your Occasions" section
final occasionTabsProvider = FutureProvider<List<OccasionTab>>((ref) {
  return ref.read(homepageRepositoryProvider).fetchOccasionTabs();
});

/// Products for a specific occasion tab (by productIds or occasion filter)
final occasionProductsProvider =
    FutureProvider.family<List<Product>, OccasionTab>((ref, tab) async {
  final repo = ref.read(homepageRepositoryProvider);
  if (tab.productIds != null && tab.productIds!.isNotEmpty) {
    return repo.fetchProducts(ids: tab.productIds, limit: 20);
  }
  // Fallback: fetch by occasion name
  final products = await repo.fetchProducts(occasion: tab.name.toLowerCase(), limit: 20);
  if (products.isEmpty) {
    // If no products for this occasion, show featured as fallback
    return repo.fetchFeaturedProducts();
  }
  return products;
});

/// Gifting stories for Instagram-style stories section
final giftingStoriesProvider = FutureProvider<List<GiftingStory>>((ref) {
  return ref.read(homepageRepositoryProvider).fetchGiftingStories();
});

// ─── Static Fallbacks matching website ───────────────────────────

const _staticLuxuryCards = [
  HomepageCard(
    id: 'lux_1',
    title: 'Luxe Vibe',
    imageUrl: 'https://images.unsplash.com/photo-1591886960571-74d43a9d4166?w=400&auto=format&fit=crop&q=80',
    link: '/shop?category=luxe-gifts',
  ),
  HomepageCard(
    id: 'lux_2',
    title: 'Flowers',
    imageUrl: 'https://images.unsplash.com/photo-1550950158-d0d960dff51b?w=400&auto=format&fit=crop&q=80',
    link: '/shop?category=flowers&tag=luxe',
  ),
  HomepageCard(
    id: 'lux_3',
    title: 'Cakes',
    imageUrl: 'https://images.unsplash.com/photo-1535141192574-5d4897c13636?w=400&auto=format&fit=crop&q=80',
    link: '/shop?category=cakes&tag=luxe',
  ),
  HomepageCard(
    id: 'lux_4',
    title: 'Hampers',
    imageUrl: 'https://images.unsplash.com/photo-1607344645866-009c320c5ab8?w=400&auto=format&fit=crop&q=80',
    link: '/shop?category=gift-hampers&tag=luxe',
  ),
  HomepageCard(
    id: 'lux_5',
    title: 'Plants',
    imageUrl: 'https://images.unsplash.com/photo-1485955900006-10f4d324d411?w=400&auto=format&fit=crop&q=80',
    link: '/shop?category=plants&tag=luxe',
  ),
];

const _staticPersonalizeCards = [
  HomepageCard(
    id: 'pers_1',
    title: 'Jewellery',
    imageUrl: 'https://images.unsplash.com/photo-1611085583191-a3b1a30a5a40?w=400&auto=format&fit=crop&q=80',
    link: '/shop?category=jewelry-accessories',
  ),
  HomepageCard(
    id: 'pers_2',
    title: 'New Arrivals',
    imageUrl: 'https://images.unsplash.com/photo-1595079676339-1534801ad6cf?w=400&auto=format&fit=crop&q=80',
    link: '/shop?sort=newest',
  ),
  HomepageCard(
    id: 'pers_3',
    title: 'Mugs',
    imageUrl: 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=400&auto=format&fit=crop&q=80',
    link: '/shop?category=personalized-mugs',
  ),
  HomepageCard(
    id: 'pers_4',
    title: 'Cushions',
    imageUrl: 'https://images.unsplash.com/photo-1584100936595-c0654b55a2e2?w=400&auto=format&fit=crop&q=80',
    link: '/shop?category=personalized-cushions',
  ),
  HomepageCard(
    id: 'pers_5',
    title: 'Flowers',
    imageUrl: 'https://images.unsplash.com/photo-1561181286-d3fee7d55364?w=400&auto=format&fit=crop&q=80',
    link: '/shop?category=flowers',
  ),
  HomepageCard(
    id: 'pers_6',
    title: 'Sippers',
    imageUrl: 'https://images.unsplash.com/photo-1602143407151-7111542de6e8?w=400&auto=format&fit=crop&q=80',
    link: '/shop?category=personalized-gifts',
  ),
];

const _staticComboCards = [
  HomepageCard(
    id: 'combo_1',
    title: 'Flowers N Chocolates',
    imageUrl: 'https://images.unsplash.com/photo-1513201099705-a9746e1e201f?w=400&auto=format&fit=crop&q=80',
    link: '/shop?category=birthday-combos&search=chocolate',
  ),
  HomepageCard(
    id: 'combo_2',
    title: 'Flowers N Cakes',
    imageUrl: 'https://images.unsplash.com/photo-1535141192574-5d4897c13636?w=400&auto=format&fit=crop&q=80',
    link: '/shop?category=birthday-combos&search=cake',
  ),
  HomepageCard(
    id: 'combo_3',
    title: 'Plant Gift Sets',
    imageUrl: 'https://images.unsplash.com/photo-1485955900006-10f4d324d411?w=400&auto=format&fit=crop&q=80',
    link: '/shop?category=plants',
  ),
  HomepageCard(
    id: 'combo_4',
    title: 'Gift Hampers',
    imageUrl: 'https://images.unsplash.com/photo-1607344645866-009c320c5ab8?w=400&auto=format&fit=crop&q=80',
    link: '/shop?category=gift-hampers',
  ),
  HomepageCard(
    id: 'combo_5',
    title: 'Flowers N Guitarist',
    imageUrl: 'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=400&auto=format&fit=crop&q=80',
    link: '/shop?category=experiences-vouchers',
  ),
];
