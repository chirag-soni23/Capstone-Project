import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.1.234:3000';

  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: '$baseUrl/api',
      headers: {'Content-Type': 'application/json'},
    ),
  );

  static final CookieJar cookieJar = CookieJar();

  static void init() {
    dio.interceptors.add(CookieManager(cookieJar));
  }

  // Direct image URL
  static String imageUrl(String image) {
    if (image.startsWith('http')) {
      return image;
    }

    return '$baseUrl$image';
  }

  // ============== AUTH =================

  static Future<Response> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    return dio.post(
      '/auth/register',
      data: {
        'name': name,
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
      },
    );
  }

  static Future<Response> login({
    required String email,
    required String password,
  }) {
    return dio.post(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );
  }

  static Future<Response> getMe() {
    return dio.get('/auth/me');
  }

  static Future<Response> googleLogin({
    required String idToken,
  }) {
    return dio.post(
      '/auth/google',
      data: {
        'idToken': idToken,
      },
    );
  }

  static Future<Response> updateProfile({
    String? name,
    String? email,
  }) {
    return dio.patch(
      '/auth/update-profile',
      data: {
        if (name != null) 'name': name,
        if (email != null) 'email': email,
      },
    );
  }

  static Future<Response> logout() {
    return dio.post('/auth/logout');
  }

  // ============== CATEGORY =================

  static Future<Response> getCategories({
    int page = 1,
    int limit = 10,
    String search = '',
  }) {
    return dio.get(
      '/category',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (search.isNotEmpty) 'search': search,
      },
    );
  }

  static Future<Response> createCategory({
    required String name,
    required File image,
  }) async {
    final formData = FormData.fromMap({
      'name': name,
      'image': await MultipartFile.fromFile(
        image.path,
        filename: image.path.split('/').last,
      ),
    });

    return dio.post(
      '/category',
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
      ),
    );
  }

  static Future<Response> updateCategory({
    required String id,
    String? name,
    File? image,
  }) async {
    final formData = FormData();

    if (name != null) {
      formData.fields.add(
        MapEntry('name', name),
      );
    }

    if (image != null) {
      formData.files.add(
        MapEntry(
          'image',
          await MultipartFile.fromFile(
            image.path,
            filename: image.path.split('/').last,
          ),
        ),
      );
    }

    return dio.patch(
      '/category/$id',
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
      ),
    );
  }

  static Future<Response> deleteCategory({
    required String id,
  }) {
    return dio.delete('/category/$id');
  }



// ============== PRODUCTS =================

  static Future<Response> getProducts({
    int page = 1,
    int limit = 10,
    String search = '',
    int? categoryId,
  }) {
    return dio.get(
      '/product',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (search.isNotEmpty) 'search': search,
        if (categoryId != null) 'categoryId': categoryId,
      },
    );
  }

  static Future<Response> getProductById({
    required String id,
  }) {
    return dio.get('/product/$id');
  }

// Create Product
  static Future<Response> createProduct({
    required String name,
    required int categoryId,
    required String price,
    String? discountPercentage,
    String? description,
    required File image,
  }) async {
    final formData = FormData.fromMap({
      'name': name,
      'categoryId': categoryId.toString(),
      'price': price,

      if (discountPercentage != null &&
          discountPercentage.isNotEmpty)
        'discountPercentage': discountPercentage,

      if (description != null && description.isNotEmpty)
        'description': description,

      'image': await MultipartFile.fromFile(
        image.path,
        filename: image.path.split('/').last,
      ),
    });

    return dio.post(
      '/product',
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
      ),
    );
  }

// Update Product
  static Future<Response> updateProduct({
    required String id,
    String? name,
    int? categoryId,
    String? price,
    String? discountPercentage,
    String? description,
    File? image,
  }) async {
    final formData = FormData();

    if (name != null) {
      formData.fields.add(
        MapEntry('name', name),
      );
    }

    if (categoryId != null) {
      formData.fields.add(
        MapEntry(
          'categoryId',
          categoryId.toString(),
        ),
      );
    }

    if (price != null) {
      formData.fields.add(
        MapEntry('price', price),
      );
    }

    if (discountPercentage != null) {
      formData.fields.add(
        MapEntry(
          'discountPercentage',
          discountPercentage,
        ),
      );
    }

    if (description != null) {
      formData.fields.add(
        MapEntry('description', description),
      );
    }

    if (image != null) {
      formData.files.add(
        MapEntry(
          'image',
          await MultipartFile.fromFile(
            image.path,
            filename: image.path.split('/').last,
          ),
        ),
      );
    }

    return dio.patch(
      '/product/$id',
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
      ),
    );
  }

// Delete Product
  static Future<Response> deleteProduct({
    required String id,
  }) {
    return dio.delete('/product/$id');
  }


  // ========== dashboard =============
  static Future<Response> getDashboard() {
    return dio.get('/dashboard');
  }

  static Future<Response> getDashboardUsers() {
    return dio.get('/dashboard/users');
  }

// ============== NOTIFICATIONS =================

  static Future<Response> sendNotification({
    required String title,
    required String message,
  }) {
    return dio.post(
      '/notification/send',
      data: {
        'title': title,
        'message': message,
      },
    );
  }

  // ============== WISHLIST =================

  static Future<Response> addWishlist({
    required int productId,
  }) {
    return dio.post(
      '/wishlist',
      data: {
        'productId': productId,
      },
    );
  }

  static Future<Response> getWishlist() {
    return dio.get('/wishlist');
  }

  static Future<Response> removeWishlist({
    required int productId,
  }) {
    return dio.delete(
      '/wishlist/$productId',
    );
  }

  static Future<Response> checkWishlist({
    required int productId,
  }) {
    return dio.get(
      '/wishlist/check/$productId',
    );
  }
 }