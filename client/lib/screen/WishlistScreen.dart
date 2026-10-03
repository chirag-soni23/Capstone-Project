import 'package:client/services/api_service.dart';
import 'package:flutter/material.dart';

class Wishlistscreen extends StatefulWidget {
  const Wishlistscreen({super.key});

  @override
  State<Wishlistscreen> createState() => _WishlistscreenState();
}

class _WishlistscreenState extends State<Wishlistscreen> {
  List<dynamic> wishlist = [];
  bool loading = true;
  bool refreshing = false;

  @override
  void initState() {
    super.initState();
    getWishlist();
  }

  // ================= GET WISHLIST =================

  Future<void> getWishlist({bool showLoader = true}) async {
    try {
      if (showLoader && mounted) {
        setState(() {
          loading = true;
        });
      }

      final response = await ApiService.getWishlist();

      final responseData = response.data;

      List<dynamic> data = [];

      if (responseData is Map<String, dynamic>) {
        final result = responseData['data'];

        if (result is List) {
          data = result;
        }
      }

      if (!mounted) return;

      setState(() {
        wishlist = data;
        loading = false;
        refreshing = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        refreshing = false;
      });

      debugPrint('Wishlist Error: $e');
    }
  }

  // ================= REFRESH =================

  Future<void> refreshWishlist() async {
    if (refreshing) return;

    setState(() {
      refreshing = true;
    });

    await getWishlist(showLoader: false);
  }

  // ================= REMOVE =================

  Future<void> removeFromWishlist(int productId) async {
    try {
      await ApiService.removeWishlist(
        productId: productId,
      );

      if (!mounted) return;

      // Pehle UI se remove
      setState(() {
        wishlist.removeWhere((item) {
          final product = item is Map
              ? item['product']
              : null;

          final itemProductId =
              product?['id'] ??
                  item['productId'];

          return int.tryParse(
            itemProductId.toString(),
          ) ==
              productId;
        });
      });

      // Backend se latest wishlist dobara fetch
      await getWishlist(showLoader: false);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Removed from wishlist'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      debugPrint('Remove Wishlist Error: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to remove from wishlist',
          ),
        ),
      );
    }
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist'),
        actions: [
          IconButton(
            onPressed: refreshing
                ? null
                : refreshWishlist,
            icon: refreshing
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
                : const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),

      body: loading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : wishlist.isEmpty
          ? _emptyWishlist(theme)
          : RefreshIndicator(
        onRefresh: refreshWishlist,
        child: ListView.builder(
          physics:
          const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: wishlist.length,
          itemBuilder: (
              context,
              index,
              ) {
            final item = wishlist[index];

            final product =
                item['product'] ?? item;

            final dynamic rawProductId =
                product['id'] ??
                    item['productId'];

            final int? productId =
            int.tryParse(
              rawProductId.toString(),
            );

            final String name =
                product['name']
                    ?.toString() ??
                    '';

            final String image =
                product['image']
                    ?.toString() ??
                    '';

            final String description =
                product['description']
                    ?.toString() ??
                    '';

            final dynamic discountPrice =
            product['discountPrice'];

            final dynamic originalPrice =
            product['price'];

            final bool hasDiscount =
                discountPrice != null &&
                    discountPrice
                        .toString()
                        .isNotEmpty;

            return Container(
              margin:
              const EdgeInsets.only(
                bottom: 14,
              ),
              padding:
              const EdgeInsets.all(10),
              decoration:
              BoxDecoration(
                color:
                theme.colorScheme.surface,
                borderRadius:
                BorderRadius.circular(
                  16,
                ),
                border: Border.all(
                  color: theme.colorScheme
                      .outlineVariant,
                ),
              ),
              child: Row(
                children: [
                  // IMAGE
                  ClipRRect(
                    borderRadius:
                    BorderRadius.circular(
                      12,
                    ),
                    child: image.isNotEmpty
                        ? Image.network(
                      ApiService.imageUrl(
                        image,
                      ),
                      width: 85,
                      height: 85,
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

                  const SizedBox(
                    width: 12,
                  ),

                  // PRODUCT INFO
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow:
                          TextOverflow
                              .ellipsis,
                          style:
                          const TextStyle(
                            fontSize: 16,
                            fontWeight:
                            FontWeight.w600,
                          ),
                        ),

                        const SizedBox(
                          height: 4,
                        ),

                        if (description
                            .isNotEmpty)
                          Text(
                            description,
                            maxLines: 2,
                            overflow:
                            TextOverflow
                                .ellipsis,
                            style: theme
                                .textTheme
                                .bodySmall,
                          ),

                        const SizedBox(
                          height: 8,
                        ),

                        Row(
                          children: [
                            Text(
                              hasDiscount
                                  ? '\$$discountPrice'
                                  : '\$$originalPrice',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight:
                                FontWeight
                                    .bold,
                                color: theme
                                    .colorScheme
                                    .primary,
                              ),
                            ),

                            if (hasDiscount &&
                                originalPrice !=
                                    null) ...[
                              const SizedBox(
                                width: 8,
                              ),
                              Text(
                                '\$$originalPrice',
                                style:
                                const TextStyle(
                                  fontSize: 13,
                                  decoration:
                                  TextDecoration
                                      .lineThrough,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // REMOVE HEART
                  IconButton(
                    onPressed:
                    productId == null
                        ? null
                        : () {
                      removeFromWishlist(
                        productId,
                      );
                    },
                    icon: const Icon(
                      Icons.favorite,
                    ),
                    color: theme
                        .colorScheme
                        .primary,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ================= EMPTY =================

  Widget _emptyWishlist(
      ThemeData theme,
      ) {
    return RefreshIndicator(
      onRefresh: refreshWishlist,
      child: ListView(
        physics:
        const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height:
            MediaQuery.of(context).size.height *
                0.35,
          ),
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 70,
                  color:
                  theme.colorScheme.primary,
                ),
                const SizedBox(
                  height: 14,
                ),
                const Text(
                  'Your wishlist is empty',
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
                  'Add products you love to your wishlist',
                ),
                const SizedBox(
                  height: 15,
                ),
                const Text(
                  'Pull down to refresh',
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= IMAGE =================

  Widget _imagePlaceholder(
      ThemeData theme,
      ) {
    return Container(
      width: 85,
      height: 85,
      color: theme
          .colorScheme
          .surfaceContainerHighest,
      child: const Icon(
        Icons.image_not_supported,
      ),
    );
  }
}