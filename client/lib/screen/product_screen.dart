import 'package:client/services/api_service.dart';
import 'package:flutter/material.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  List<dynamic> products = [];

  bool loading = true;
  bool loadingMore = false;

  int page = 1;
  final int limit = 10;

  bool hasMore = true;

  final TextEditingController searchController =
  TextEditingController();

  String search = '';

  @override
  void initState() {
    super.initState();
    getProducts();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> getProducts({
    bool refresh = false,
  }) async {
    if (refresh) {
      page = 1;
      hasMore = true;
    }

    if (!hasMore && !refresh) return;

    if (page == 1) {
      setState(() {
        loading = true;
      });
    } else {
      setState(() {
        loadingMore = true;
      });
    }

    try {
      final response = await ApiService.getProducts(
        page: page,
        limit: limit,
        search: search,
      );

      debugPrint(
        'Products Response: ${response.data}',
      );

      if (!mounted) return;

      final responseData = response.data;

      List<dynamic> newProducts = [];

      if (responseData is Map) {
        final data = responseData['data'];

        if (data is List) {
          newProducts = data;
        } else if (data is Map) {
          if (data['products'] is List) {
            newProducts = data['products'];
          } else if (data['data'] is List) {
            newProducts = data['data'];
          }
        }
      } else if (responseData is List) {
        newProducts = responseData;
      }

      setState(() {
        if (page == 1) {
          products = newProducts;
        } else {
          products.addAll(newProducts);
        }

        if (newProducts.length < limit) {
          hasMore = false;
        } else {
          page++;
        }

        loading = false;
        loadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        loadingMore = false;
      });

      debugPrint(
        'Get Products Error: $e',
      );
    }
  }

  Future<void> searchProducts(String value) async {
    search = value.trim();
    page = 1;
    hasMore = true;

    await getProducts(
      refresh: true,
    );
  }

  int? getProductId(dynamic product) {
    if (product is! Map) return null;

    final id = product['id'];

    return int.tryParse(
      id?.toString() ?? '',
    );
  }

  String getProductName(dynamic product) {
    if (product is! Map) {
      return 'Product';
    }

    return product['name']?.toString() ??
        product['title']?.toString() ??
        'Product';
  }

  String getProductImage(dynamic product) {
    if (product is! Map) return '';

    return product['image']?.toString() ??
        product['imageUrl']?.toString() ??
        product['thumbnail']?.toString() ??
        '';
  }

  String getProductDescription(dynamic product) {
    if (product is! Map) return '';

    return product['description']?.toString() ?? '';
  }

  dynamic getProductPrice(dynamic product) {
    if (product is! Map) return 0;

    return product['price'] ?? 0;
  }

  dynamic getDiscountPrice(dynamic product) {
    if (product is! Map) return null;

    return product['discountPrice'];
  }

  bool hasDiscount(dynamic product) {
    final discount = getDiscountPrice(product);

    return discount != null &&
        discount.toString() != '0' &&
        discount.toString() != '0.0' &&
        discount.toString().isNotEmpty;
  }

  Future<void> addToWishlist(int productId) async {
    try {
      await ApiService.addWishlist(
        productId: productId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Added to wishlist',
          ),
        ),
      );

      setState(() {});
    } catch (e) {
      debugPrint(
        'Add Wishlist Error: $e',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().contains(
              'already exists',
            )
                ? 'Product already in wishlist'
                : 'Failed to add to wishlist',
          ),
        ),
      );
    }
  }

  Future<void> removeFromWishlist(
      int productId,
      ) async {
    try {
      await ApiService.removeWishlist(
        productId: productId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Removed from wishlist',
          ),
        ),
      );

      setState(() {});
    } catch (e) {
      debugPrint(
        'Remove Wishlist Error: $e',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to remove from wishlist',
          ),
        ),
      );
    }
  }

  Future<bool> checkWishlist(
      int productId,
      ) async {
    try {
      final response =
      await ApiService.checkWishlist(
        productId: productId,
      );

      final data = response.data;

      if (data is Map) {
        if (data['data'] is Map) {
          return data['data']['isWishlisted'] ==
              true;
        }

        return data['isWishlisted'] == true;
      }

      return false;
    } catch (e) {
      debugPrint(
        'Check Wishlist Error: $e',
      );

      return false;
    }
  }

  void openProductDetail(
      dynamic product,
      ) {
    final productId =
    getProductId(product);

    if (productId == null) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ProductDetailScreen(
              product: product,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Products',
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              12,
              16,
              8,
            ),
            child: TextField(
              controller: searchController,
              textInputAction:
              TextInputAction.search,
              onSubmitted: searchProducts,
              decoration: InputDecoration(
                hintText:
                'Search products...',
                prefixIcon: const Icon(
                  Icons.search,
                ),
                suffixIcon:
                searchController.text.isNotEmpty
                    ? IconButton(
                  onPressed: () {
                    searchController
                        .clear();

                    searchProducts('');
                  },
                  icon: const Icon(
                    Icons.clear,
                  ),
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(14),
                ),
              ),
            ),
          ),

          Expanded(
            child: loading
                ? const Center(
              child:
              CircularProgressIndicator(),
            )
                : products.isEmpty
                ? _emptyProducts(
              theme,
            )
                : RefreshIndicator(
              onRefresh: () =>
                  getProducts(
                    refresh: true,
                  ),
              child:
              NotificationListener<
                  ScrollNotification>(
                onNotification:
                    (notification) {
                  if (notification
                  is ScrollEndNotification &&
                      notification
                          .metrics
                          .pixels >=
                          notification
                              .metrics
                              .maxScrollExtent -
                              200) {
                    getProducts();
                  }

                  return false;
                },
                child:
                GridView.builder(
                  physics:
                  const AlwaysScrollableScrollPhysics(),
                  padding:
                  const EdgeInsets.all(
                    16,
                  ),
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio:
                    0.68,
                  ),
                  itemCount:
                  products.length +
                      (loadingMore
                          ? 1
                          : 0),
                  itemBuilder:
                      (
                      context,
                      index,
                      ) {
                    if (index >=
                        products.length) {
                      return const Center(
                        child:
                        CircularProgressIndicator(),
                      );
                    }

                    final product =
                    products[index];

                    return _productCard(
                      theme,
                      product,
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _productCard(
      ThemeData theme,
      dynamic product,
      ) {
    final productId =
    getProductId(product);

    final name =
    getProductName(product);

    final image =
    getProductImage(product);

    final description =
    getProductDescription(product);

    final price =
    getProductPrice(product);

    final discountPrice =
    getDiscountPrice(product);

    return FutureBuilder<bool>(
      future: productId == null
          ? Future.value(false)
          : checkWishlist(
        productId,
      ),
      builder: (
          context,
          snapshot,
          ) {
        final isWishlisted =
            snapshot.data ?? false;

        return InkWell(
          borderRadius:
          BorderRadius.circular(16),
          onTap: () {
            openProductDetail(
              product,
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color:
              theme.colorScheme.surface,
              borderRadius:
              BorderRadius.circular(16),
              border: Border.all(
                color: theme
                    .colorScheme
                    .outlineVariant,
              ),
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius:
                        const BorderRadius
                            .vertical(
                          top:
                          Radius.circular(16),
                        ),
                        child: image.isNotEmpty
                            ? Image.network(
                          ApiService.imageUrl(
                            image,
                          ),
                          width:
                          double.infinity,
                          height:
                          double.infinity,
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

                      if (productId != null)
                        Positioned(
                          top: 8,
                          right: 8,
                          child:
                          Material(
                            color: theme
                                .colorScheme
                                .surface
                                .withValues(
                              alpha: 0.9,
                            ),
                            shape:
                            const CircleBorder(),
                            child: IconButton(
                              onPressed: () async {
                                if (isWishlisted) {
                                  await removeFromWishlist(
                                    productId,
                                  );
                                } else {
                                  await addToWishlist(
                                    productId,
                                  );
                                }

                                setState(() {});
                              },
                              icon: Icon(
                                isWishlisted
                                    ? Icons.favorite
                                    : Icons
                                    .favorite_border,
                                color: isWishlisted
                                    ? theme
                                    .colorScheme
                                    .primary
                                    : theme
                                    .colorScheme
                                    .onSurface,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                Padding(
                  padding:
                  const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow:
                        TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight:
                          FontWeight.w600,
                        ),
                      ),

                      if (description
                          .isNotEmpty) ...[
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          description,
                          maxLines: 2,
                          overflow:
                          TextOverflow.ellipsis,
                          style: theme
                              .textTheme
                              .bodySmall,
                        ),
                      ],

                      const SizedBox(
                        height: 8,
                      ),

                      if (hasDiscount(
                        product,
                      ))
                        Row(
                          children: [
                            Text(
                              '\$$discountPrice',
                              style:
                              TextStyle(
                                fontSize:
                                16,
                                fontWeight:
                                FontWeight
                                    .bold,
                                color: theme
                                    .colorScheme
                                    .primary,
                              ),
                            ),
                            const SizedBox(
                              width: 6,
                            ),
                            Text(
                              '\$$price',
                              style:
                              TextStyle(
                                fontSize:
                                12,
                                decoration:
                                TextDecoration
                                    .lineThrough,
                                color: theme
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                          ],
                        )
                      else
                        Text(
                          '\$$price',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                            FontWeight.bold,
                            color: theme
                                .colorScheme
                                .primary,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _emptyProducts(
      ThemeData theme,
      ) {
    return Center(
      child: Column(
        mainAxisSize:
        MainAxisSize.min,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 70,
            color:
            theme.colorScheme.primary,
          ),
          const SizedBox(
            height: 14,
          ),
          const Text(
            'No products found',
            style: TextStyle(
              fontSize: 18,
              fontWeight:
              FontWeight.w600,
            ),
          ),
          const SizedBox(
            height: 6,
          ),
          const Text(
            'Try searching for another product',
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder(
      ThemeData theme,
      ) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: theme
          .colorScheme
          .surfaceContainerHighest,
      child: const Icon(
        Icons.image_not_supported,
        size: 40,
      ),
    );
  }
}


// =====================================================
// PRODUCT DETAIL SCREEN
// =====================================================

class ProductDetailScreen
    extends StatefulWidget {
  final dynamic product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState
    extends State<ProductDetailScreen> {
  bool isWishlisted = false;
  bool wishlistLoading = true;

  int? get productId {
    final id =
    widget.product['id'];

    return int.tryParse(
      id?.toString() ?? '',
    );
  }

  String get name {
    return widget.product['name']
        ?.toString() ??
        widget.product['title']
            ?.toString() ??
        'Product';
  }

  String get image {
    return widget.product['image']
        ?.toString() ??
        widget.product['imageUrl']
            ?.toString() ??
        '';
  }

  String get description {
    return widget.product['description']
        ?.toString() ??
        '';
  }

  dynamic get price {
    return widget.product['price'] ??
        0;
  }

  dynamic get discountPrice {
    return widget.product[
    'discountPrice'];
  }

  bool get hasDiscount {
    return discountPrice != null &&
        discountPrice.toString() !=
            '0' &&
        discountPrice.toString() !=
            '0.0';
  }

  @override
  void initState() {
    super.initState();
    loadWishlistStatus();
  }

  Future<void> loadWishlistStatus() async {
    if (productId == null) {
      setState(() {
        wishlistLoading = false;
      });
      return;
    }

    try {
      final response =
      await ApiService.checkWishlist(
        productId: productId!,
      );

      final data = response.data;

      bool status = false;

      if (data is Map) {
        if (data['data'] is Map) {
          status =
              data['data']['isWishlisted'] ==
                  true;
        } else {
          status =
              data['isWishlisted'] == true;
        }
      }

      if (!mounted) return;

      setState(() {
        isWishlisted = status;
        wishlistLoading = false;
      });
    } catch (e) {
      debugPrint(
        'Check Wishlist Error: $e',
      );

      if (!mounted) return;

      setState(() {
        wishlistLoading = false;
      });
    }
  }

  Future<void> toggleWishlist() async {
    if (productId == null) return;

    try {
      if (isWishlisted) {
        await ApiService.removeWishlist(
          productId: productId!,
        );

        if (!mounted) return;

        setState(() {
          isWishlisted = false;
        });

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'Removed from wishlist',
            ),
          ),
        );
      } else {
        await ApiService.addWishlist(
          productId: productId!,
        );

        if (!mounted) return;

        setState(() {
          isWishlisted = true;
        });

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'Added to wishlist',
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint(
        'Wishlist Error: $e',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Wishlist operation failed',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme =
    Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Product Details',
        ),
        actions: [
          if (!wishlistLoading)
            IconButton(
              onPressed:
              toggleWishlist,
              icon: Icon(
                isWishlisted
                    ? Icons.favorite
                    : Icons.favorite_border,
              ),
              color: isWishlisted
                  ? theme
                  .colorScheme
                  .primary
                  : null,
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              height: 350,
              child: image.isNotEmpty
                  ? Image.network(
                ApiService.imageUrl(
                  image,
                ),
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

            Padding(
              padding:
              const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style:
                    const TextStyle(
                      fontSize: 24,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  if (hasDiscount)
                    Row(
                      children: [
                        Text(
                          '\$$discountPrice',
                          style:
                          TextStyle(
                            fontSize: 24,
                            fontWeight:
                            FontWeight.bold,
                            color: theme
                                .colorScheme
                                .primary,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          '\$$price',
                          style:
                          const TextStyle(
                            fontSize: 16,
                            decoration:
                            TextDecoration
                                .lineThrough,
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      '\$$price',
                      style:
                      TextStyle(
                        fontSize: 24,
                        fontWeight:
                        FontWeight.bold,
                        color: theme
                            .colorScheme
                            .primary,
                      ),
                    ),

                  const SizedBox(
                    height: 20,
                  ),

                  const Text(
                    'Description',
                    style:
                    TextStyle(
                      fontSize: 18,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  Text(
                    description.isNotEmpty
                        ? description
                        : 'No description available.',
                    style: theme
                        .textTheme
                        .bodyLarge,
                  ),

                  const SizedBox(
                    height: 30,
                  ),

                  SizedBox(
                    width:
                    double.infinity,
                    height: 52,
                    child:
                    ElevatedButton.icon(
                      onPressed:
                      toggleWishlist,
                      icon: Icon(
                        isWishlisted
                            ? Icons
                            .favorite
                            : Icons
                            .favorite_border,
                      ),
                      label: Text(
                        isWishlisted
                            ? 'Remove from Wishlist'
                            : 'Add to Wishlist',
                      ),
                    ),
                  ),
                ],
              ),
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
      color: theme
          .colorScheme
          .surfaceContainerHighest,
      child: const Center(
        child: Icon(
          Icons.image_not_supported,
          size: 60,
        ),
      ),
    );
  }
}