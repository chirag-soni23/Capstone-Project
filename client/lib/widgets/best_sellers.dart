import 'package:client/screen/product_detail_screen.dart';
import 'package:client/services/api_service.dart';
import 'package:flutter/material.dart';

class BestSellers extends StatefulWidget {
  const BestSellers({super.key});

  @override
  State<BestSellers> createState() => _BestSellersState();
}

class _BestSellersState extends State<BestSellers> {
  List<dynamic> products = [];

  // productId -> wishlist status
  final Map<int, bool> wishlistStatus = {};

  // productId -> loading
  final Map<int, bool> wishlistLoading = {};

  bool loading = true;

  @override
  void initState() {
    super.initState();
    getProducts();
  }

  Future<void> getProducts() async {
    try {
      final response = await ApiService.getProducts(
        page: 1,
        limit: 10,
      );

      if (!mounted) return;

      final data = response.data['data'];

      setState(() {
        products = data is Map
            ? (data['products'] is List ? data['products'] : [])
            : [];

        loading = false;
      });

      // Check wishlist status for every product
      await checkAllWishlist();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      debugPrint('Get Products Error: $e');
    }
  }

  Future<void> checkAllWishlist() async {
    for (final product in products) {
      final dynamic rawId = product['id'];

      final int? productId = rawId is int
          ? rawId
          : int.tryParse(rawId?.toString() ?? '');

      if (productId == null) continue;

      try {
        final response = await ApiService.checkWishlist(
          productId: productId,
        );

        if (!mounted) return;

        final data = response.data['data'];

        final bool isWishlisted =
            data is Map && data['isWishlisted'] == true;

        setState(() {
          wishlistStatus[productId] = isWishlisted;
        });
      } catch (e) {
        debugPrint(
          'Check Wishlist Error [$productId]: $e',
        );

        if (!mounted) return;

        setState(() {
          wishlistStatus[productId] = false;
        });
      }
    }
  }

  Future<void> toggleWishlist(
      int productId,
      ) async {
    if (wishlistLoading[productId] == true) {
      return;
    }

    setState(() {
      wishlistLoading[productId] = true;
    });

    final bool currentlyWishlisted =
        wishlistStatus[productId] ?? false;

    try {
      if (currentlyWishlisted) {
        await ApiService.removeWishlist(
          productId: productId,
        );

        if (!mounted) return;

        setState(() {
          wishlistStatus[productId] = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Removed from wishlist',
            ),
            duration: Duration(seconds: 1),
          ),
        );
      } else {
        await ApiService.addWishlist(
          productId: productId,
        );

        if (!mounted) return;

        setState(() {
          wishlistStatus[productId] = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Added to wishlist',
            ),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      debugPrint(
        'Wishlist Error [$productId]: $e',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            currentlyWishlisted
                ? 'Failed to remove from wishlist'
                : 'Failed to add to wishlist',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        wishlistLoading[productId] = false;
      });
    }
  }

