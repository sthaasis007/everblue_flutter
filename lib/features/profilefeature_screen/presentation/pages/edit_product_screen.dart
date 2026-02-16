import 'dart:io';

import 'package:everblue/core/api/api_endpoint.dart';
import 'package:everblue/features/items/domain/entities/item_entity.dart';
import 'package:everblue/features/items/presentation/state/item_state.dart';
import 'package:everblue/features/items/presentation/view_model/item_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class EditProductScreen extends ConsumerStatefulWidget {
  const EditProductScreen({super.key});

  @override
  ConsumerState<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends ConsumerState<EditProductScreen> {
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(itemViewModelProvider.notifier).getItems();
    });
  }

  String? _buildItemImageUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http')) return path;
    if (path.startsWith('/public')) {
      return '${ApiEndpoints.serverUrl}${path.replaceFirst('/public', '')}';
    }
    if (path.startsWith('/')) return '${ApiEndpoints.serverUrl}$path';
    // Handle bare filenames (e.g., "item-pic-1771263769483.jpg")
    return '${ApiEndpoints.serverUrl}/public/item_photo/$path';
  }

  Future<void> _showEditSheet(ItemEntity item) async {
    final nameController = TextEditingController(text: item.name);
    final descriptionController = TextEditingController(text: item.description);
    final priceController = TextEditingController(text: item.price.toString());
    final statusController = TextEditingController(text: item.status);
    String typeValue = item.type.isNotEmpty ? item.type : 'Men';
    File? selectedImage;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> pickImage() async {
              final XFile? image = await _imagePicker.pickImage(
                source: ImageSource.gallery,
                imageQuality: 80,
              );
              if (image == null) return;
              setModalState(() {
                selectedImage = File(image.path);
              });
            }

            final imageUrl = _buildItemImageUrl(item.photoUrl);
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      'Edit Product',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 160,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(
                                selectedImage!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : (imageUrl == null)
                              ? const Center(child: Icon(Icons.image_outlined))
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: OutlinedButton.icon(
                        onPressed: pickImage,
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Edit Image'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: typeValue,
                      decoration: const InputDecoration(
                        labelText: 'Type',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Men', child: Text('Men')),
                        DropdownMenuItem(value: 'Women', child: Text('Women')),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setModalState(() {
                          typeValue = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: statusController,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        final name = nameController.text.trim();
                        final description = descriptionController.text.trim();
                        final status = statusController.text.trim();
                        final price =
                            double.tryParse(priceController.text.trim()) ?? 0;

                        if (name.isEmpty || description.isEmpty || status.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please fill all fields.')),
                          );
                          return;
                        }

                        String? photoUrl = item.photoUrl;
                        if (selectedImage != null) {
                          final uploadedUrl = await ref
                              .read(itemViewModelProvider.notifier)
                              .uploadItemPhoto(selectedImage!);
                          if (uploadedUrl == null) {
                            final errorMessage =
                                ref.read(itemViewModelProvider).errorMessage;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  errorMessage ?? 'Image upload failed.',
                                ),
                              ),
                            );
                            return;
                          }
                          photoUrl = uploadedUrl;
                        }

                        if (item.id == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Missing item id.')),
                          );
                          return;
                        }

                        final updated = await ref
                            .read(itemViewModelProvider.notifier)
                            .updateItem(
                              id: item.id!,
                              name: name,
                              description: description,
                              type: typeValue,
                              price: price,
                              status: status,
                              photoUrl: photoUrl,
                            );

                        if (updated == null) {
                          final errorMessage =
                              ref.read(itemViewModelProvider).errorMessage;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                errorMessage ?? 'Unable to update product.',
                              ),
                            ),
                          );
                          return;
                        }

                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Product updated.')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Save Changes'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    statusController.dispose();
  }

  Future<void> _confirmDelete(ItemEntity item) async {
    final id = item.id;
    if (id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Delete ${item.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final deleted = await ref.read(itemViewModelProvider.notifier).deleteItem(id);
    if (!deleted) {
      final errorMessage = ref.read(itemViewModelProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage ?? 'Delete failed.')),
      );
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product deleted.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemState = ref.watch(itemViewModelProvider);
    final items = itemState.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            onPressed: () {
              ref.read(itemViewModelProvider.notifier).getItems();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: itemState.status == ItemStatus.fetching && items.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
              ? const Center(child: Text('No items available.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final imageUrl = _buildItemImageUrl(item.photoUrl);
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: imageUrl == null
                              ? Container(
                                  width: 56,
                                  height: 56,
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.image_outlined),
                                )
                              : Image.network(
                                  imageUrl,
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        title: Text(
                          item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Price: ${item.price.toStringAsFixed(2)}\nStatus: ${item.status}',
                          ),
                        ),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: item.id == null
                                  ? null
                                  : () => _showEditSheet(item),
                              icon: const Icon(Icons.edit_outlined),
                            ),
                            IconButton(
                              onPressed: item.id == null
                                  ? null
                                  : () => _confirmDelete(item),
                              icon: const Icon(Icons.delete_outline),
                              color: Colors.red,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemCount: items.length,
                ),
    );
  }
}
