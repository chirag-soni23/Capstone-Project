import 'dart:io';

import 'package:client/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AdminProductScreen extends StatefulWidget {
  const AdminProductScreen({super.key});

  @override
  State<AdminProductScreen> createState() => _AdminProductScreenState();
}

class _AdminProductScreenState extends State<AdminProductScreen> {
  final ImagePicker _picker = ImagePicker();

  List<dynamic> products = [];
  List<dynamic> categories = [];

  bool loading = true;
  bool categoriesLoading = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    await Future.wait([
      getProducts(),
      getCategories(),
    ]);
  }

  Future<void> getProducts() async {
    try {
      final response = await ApiService.getProducts(
        page: 1,
        limit: 50,
      );

      if (!mounted) return;

      setState(() {
        products = response.data['data']['products'] ?? [];
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      _showMessage('Failed to load products');
      debugPrint('Products Error: $e');
    }
  }

  Future<void> getCategories() async {
    try {
      setState(() => categoriesLoading = true);

      final response = await ApiService.getCategories(
        page: 1,
        limit: 50,
      );

      if (!mounted) return;

      setState(() {
        categories = response.data['data']['categories'] ?? [];
        categoriesLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => categoriesLoading = false);
      debugPrint('Categories Error: $e');
    }
  }

  Future<File?> pickImage() async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (picked == null) return null;

      return File(picked.path);
    } catch (e) {
      debugPrint('Image Picker Error: $e');

      if (mounted) {
        _showMessage('Unable to pick image');
      }

      return null;
    }
  }

  Future<void> addProduct() async {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final descriptionController = TextEditingController();
    final discountController = TextEditingController();

    File? image;
    int? selectedCategoryId;
    bool saving = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> selectImage() async {
              final selected = await pickImage();

              if (selected != null) {
                setDialogState(() {
                  image = selected;
                });
              }
            }

            Future<void> save() async {
              if (nameController.text.trim().isEmpty) {
                _showMessage('Product name is required');
                return;
              }

              if (selectedCategoryId == null) {
                _showMessage('Please select a category');
                return;
              }

              if (priceController.text.trim().isEmpty) {
                _showMessage('Price is required');
                return;
              }

              if (image == null) {
                _showMessage('Product image is required');
                return;
              }

              try {
                setDialogState(() => saving = true);

                await ApiService.createProduct(
                  name: nameController.text.trim(),
                  categoryId: selectedCategoryId!,
                  price: priceController.text.trim(),
                  discountPercentage:
                  discountController.text.trim().isEmpty
                      ? null
                      : discountController.text.trim(),
                  description:
                  descriptionController.text.trim().isEmpty
                      ? null
                      : descriptionController.text.trim(),
                  image: image!,
                );

                if (!mounted) return;

                Navigator.pop(dialogContext);

                _showMessage('Product added successfully');

                await getProducts();
              } catch (e) {
                setDialogState(() => saving = false);

                debugPrint('Create Product Error: $e');

                if (mounted) {
                  _showMessage('Failed to add product');
                }
              }
            }

            return AlertDialog(
              title: const Text('Add Product'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: saving ? null : selectImage,
                      child: Container(
                        width: double.infinity,
                        height: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .outlineVariant,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: image != null
                            ? Image.file(
                          image!,
                          fit: BoxFit.cover,
                        )
                            : const Column(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 40,
                            ),
                            SizedBox(height: 8),
                            Text('Select Product Image'),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: nameController,
                      enabled: !saving,
                      decoration: const InputDecoration(
                        labelText: 'Product Name',
                        prefixIcon: Icon(Icons.inventory_2_outlined),
                      ),
                    ),

                    const SizedBox(height: 12),

                    DropdownButtonFormField<int>(
                      initialValue: selectedCategoryId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items: categories.map<DropdownMenuItem<int>>((category) {
                        return DropdownMenuItem<int>(
                          value: category['id'],
                          child: Text(
                            category['name'] ?? '',
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: saving
                          ? null
                          : (value) {
                        setDialogState(() {
                          selectedCategoryId = value;
                        });
                      },
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: priceController,
                      enabled: !saving,
                      keyboardType:
                      const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        prefixIcon: Icon(Icons.currency_rupee),
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: discountController,
                      enabled: !saving,
                      keyboardType:
                      const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Discount Percentage',
                        hintText: 'Example: 20',
                        prefixIcon: Icon(Icons.percent),
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: descriptionController,
                      enabled: !saving,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        prefixIcon: Icon(Icons.description_outlined),
                        alignLabelWithHint: true,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: saving
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: saving ? null : save,
                  child: saving
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : const Text('Add Product'),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    discountController.dispose();
  }

  Future<void> deleteProduct(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Product'),
          content: const Text(
            'Are you sure you want to delete this product?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await ApiService.deleteProduct(id: id);

      if (!mounted) return;

      _showMessage('Product deleted successfully');
      await getProducts();
    } catch (e) {
      debugPrint('Delete Product Error: $e');

      if (mounted) {
        _showMessage('Failed to delete product');
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            onPressed: loadData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: categoriesLoading ? null : addProduct,
        child: const Icon(Icons.add),
      ),
      body: loading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : products.isEmpty
          ? RefreshIndicator(
        onRefresh: loadData,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 250),
            Center(
              child: Text('No products found'),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: loadData,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];

            final String image =
                product['image']?.toString() ?? '';

            final String name =
                product['name']?.toString() ?? '';

            final String description =
                product['description']?.toString() ?? '';

            final String category =
                product['category']?['name']?.toString() ??
                    'No Category';

            final double price = double.tryParse(
              product['price']?.toString() ?? '0',
            ) ??
                0;

            final double discountPercentage =
                double.tryParse(
                  product['discountPercentage']
                      ?.toString() ??
                      '0',
                ) ??
                    0;

            final double discountPrice =
                price -
                    (price * discountPercentage / 100);

            return Card(
              margin: const EdgeInsets.only(bottom: 14),
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius:
                      BorderRadius.circular(12),
                      child: image.isNotEmpty
                          ? Image.network(
                        ApiService.imageUrl(image),
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) {
                          return _imagePlaceholder();
                        },
                      )
                          : _imagePlaceholder(),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow:
                            TextOverflow.ellipsis,
                            style: theme.textTheme
                                .titleMedium
                                ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            category,
                            maxLines: 1,
                            overflow:
                            TextOverflow.ellipsis,
                            style: TextStyle(
                              color: theme
                                  .colorScheme.primary,
                              fontSize: 13,
                            ),
                          ),

                          const SizedBox(height: 5),

                          if (description.isNotEmpty)
                            Text(
                              description,
                              maxLines: 2,
                              overflow:
                              TextOverflow.ellipsis,
                              style: theme
                                  .textTheme.bodySmall,
                            ),

                          const SizedBox(height: 7),

                          Wrap(
                            spacing: 7,
                            runSpacing: 4,
                            crossAxisAlignment:
                            WrapCrossAlignment.center,
                            children: [
                              Text(
                                '₹${discountPrice.toStringAsFixed(2)}',
                                style: theme
                                    .textTheme.titleSmall
                                    ?.copyWith(
                                  fontWeight:
                                  FontWeight.bold,
                                ),
                              ),
                              if (discountPercentage > 0)
                                Text(
                                  '₹${price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    decoration:
                                    TextDecoration
                                        .lineThrough,
                                    fontSize: 12,
                                  ),
                                ),
                              if (discountPercentage > 0)
                                Text(
                                  '${discountPercentage.toStringAsFixed(0)}% OFF',
                                  style: TextStyle(
                                    color: theme
                                        .colorScheme
                                        .primary,
                                    fontSize: 12,
                                    fontWeight:
                                    FontWeight.w600,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 4),

                    IconButton(
                      tooltip: 'Delete',
                      onPressed: () {
                        deleteProduct(
                          product['id'].toString(),
                        );
                      },
                      icon: const Icon(
                        Icons.delete_outline,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 90,
      height: 90,
      color: Theme.of(context)
          .colorScheme
          .surfaceContainerHighest,
      child: const Icon(
        Icons.image_not_supported_outlined,
      ),
    );
  }
}