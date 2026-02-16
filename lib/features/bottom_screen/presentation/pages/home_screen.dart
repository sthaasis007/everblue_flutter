import 'package:everblue/core/api/api_endpoint.dart';
import 'package:everblue/features/items/presentation/state/item_state.dart';
import 'package:everblue/features/items/presentation/view_model/item_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
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

  @override
  Widget build(BuildContext context) {
    final itemState = ref.watch(itemViewModelProvider);
    final items = itemState.items;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
          children: [
            SizedBox(
              height: 150,
              child: Image.asset('assets/images/dashpic.png')),
            Align(
              alignment: Alignment.topLeft,
              child: Text("Top Seller",
              style: TextStyle(
                fontSize: 25,
                fontFamily: 'OpenSans Regular',
              ),),
            ),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemCount: 10,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey, width: 2)
                      ),
                    ),
                  );
                }),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Text("Browse more",
              style: TextStyle(
                fontSize: 25,
                fontFamily: 'OpenSans Regular',
              ),),
            ),     
            SizedBox(
              child: itemState.status == ItemStatus.fetching && items.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : items.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('No items available yet.'),
                        )
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(10),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            final imageUrl = _buildItemImageUrl(item.photoUrl);
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(12),
                                      ),
                                      child: imageUrl == null
                                          ? Container(
                                              color: Colors.red.shade100,
                                              child: const Center(
                                                child: Icon(
                                                  Icons.image_outlined,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            )
                                          : Image.network(
                                              imageUrl,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stack) {
                                                return Container(
                                                  color: Colors.red.shade100,
                                                  child: const Center(
                                                    child: Icon(
                                                      Icons.broken_image_outlined,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Price: ${item.price.toStringAsFixed(2)}',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      )
    );
  }
}