  void openProduct(dynamic product) {
    final dynamic rawId = product['id'];

    final int? productId = rawId is int
        ? rawId
        : int.tryParse(
      rawId?.toString() ?? '',
    );

    if (productId == null) {
      debugPrint(
        'Invalid Product ID: $rawId',
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(
          productId: productId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'ICONIC FORMULAS',
                  style:
                  theme.textTheme.labelSmall?.copyWith(
                    color:
                    theme.colorScheme.primary,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Best Sellers',
                  style:
                  theme.textTheme.headlineSmall,
                ),
              ],
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'See All ›',
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        if (loading)
          const SizedBox(
            height: 330,
            child: Center(
              child:
              CircularProgressIndicator(),
            ),
          )
        else if (products.isEmpty)
          const SizedBox(
            height: 200,
            child: Center(
              child: Text(
                'No products found',
              ),
            ),
          )
        else
          SizedBox(
            height: 330,
            child: ListView.builder(
              scrollDirection:
              Axis.horizontal,
              itemCount: products.length,
              itemBuilder:
                  (context, index) {
                final product =
                products[index];

                return _productCard(
                  context,
                  product,
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _productCard(
      BuildContext context,
      dynamic product,
      ) {
    final theme =
    Theme.of(context);

    final String name =
        product['name']?.toString() ?? '';

    final String description =
        product['description']
            ?.toString() ??
            '';

    final String image =
        product['image']?.toString() ??
            '';

    final dynamic rawId =
    product['id'];

    final int? productId =
    rawId is int
        ? rawId
        : int.tryParse(
      rawId?.toString() ?? '',
    );

    final String price =
    product['discountPrice'] != null
        ? '\$${product['discountPrice']}'
        : '\$${product['price'] ?? 0}';

    final String oldPrice =
    product['discountPrice'] != null
        ? '\$${product['price'] ?? 0}'
        : '';

    final String discountPercentage =
    product['discountPercentage'] != null
        ? '${product['discountPercentage']}% OFF'
        : '';

    final String categoryName =
        product['category']?['name']
            ?.toString() ??
            'Skincare';

    final bool isWishlisted =
        productId != null &&
            (wishlistStatus[productId] ??
                false);

    final bool isWishlistLoading =
        productId != null &&
            (wishlistLoading[productId] ??
                false);

    return GestureDetector(
      onTap: () {
        openProduct(product);
      },
      child: Container(
        width: 228,
        margin:
        const EdgeInsets.only(
          right: 14,
        ),
        padding:
        const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color:
          theme.colorScheme.surface,
          borderRadius:
          BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                  BorderRadius.circular(
                    13,
                  ),
                  child: image.isNotEmpty
                      ? Image.network(
                    ApiService.imageUrl(
                      image,
                    ),
                    width:
                    double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (
                        context,
                        error,
                        stackTrace,
                        ) {
                      return _imagePlaceholder(
                        theme,
                      );
                    },
                  )
                      : _imagePlaceholder(
                    theme,
                  ),
                ),

                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding:
                    const EdgeInsets
                        .symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration:
                    BoxDecoration(
                      color: theme
                          .colorScheme
                          .surface,
                      borderRadius:
                      BorderRadius
                          .circular(
                        8,
                      ),
                    ),
                    child: Text(
                      categoryName,
                      style: theme
                          .textTheme
                          .labelSmall,
                    ),
                  ),
                ),

                // Wishlist Button
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: productId == null ||
                        isWishlistLoading
                        ? null
                        : () {
                      toggleWishlist(
                        productId,
                      );
                    },
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor:
                      theme.colorScheme
                          .surface,
                      child:
                      isWishlistLoading
                          ? SizedBox(
                        width: 15,
                        height: 15,
                        child:
                        CircularProgressIndicator(
                          strokeWidth:
                          2,
                          color: theme
                              .colorScheme
                              .primary,
                        ),
                      )
                          : Icon(
                        isWishlisted
                            ? Icons
                            .favorite
                            : Icons
                            .favorite_border,
                        size: 18,
                        color: theme
                            .colorScheme
                            .primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              categoryName,
              maxLines: 1,
              overflow:
              TextOverflow.ellipsis,
              style: theme
                  .textTheme
                  .bodySmall
                  ?.copyWith(
                color: theme
                    .colorScheme
                    .primary,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              name,
              maxLines: 1,
              overflow:
              TextOverflow.ellipsis,
              style:
              theme.textTheme.titleMedium,
            ),

            Text(
              description,
              maxLines: 1,
              overflow:
              TextOverflow.ellipsis,
              style:
              theme.textTheme.bodySmall,
            ),

            const Spacer(),

            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          price,
                          maxLines: 1,
                          overflow:
                          TextOverflow
                              .ellipsis,
                          style: theme
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                            fontWeight:
                            FontWeight
                                .w700,
                          ),
                        ),
                      ),

                      if (oldPrice
                          .isNotEmpty) ...[
                        const SizedBox(
                          width: 6,
                        ),
                        Flexible(
                          child: Text(
                            oldPrice,
                            maxLines: 1,
                            overflow:
                            TextOverflow
                                .ellipsis,
                            style:
                            const TextStyle(
                              decoration:
                              TextDecoration
                                  .lineThrough,
                            ),
                          ),
                        ),
                      ],

                      if (discountPercentage
                          .isNotEmpty) ...[
                        const SizedBox(
                          width: 5,
                        ),
                        Flexible(
                          child: Text(
                            discountPercentage,
                            maxLines: 1,
                            overflow:
                            TextOverflow
                                .ellipsis,
                            style: theme
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                              color: theme
                                  .colorScheme
                                  .primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(
                  width: 6,
                ),

                CircleAvatar(
                  radius: 17,
                  backgroundColor:
                  theme.colorScheme
                      .primary,
                  child: Icon(
                    Icons.add,
                    color: theme.colorScheme
                        .onPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder(
      ThemeData theme,
      ) {
    return Container(
      width: double.infinity,
      height: 180,
      color: theme.colorScheme
          .surfaceContainerHighest,
      child: const Icon(
        Icons
            .image_not_supported_outlined,
        size: 45,
      ),
    );
  }
}