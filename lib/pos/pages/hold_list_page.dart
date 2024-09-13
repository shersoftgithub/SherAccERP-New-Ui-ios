import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sheraccerp/pos/controllers/cart_item_provider.dart';
import 'package:sheraccerp/pos/controllers/hold_item_provider.dart';
import 'package:sheraccerp/util/res_color.dart';

class HoldList extends ConsumerWidget {
  const HoldList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final holdModel = ref.watch(holdItemProvider); 
    debugPrint(holdModel.toString());

    return Scaffold(
      backgroundColor: bagroundColor,
      appBar: AppBar(
        title: const Text('Hold List'),
        centerTitle: true,
        titleTextStyle: const TextStyle(fontFamily: 'poppins'),
        backgroundColor: kPrimaryColor,
      ),
      body: holdModel.isEmpty
          ? const Center(child: Text('No items in the hold list'))
          : Column(
            children: [
              const SizedBox(
                height: 8,
              ),
              ListView.separated(
                separatorBuilder: (context, index) => const SizedBox(
                  height: 6,
                ),
                shrinkWrap: true,
                  itemCount: holdModel.length,
                  itemBuilder: (context, index) {
                    final holdList = holdModel[index];
              
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: grey, width: .5),
                                                borderRadius:
                                                    BorderRadius.circular(3),
                                                color:
                                                    Colors.grey.withOpacity(.1)),
                        child: ExpansionTile(
                          title: Text('Hold List ${index+ 1}',
                           style: const TextStyle(
                                fontFamily: 'poppins'
                              ),
                          ),
                          subtitle: Text('Items: ${holdList.items.length}',
                           style: const TextStyle(
                                fontFamily: 'poppins'
                              ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.restore,
                            color: black,
                            ),
                            onPressed: () {
                              final restoredItems = ref
                                  .read(holdItemProvider.notifier)
                                  .restoreHoldList(holdList.id);
                        
                              for (var item in restoredItems) {
                                ref.read(cartItemProvider.notifier).addItem(item);
                              }
                              Navigator.pop(context);
                              ref.read(holdItemProvider.notifier).removeHoldList(holdList.id);
                        
                              // ScaffoldMessenger.of(context).showSnackBar(
                              //   SnackBar(content: Text('Restored Hold List ${holdList.id} to cart')),
                              // );
                            },
                          ),
                          children: holdList.items.map((item) {
                            return ListTile(
                              title: Text(item.itemName!,
                              style: const TextStyle(
                                fontFamily: 'poppins'
                              ),
                              ),
                              subtitle: Text('Quantity: ${item.quantity}',
                               style: const TextStyle(
                                fontFamily: 'poppins'
                              ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
    );
  }
}
