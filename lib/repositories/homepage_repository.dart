import '../core/constants/api_constants.dart';
import '../core/network/dio_client.dart';
import '../models/banner.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../models/homepage_card.dart';
import '../models/occasion_tab.dart';
import '../models/gifting_story.dart';
import '../models/age_group.dart';
import '../models/section_banner.dart';
import '../models/review.dart';

/// Homepage Repository — fetches all homepage section data
class HomepageRepository {
  final DioClient _client = DioClient();

  /// GET /section-banners
  Future<List<SectionBanner>> fetchSectionBanners() async {
    try {
      final response = await _client.get(ApiConstants.sectionBanners);
      final body = response.data;
      final list = (body is Map
          ? (body['banners'] as List<dynamic>? ?? body['data'] as List<dynamic>? ?? [])
          : (body is List ? body : []));
      return list.map((e) => SectionBanner.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  /// GET /products?gifting=true&limit=8
  Future<List<Product>> fetchGiftingProducts() async {
    final response = await _client.get(
      ApiConstants.products,
      queryParameters: {'gifting': 'true', 'limit': 8},
    );
    final data = response.data;
    List<dynamic> list = [];
    if (data is Map) {
      list = (data['products'] as List<dynamic>?) ?? (data['data'] as List<dynamic>?) ?? [];
    } else if (data is List) {
      list = data;
    }
    return list.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// GET /products?ageGroup=0–1 Years&limit=8
  Future<List<Product>> fetchMyFirstYearProducts() async {
    final response = await _client.get(
      ApiConstants.products,
      queryParameters: {'ageGroup': '0–1 Years', 'limit': 8},
    );
    final data = response.data;
    List<dynamic> list = [];
    if (data is Map) {
      list = (data['products'] as List<dynamic>?) ?? (data['data'] as List<dynamic>?) ?? [];
    } else if (data is List) {
      list = data;
    }
    return list.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// GET /products?featured=true&limit=8
  Future<List<Product>> fetchTrendingProducts() async {
    final response = await _client.get(
      ApiConstants.products,
      queryParameters: {'featured': 'true', 'limit': 8},
    );
    final data = response.data;
    List<dynamic> list = [];
    if (data is Map) {
      list = (data['products'] as List<dynamic>?) ?? (data['data'] as List<dynamic>?) ?? [];
    } else if (data is List) {
      list = data;
    }
    return list.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// GET /products?skillDevelopment=true&limit=8
  Future<List<Product>> fetchSkillProducts() async {
    final response = await _client.get(
      ApiConstants.products,
      queryParameters: {'skillDevelopment': 'true', 'limit': 8},
    );
    final data = response.data;
    List<dynamic> list = [];
    if (data is Map) {
      list = (data['products'] as List<dynamic>?) ?? (data['data'] as List<dynamic>?) ?? [];
    } else if (data is List) {
      list = data;
    }
    return list.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// GET /products?musical=true&limit=8
  Future<List<Product>> fetchMusicalProducts() async {
    final response = await _client.get(
      ApiConstants.products,
      queryParameters: {'musical': 'true', 'limit': 8},
    );
    final data = response.data;
    List<dynamic> list = [];
    if (data is Map) {
      list = (data['products'] as List<dynamic>?) ?? (data['data'] as List<dynamic>?) ?? [];
    } else if (data is List) {
      list = data;
    }
    return list.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// GET /reviews/homepage?limit=8
  Future<List<Review>> fetchHomepageReviews() async {
    try {
      final response = await _client.get(
        ApiConstants.homepageReviews,
        queryParameters: {'limit': 8},
      );
      final data = response.data;
      List<dynamic> list = [];
      if (data is Map) {
        list = (data['reviews'] as List<dynamic>?) ?? (data['data'] as List<dynamic>?) ?? [];
      } else if (data is List) {
        list = data;
      }
      return list.map((e) => Review.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  /// GET /reviews/product/:id
  Future<List<Review>> fetchProductReviews(String productId) async {
    try {
      final response = await _client.get('/reviews/product/$productId');
      final data = response.data;
      List<dynamic> list = [];
      if (data is Map) {
        list = (data['reviews'] as List<dynamic>?) ?? (data['data'] as List<dynamic>?) ?? [];
      } else if (data is List) {
        list = data;
      }
      return list.map((e) => Review.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  /// GET /age-groups
  Future<List<AgeGroup>> fetchAgeGroups() async {
    final response = await _client.get(ApiConstants.ageGroups);
    final data = response.data['data'] ?? response.data;
    final list = data is List
        ? data
        : (data is Map ? (data['ageGroups'] as List<dynamic>? ?? []) : []);
    return list
        .map((e) => AgeGroup.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /carousel
  Future<List<Banner>> fetchBanners() async {
    final response = await _client.get(ApiConstants.banners);
    final data = response.data;
    final list = (data is Map
        ? (data['slides'] as List<dynamic>? ??
            data['banners'] as List<dynamic>? ??
            data['data'] as List<dynamic>? ??
            [])
        : (data is List ? data : []));
    return list.map((e) => Banner.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// GET /categories
  Future<List<Category>> fetchCategories({bool parentOnly = false}) async {
    final response = await _client.get(
      ApiConstants.categories,
      queryParameters: parentOnly ? {'parent': 'null'} : null,
    );
    final body = response.data;
    List<dynamic> list = [];
    if (body is Map) {
      list = (body['categories'] as List<dynamic>?) ??
          (body['data'] is List ? body['data'] : (body['data']?['categories'] as List<dynamic>?)) ??
          [];
    } else if (body is List) {
      list = body;
    }
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

  /// GET /products?bestseller=true&limit=10
  Future<List<Product>> fetchBestSellers() async {
    final response = await _client.get(
      ApiConstants.products,
      queryParameters: {'bestseller': 'true', 'limit': 10},
    );
    final data = response.data;
    List<dynamic> list = [];
    if (data is Map) {
      list = (data['products'] as List<dynamic>?) ?? (data['data'] as List<dynamic>?) ?? [];
    } else if (data is List) {
      list = data;
    }
    if (list.isEmpty) {
      return fetchFeaturedProducts();
    }
    return list.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// GET /products with full filter support
  Future<List<Product>> fetchProducts({
    String? category,
    String? subCategory,
    String? ageGroup,
    String? tag,
    String? search,
    String? occasion,
    String? relation,
    String? ids,
    String? sort,
    double? minPrice,
    double? maxPrice,
    int page = 1,
    int limit = 100,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (category != null && category.isNotEmpty) queryParams['category'] = category;
    if (subCategory != null && subCategory.isNotEmpty) queryParams['subCategory'] = subCategory;
    if (ageGroup != null && ageGroup.isNotEmpty) queryParams['ageGroup'] = ageGroup;
    if (tag != null && tag.isNotEmpty) queryParams['tag'] = tag;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (occasion != null && occasion.isNotEmpty) queryParams['occasion'] = occasion;
    if (relation != null && relation.isNotEmpty) queryParams['relation'] = relation;
    if (ids != null && ids.isNotEmpty) queryParams['ids'] = ids;
    if (minPrice != null) queryParams['minPrice'] = minPrice;
    if (maxPrice != null) queryParams['maxPrice'] = maxPrice;
    if (sort != null && sort.isNotEmpty) queryParams['sort'] = sort;

    final response = await _client.get(
      ApiConstants.products,
      queryParameters: queryParams,
    );
    final data = response.data;
    List<dynamic> list = [];
    if (data is Map) {
      list = (data['products'] as List<dynamic>?) ??
          (data['data'] is List
              ? data['data']
              : (data['data']?['products'] as List<dynamic>?)) ??
          [];
    } else if (data is List) {
      list = data;
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

