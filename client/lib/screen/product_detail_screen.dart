import 'package:client/services/api_service.dart';
import 'package:flutter/material.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState
    extends State<ProductDetailScreen> {
  Map<String, dynamic>? product;

  bool loading = true;
  bool wishlistLoading = false;
  bool isWishlisted = false;

  @override
  void initState() {
    super.initState();

    getProduct();
    checkWishlist();
  }

  // ================= PRODUCT =================

  Future<void> getProduct() async {
    try {
      final response = await ApiService.getProductById(
        id: widget.productId.toString(),
      );

      if (!mounted) return;

      final data = response.data['data'];

      setState(() {
        product = data is Map<String, dynamic>
            ? data
            : Map<String, dynamic>.from(data ?? {});

        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      debugPrint('Get Product Error: $e');
    }
  }

  // ================= WISHLIST CHECK =================

  Future<void> checkWishlist() async {
    try {
      final response = await ApiService.checkWishlist(
        productId: widget.productId,
      );

      if (!mounted) return;

      final data = response.data['data'];

      setState(() {
        isWishlisted =
            data?['isWishlisted'] == true;
      });
    } catch (e) {
      debugPrint('Check Wishlist Error: $e');
    }
  }

  // ================= TOGGLE WISHLIST =================

  Future<void> toggleWishlist() async {
    if (wishlistLoading) return;

    setState(() {
      wishlistLoading = true;
    });

    try {
      if (isWishlisted) {
        await ApiService.removeWishlist(
          productId: widget.productId,
        );

        if (!mounted) return;

        setState(() {
          isWishlisted = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Removed from wishlist',
            ),
          ),
        );
      } else {
        await ApiService.addWishlist(
          productId: widget.productId,
        );

        if (!mounted) return;

        setState(() {
          isWishlisted = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isWishlisted
                ? 'Failed to remove from wishlist'
                : 'Failed to add to wishlist',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          wishlistLoading = false;
        });
      }
    }
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor:
      theme.colorScheme.surface,

      appBar: AppBar(
        title: const Text(
          'Product Details',
        ),
        centerTitle: false,

        actions: [
          IconButton(
            onPressed: wishlistLoading
                ? null
                : toggleWishlist,
            icon: wishlistLoading
                ? const SizedBox(
              width: 20,
              height: 20,
              child:
              CircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
                : Icon(
              isWishlisted
                  ? Icons.favorite
                  : Icons.favorite_border,
            ),
            color: isWishlisted
                ? theme.colorScheme.primary
                : null,
          ),
        ],
      ),

      body: loading
          ? const Center(
        child:
        CircularProgressIndicator(),
      )
          : product == null
          ? _errorWidget()
          : _productDetails(
        context,
        theme,
      ),
    );
  }

  // ================= DETAILS =================

  Widget _productDetails(
      BuildContext context,
      ThemeData theme,
      ) {
    final String name =
        product?['name']?.toString() ?? '';

    final String description =
        product?['description']?.toString() ?? '';

    final String image =
        product?['image']?.toString() ?? '';

    final String categoryName =
        product?['category']?['name']?.toString() ??
            'Skincare';

    final dynamic rawPrice =
    product?['price'];

    final dynamic rawDiscountPrice =
    product?['discountPrice'];

    final dynamic rawDiscountPercentage =
    product?['discountPercentage'];

    final bool hasDiscount =
        rawDiscountPrice != null;

    final String price = hasDiscount
        ? '\$${rawDiscountPrice}'
        : '\$${rawPrice ?? 0}';

    final String oldPrice =
    hasDiscount
        ? '\$${rawPrice ?? 0}'
        : '';

    final String discount =
    rawDiscountPercentage != null
        ? '${rawDiscountPercentage}% OFF'
        : '';

    return RefreshIndicator(
      onRefresh: getProduct,
      child: SingleChildScrollView(
        physics:
        const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            // ================= IMAGE =================

            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 390,
                  color: theme.colorScheme
                      .surfaceContainerHighest,
                  child: image.isNotEmpty
                      ? Image.network(
                    ApiService.imageUrl(
                      image,
                    ),
                    width: double.infinity,
                    height: 390,
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

                // Category
                Positioned(
                  top: 18,
                  left: 18,
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration:
                    BoxDecoration(
                      color: theme
                          .colorScheme.surface,
                      borderRadius:
                      BorderRadius.circular(
                        10,
                      ),
                    ),
                    child: Text(
                      categoryName,
                      style: theme
                          .textTheme.labelMedium
                          ?.copyWith(
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                // Wishlist
                Positioned(
                  top: 18,
                  right: 18,
                  child: Material(
                    color: theme
                        .colorScheme.surface,
                    shape:
                    const CircleBorder(),
                    child: InkWell(
                      customBorder:
                      const CircleBorder(),
                      onTap: wishlistLoading
                          ? null
                          : toggleWishlist,
                      child: Padding(
                        padding:
                        const EdgeInsets.all(
                          11,
                        ),
                        child: wishlistLoading
                            ? const SizedBox(
                          width: 22,
                          height: 22,
                          child:
                          CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                            : Icon(
                          isWishlisted
                              ? Icons.favorite
                              : Icons
                              .favorite_border,
                          color: isWishlisted
                              ? theme
                              .colorScheme
                              .primary
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ================= CONTENT =================

            Padding(
              padding:
              const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  // Category
                  Text(
                    categoryName
                        .toUpperCase(),
                    style: theme
                        .textTheme
                        .labelMedium
                        ?.copyWith(
                      color: theme
                          .colorScheme.primary,
                      fontWeight:
                      FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  // Name
                  Text(
                    name,
                    style: theme
                        .textTheme
                        .headlineSmall
                        ?.copyWith(
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  // Price
                  Row(
                    crossAxisAlignment:
                    CrossAxisAlignment.center,
                    children: [
                      Text(
                        price,
                        style: theme
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                          fontWeight:
                          FontWeight.w800,
                          color: theme
                              .colorScheme
                              .primary,
                        ),
                      ),

                      if (oldPrice
                          .isNotEmpty) ...[
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          oldPrice,
                          style: theme
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                            decoration:
                            TextDecoration
                                .lineThrough,
                            color: theme
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                      ],

                      if (discount
                          .isNotEmpty) ...[
                        const SizedBox(
                          width: 10,
                        ),
                        Container(
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
                                .primary
                                .withValues(
                              alpha: 0.10,
                            ),
                            borderRadius:
                            BorderRadius
                                .circular(
                              6,
                            ),
                          ),
                          child: Text(
                            discount,
                            style: theme
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                              color: theme
                                  .colorScheme
                                  .primary,
                              fontWeight:
                              FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  const Divider(),

                  const SizedBox(
                    height: 20,
                  ),

                  // Description
                  Text(
                    'Description',
                    style: theme
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Text(
                    description.isNotEmpty
                        ? description
                        : 'No description available.',
                    style: theme
                        .textTheme
                        .bodyLarge
                        ?.copyWith(
                      height: 1.6,
                      color: theme
                          .colorScheme
                          .onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(
                    height: 30,
                  ),

                  // ================= WISHLIST BUTTON =================

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed:
                      wishlistLoading
                          ? null
                          : toggleWishlist,
                      icon: Icon(
                        isWishlisted
                            ? Icons.favorite
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

                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= ERROR =================

  Widget _errorWidget() {
    return Center(
      child: Column(
        mainAxisSize:
        MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline,
            size: 60,
          ),

          const SizedBox(
            height: 12,
          ),

          const Text(
            'Product not found',
            style: TextStyle(
              fontSize: 18,
              fontWeight:
              FontWeight.w600,
            ),
          ),

          const SizedBox(
            height: 16,
          ),

          ElevatedButton(
            onPressed: () {
              setState(() {
                loading = true;
              });

              getProduct();
            },
            child: const Text(
              'Try Again',
            ),
          ),
        ],
      ),
    );
  }

  // ================= IMAGE PLACEHOLDER =================

  Widget _imagePlaceholder(
      ThemeData theme,
      ) {
    return Center(
      child: Icon(
        Icons.image_not_supported_outlined,
        size: 70,
        color: theme
            .colorScheme
            .onSurfaceVariant,
      ),
    );
  }
}