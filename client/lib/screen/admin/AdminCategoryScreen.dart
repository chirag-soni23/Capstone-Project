import 'dart:io';

import 'package:client/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AdminCategoryScreen extends StatefulWidget {
  const AdminCategoryScreen({super.key});

  @override
  State<AdminCategoryScreen> createState() => _AdminCategoryScreenState();
}

class _AdminCategoryScreenState extends State<AdminCategoryScreen> {
  List<dynamic> categories = [];
  bool loading = true;

  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    getCategories();
  }

  // ================= GET =================

  Future<void> getCategories() async {
    try {
      setState(() => loading = true);

      final response = await ApiService.getCategories(
        limit: 50,
      );

      if (!mounted) return;

      if (response.data['success'] == true) {
        setState(() {
          categories =
              response.data['data']['categories'] ?? [];
          loading = false;
        });
      } else {
        setState(() => loading = false);
      }
    } catch (e) {
      print('Get Category Error: $e');

      if (!mounted) return;

      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load categories'),
        ),
      );
    }
  }

  // ================= IMAGE PICKER =================

  Future<File?> pickImage() async {
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile == null) return null;

    return File(pickedFile.path);
  }

  // ================= ADD =================

  void showAddCategoryDialog() {
    final nameController = TextEditingController();
    File? selectedImage;
    bool submitting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Category'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Category Name',
                        hintText: 'Enter category name',
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                    ),

                    const SizedBox(height: 20),

                    GestureDetector(
                      onTap: submitting
                          ? null
                          : () async {
                        final image = await pickImage();

                        if (image != null) {
                          setDialogState(() {
                            selectedImage = image;
                          });
                        }
                      },
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        child: selectedImage == null
                            ? const Column(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 45,
                            ),
                            SizedBox(height: 8),
                            Text('Select Category Image'),
                          ],
                        )
                            : ClipRRect(
                          borderRadius:
                          BorderRadius.circular(12),
                          child: Image.file(
                            selectedImage!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: submitting
                      ? null
                      : () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: submitting
                      ? null
                      : () async {
                    if (nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                          Text('Category name is required'),
                        ),
                      );
                      return;
                    }

                    if (selectedImage == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                          Text('Category image is required'),
                        ),
                      );
                      return;
                    }

                    setDialogState(() {
                      submitting = true;
                    });

                    try {
                      final response =
                      await ApiService.createCategory(
                        name: nameController.text.trim(),
                        image: selectedImage!,
                      );

                      if (!mounted) return;

                      if (response.data['success'] == true) {
                        Navigator.pop(dialogContext);

                        await getCategories();

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Category created successfully',
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      setDialogState(() {
                        submitting = false;
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Failed to create category: $e',
                          ),
                        ),
                      );
                    }
                  },
                  child: submitting
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ================= UPDATE =================

  void showUpdateCategoryDialog(dynamic category) {
    final nameController = TextEditingController(
      text: category['name'] ?? '',
    );

    File? selectedImage;
    bool submitting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Update Category'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Category Name',
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                    ),

                    const SizedBox(height: 20),

                    GestureDetector(
                      onTap: submitting
                          ? null
                          : () async {
                        final image = await pickImage();

                        if (image != null) {
                          setDialogState(() {
                            selectedImage = image;
                          });
                        }
                      },
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        child: selectedImage != null
                            ? ClipRRect(
                          borderRadius:
                          BorderRadius.circular(12),
                          child: Image.file(
                            selectedImage!,
                            fit: BoxFit.cover,
                          ),
                        )
                            : ClipRRect(
                          borderRadius:
                          BorderRadius.circular(12),
                          child: Image.network(
                            'http://192.168.56.1:3000${category['image']}',
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) {
                              return const Column(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_not_supported,
                                    size: 40,
                                  ),
                                  Text('Change Image'),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Tap image to change',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: submitting
                      ? null
                      : () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: submitting
                      ? null
                      : () async {
                    if (nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                          Text('Category name is required'),
                        ),
                      );
                      return;
                    }

                    setDialogState(() {
                      submitting = true;
                    });

                    try {
                      final response =
                      await ApiService.updateCategory(
                        id: category['id'].toString(),
                        name: nameController.text.trim(),
                        image: selectedImage,
                      );

                      if (!mounted) return;

                      if (response.data['success'] == true) {
                        Navigator.pop(dialogContext);

                        await getCategories();

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Category updated successfully',
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      setDialogState(() {
                        submitting = false;
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Failed to update category: $e',
                          ),
                        ),
                      );
                    }
                  },
                  child: submitting
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ================= DELETE =================

  Future<void> deleteCategory(dynamic category) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Category'),
          content: Text(
            'Are you sure you want to delete "${category['name']}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      final response = await ApiService.deleteCategory(
        id: category['id'].toString(),
      );

      if (!mounted) return;

      if (response.data['success'] == true) {
        await getCategories();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Category deleted successfully'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete category: $e'),
        ),
      );
    }
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : categories.isEmpty
          ? const Center(
        child: Text(
          'No categories found',
          style: TextStyle(fontSize: 18),
        ),
      )
          : RefreshIndicator(
        onRefresh: getCategories,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];

            return Card(
              margin: const EdgeInsets.only(bottom: 14),
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                contentPadding: const EdgeInsets.all(10),

                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    ApiService.imageUrl(category['image']),
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) {
                      return Container(
                        width: 70,
                        height: 70,
                        color: Colors.grey.shade200,
                        child: const Icon(
                          Icons.image_not_supported,
                        ),
                      );
                    },
                  ),
                ),

                title: Text(
                  category['name'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                subtitle: Text(
                  'ID: ${category['id']}',
                ),

                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        showUpdateCategoryDialog(category);
                      },
                      icon: const Icon(
                        Icons.edit_outlined,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        deleteCategory(category);
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

      floatingActionButton: FloatingActionButton.extended(
        onPressed: showAddCategoryDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Category'),
      ),
    );
  }
}