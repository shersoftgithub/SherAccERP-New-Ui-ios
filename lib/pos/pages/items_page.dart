import 'package:flutter/material.dart';
import 'package:sheraccerp/util/res_color.dart';

class ItemsPage extends StatefulWidget {
  const ItemsPage({super.key});

  @override
  State<ItemsPage> createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  bool _showCategoryList = false;
  Map<String, int> selectedItems = {};
  String _selectedCategory = "All"; 

  final Map<String, List<String>> _categoryItems = {
    "All": [
      "Ajmi puttu podi",
      "Aatta Flour",
      "Salt & Sugar",
      "Bakery Bread",
      "Dairy Milk",
      "Coca Cola",
      "Pepsi",
      "Sunflower Oil",
      "Olive Oil"
    ],
    "Bakery & Dairy": ["Bakery Bread", "Dairy Milk"],
    "Beverages": ["Coca Cola", "Pepsi"],
    "Edible oil & Ghee": ["Sunflower Oil", "Olive Oil"],
  };

  @override
  Widget build(BuildContext context) {
    final List<String> _itemList = _categoryItems[_selectedCategory] ?? [];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios, color: white),
        ),
        title: const Text(
          'Items',
          style: TextStyle(
            fontFamily: 'poppins',
            color: white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _showCategoryList = !_showCategoryList;
              });
            },
            icon: const Icon(Icons.menu, color: white),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: white),
          ),
        ],
      ),
      body: Row(
        children: [
          if (_showCategoryList)
            Container(
              color: bagroundColor,
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width / 2.9,
              child: ListView.builder(
                itemCount: _categoryItems.keys.length,
                itemBuilder: (context, index) {
                  String category = _categoryItems.keys.elementAt(index);
                  return ListTile(
                    title: Text(category),
                    tileColor: _selectedCategory == category ? kPrimaryColor : null, 
                    textColor: _selectedCategory == category ? kPrimaryColor : null,
                    trailing: category == 'All' ? InkWell(
                      onTap: () {
                        setState(() {
                          _showCategoryList = false;
                        });
                      },
                      child: const Icon(Icons.keyboard_double_arrow_left))
                      :null,
                    onTap: () {
                      setState(() {
                        _selectedCategory = category;
                        // _showCategoryList = false; 
                      });
                    },
                  );
                },
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              child: Align(
                alignment: Alignment.center,
                child: Wrap(
                  children: _itemList.map((item) {
                    return Container(
                      padding: const EdgeInsets.all(4),
                      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      width: MediaQuery.of(context).size.width / 3.5,
                      constraints: const BoxConstraints(minHeight: 90, maxHeight: 120),
                      decoration: BoxDecoration(
                        border: Border.all(color: grey),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'poppins',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Text(
                              "\u{20B9} 200",
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                 setState(() {
      if (selectedItems.containsKey(item)) {
        selectedItems[item] = selectedItems[item]! + 1; // Increase quantity
      } else {
        selectedItems[item] = 1; // Add item with quantity 1
      }
    });
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  color: kPrimaryColor,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Add', style: TextStyle(color: white)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
