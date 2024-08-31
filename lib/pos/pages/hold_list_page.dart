import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sheraccerp/pos/controllers/hold_item_provider.dart';
import 'package:sheraccerp/util/res_color.dart';
import 'package:sheraccerp/pos/controllers/cart_item_provider.dart';

class HoldList extends ConsumerWidget {
  const HoldList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final holdModel = ref.watch(holdItemProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
        title: const Text('Hold List'),
        backgroundColor: kPrimaryColor,
      ),
      body: holdModel.isEmpty
          ? const Center(child: Text('No items in the hold list'))
          : ListView.builder(
              itemCount: holdModel.length,
              itemBuilder: (context, index) {
                final holdList = holdModel[index];
                return ListTile(
                  title: Text('Hold List ${holdList.id}'),
                  subtitle: Text('Items: ${holdList.items.length}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.restore),
                    onPressed: () {
                      // Restore items to the cart
                      final restoredItems = ref
                          .read(holdItemProvider.notifier)
                          .restoreHoldList(holdList.id);
                      for (var item in restoredItems) {
                        ref.read(cartItemProvider.notifier).addItem(item);
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Restored Hold List ${holdList.id} to cart')),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
