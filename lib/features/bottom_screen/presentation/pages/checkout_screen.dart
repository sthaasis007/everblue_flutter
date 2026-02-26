import 'package:everblue/core/api/api_endpoint.dart';
import 'package:everblue/features/cart/presentation/providers/cart_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(checkoutItemsProvider);
    
    // Calculate total price
    final totalPrice = items.fold(0.0, (sum, item) => sum + item.price);

    return Scaffold(
      body: items.isEmpty
          ? const Center(child: Text('No items in checkout.'))
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
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
                              ref
                                  .read(checkoutItemsProvider.notifier)
                                  .removeItem(item);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Total Price Section
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Amount:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Rs. ${totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: items.isEmpty ? null : () {
                            // Add your checkout logic here
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Proceed to Checkout',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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