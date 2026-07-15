import '../core/constants/api_constants.dart';
import '../core/network/dio_client.dart';
import '../models/banner.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../models/homepage_card.dart';
import '../models/occasion_tab.dart';
import '../models/gifting_story.dart';

/// Homepage Repository — fetches all homepage section data
///
/// 💡 React Native equivalent: These map 1:1 to the useQuery calls
/// in HomePage.tsx and the API functions in api/products.ts
class HomepageRepository {
  final DioClient _client = DioClient();

  /// GET /banners
  Future<List<Banner>> fetchBanners() async {
    final response = await _client.get(ApiConstants.banners);
    final list = response.data['data'] as List<dynamic>? ?? [];
    return list.map((e) => Banner.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// GET /categories
  Future<List<Category>> fetchCategories() async {
    final response = await _client.get(ApiConstants.categories);
    final data = response.data['data'];
    // API returns { data: { categories: [...] } } or { data: [...] }
    final list = data is List
        ? data
        : (data is Map ? (data['categories'] as List<dynamic>? ?? []) : []);
    return list
        .map((e) => Category.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /products/featured
  Future<List<Product>> fetchFeaturedProducts() async {
    final response = await _client.get(ApiConstants.featuredProducts);
    final data = response.data['data'];
    // API returns { data: { newest: [...], featured: [...], topRated: [...] } } or { data: [...] }
    List<dynamic> list;
    if (data is List) {
      list = data;
    } else if (data is Map) {
      list = data['newest'] as List<dynamic>? ?? data['featured'] as List<dynamic>? ?? [];
    } else {
      list = [];
    }
    return list
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /products?tag=X or similar filtered products
  Future<List<Product>> fetchProducts({
    String? category,
    String? tag,
    String? search,
    String? occasion,
    String? relation,
    String? ids,
    String? sort,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (category != null) queryParams['category'] = category;
    if (tag != null) queryParams['tag'] = tag;
    if (search != null) queryParams['search'] = search;
    if (occasion != null) queryParams['occasion'] = occasion;
    if (relation != null) queryParams['relation'] = relation;
    if (ids != null) queryParams['ids'] = ids;
    if (sort != null) queryParams['sort'] = sort;

    final response = await _client.get(
      ApiConstants.products,
      queryParameters: queryParams,
    );
    final data = response.data['data'];
    // API returns { data: { products: [...] } } or { data: [...] }
    List<dynamic> list;
    if (data is List) {
      list = data;
    } else if (data is Map) {
      list = data['products'] as List<dynamic>? ?? [];
    } else {
      list = [];
    }
    return list
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /homepage-flower-cards
  Future<List<HomepageCard>> fetchFlowerCards() async {
    final response = await _client.get(ApiConstants.flowerCards);
    final list = response.data['data'] as List<dynamic>? ?? [];
    return list
        .map((e) => HomepageCard.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /homepage-relationship-cards
  Future<List<HomepageCard>> fetchRelationshipCards() async {
    final response = await _client.get(ApiConstants.relationshipCards);
    final list = response.data['data'] as List<dynamic>? ?? [];
    return list
        .map((e) => HomepageCard.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /homepage-luxury-cards
  Future<List<HomepageCard>> fetchLuxuryCards() async {
    final response = await _client.get(ApiConstants.luxuryCards);
    final list = response.data['data'] as List<dynamic>? ?? [];
    return list
        .map((e) => HomepageCard.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /homepage-personalize-cards
  Future<List<HomepageCard>> fetchPersonalizeCards() async {
    final response = await _client.get(ApiConstants.personalizeCards);
    final list = response.data['data'] as List<dynamic>? ?? [];
    return list
        .map((e) => HomepageCard.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /homepage-combo-cards
  Future<List<HomepageCard>> fetchComboCards() async {
    final response = await _client.get(ApiConstants.comboCards);
    final list = response.data['data'] as List<dynamic>? ?? [];
    return list
        .map((e) => HomepageCard.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /homepage-occasion-tabs
  Future<List<OccasionTab>> fetchOccasionTabs() async {
    final response = await _client.get(ApiConstants.occasionTabs);
    final list = response.data['data'] as List<dynamic>? ?? [];
    return list
        .map((e) => OccasionTab.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /homepage-gifting-stories
  Future<List<GiftingStory>> fetchGiftingStories() async {
    final response = await _client.get(ApiConstants.giftingStories);
    final list = response.data['data'] as List<dynamic>? ?? [];
    return list
        .map((e) => GiftingStory.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

