import 'package:everblue/core/api/api_endpoint.dart';
import 'package:everblue/features/cart/presentation/providers/cart_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key, this.onGoToCheckout});

  final VoidCallback? onGoToCheckout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(cartItemsProvider);
    return Scaffold(
      body: items.isEmpty
          ? const Center(child: Text('Your cart is empty.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = items[index];
                final imageUrl = _buildItemImageUrl(item.photoUrl);
                return Card(
                  elevation: 1,
                  child: ListTile(
                    leading: _buildItemImage(imageUrl),
                    title: Text(item.name),
                    subtitle: Text('Rs. ${item.price.toStringAsFixed(2)}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        ref.read(cartItemsProvider.notifier).removeItem(item);
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: items.isEmpty
          ? null
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final checkoutNotifier = ref.read(
                      checkoutItemsProvider.notifier,
                    );
                    checkoutNotifier.clear();
                    for (final item in items) {
                      checkoutNotifier.addItem(item);
                    }

                    onGoToCheckout?.call();
                  },
                  icon: const Icon(Icons.payment),
                  label: const Text('Go to Checkout'),
                ),
              ),
            ),
    );
  }

  String? _buildItemImageUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http')) return path;
    if (path.startsWith('/public')) {
      return '${ApiEndpoints.serverUrl}${path.replaceFirst('/public', '')}';
    }
    if (path.startsWith('/')) return '${ApiEndpoints.serverUrl}$path';
    return '${ApiEndpoints.serverUrl}/public/item_photo/$path';
  }

  Widget _buildItemImage(String? imageUrl) {
    if (imageUrl == null) {
      return Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.image_outlined, color: Colors.white),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        imageUrl,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) {
          return Container(
            width: 56,
            height: 56,
            color: Colors.red.shade100,
            child: const Icon(Icons.broken_image_outlined, color: Colors.white),
          );
        },
      ),
    );
  }
}
