import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sheraccerp/models/product_register_model.dart';
import 'package:sheraccerp/models/stock_item.dart';
import 'package:sheraccerp/models/stock_product.dart';
import 'package:sheraccerp/pos/controllers/cart_item_provider.dart';
import 'package:sheraccerp/pos/models/pos_cart_model.dart';
import 'package:sheraccerp/pos/pages/home_page.dart';
import 'package:sheraccerp/pos/pages/pos_settings_page.dart';
import 'package:sheraccerp/service/api_dio.dart';
import 'package:sheraccerp/shared/constants.dart';
import 'package:sheraccerp/util/dateUtil.dart';
import 'package:sheraccerp/util/res_color.dart';

class ItemsPage extends StatefulHookConsumerWidget {
  const ItemsPage({super.key});

  @override
  ConsumerState<ItemsPage> createState() => _ItemsPageState();
}

class _ItemsPageState extends ConsumerState<ItemsPage> {
  final TextEditingController searchController = TextEditingController();
  List<DataJson> categoryDataList = [];
  List<String> categoryList = [];
  List<PosCartModel> cartItem = [];
  bool _showCategoryList = false;
  Map<String, int> selectedItems = {};
  List<StockItem>? products;
  List<StockItem>? filteredProducts;
  List<StockProduct>? fetchStockVariant;
  DioService api = DioService();
  String _selectedCategory = "All";
  String _toDay = '';
  String get getToDay => _toDay!;
  DateTime now = DateTime.now();
  String? formattedDate;
  bool _isLoading = true;

  final Map<String, List<StockItem>> _categoryItems = {
    "All": [],
  };

  @override
  void initState() {
    super.initState();
    formattedDate =
        getToDay.isNotEmpty ? getToDay : DateFormat('dd-MM-yyyy').format(now);
    _fetchProducts();
    categoryDataList
        .addAll(DataJson.fromJsonListX(otherRegistrationList[0]['category']));

    categoryList.addAll(categoryDataList
        .map((item) => item.name)
        .where((name) => name != null)
        .cast<String>()
        .toList());

    for (String category in categoryList) {
      _categoryItems[category] = [];
    }
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
    });

    products = await api.fetchStockProduct(DateUtil.dateDMY2YMD(formattedDate));
    filteredProducts = products;
    fetchStockVariant = [];
    for (var product in products!) {
      var variants = await api.fetchStockVariant(product.id!);
      if (variants != null) {
        fetchStockVariant!.addAll(variants);
      }
    }

    _categorizeProducts();
    setState(() {
      _isLoading = false;
    });
  }

  void _categorizeProducts() {
    _categoryItems["All"] = products ?? [];
  }

  void filterProducts(String query) {
    if (query.isEmpty) {
      filteredProducts = _categoryItems[_selectedCategory];
    } else {
      filteredProducts = _categoryItems[_selectedCategory]
          !.where((product) =>
              product.name?.toLowerCase().contains(query.toLowerCase()) ??
              false)
          .toList();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // debugPrint(cartItem.length.toString());
    final isExpanded = useState<bool>(false);
    final selectedRateType = ref.watch(rateTypeProvider);
    final List<StockItem> _itemList = filteredProducts ?? [];
    List<StockProduct> _variantList = fetchStockVariant ?? [];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        centerTitle: true,
        title: const Text(
          'Items',
          style: TextStyle(
            fontFamily: 'poppins',
            color: white,
          ),
        ),
        bottom: isExpanded.value
            ? PreferredSize(
                preferredSize: const Size.fromHeight(40),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: TextField(
                    style: const TextStyle(color: white),
                    controller: searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search..',
                      hintStyle: TextStyle(color: white, fontFamily: 'poppins'),
                      constraints: BoxConstraints(maxHeight: 45),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      filterProducts(value);
                    },
                  ),
                ),
              )
            : null,
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
            onPressed: () {
              isExpanded.value = !isExpanded.value;
            },
            icon: const Icon(Icons.search, color: white),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Row(
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
                          tileColor: _selectedCategory == category
                              ? kPrimaryColor
                              : null,
                          textColor: _selectedCategory == category
                              ? kPrimaryColor
                              : null,
                          trailing: category == 'All'
                              ? InkWell(
                                  onTap: () {
                                    setState(() {
                                      _showCategoryList = false;
                                    });
                                  },
                                  child: const Icon(
                                      Icons.keyboard_double_arrow_left))
                              : null,
                          onTap: () {
                            setState(() {
                              _selectedCategory = category;
                              filterProducts(searchController.text);
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
                          // Find the variant for the current item
                          StockProduct? variant = _variantList.firstWhere(
                              (variant) => variant.itemId == item.id,
                              orElse: () => StockProduct());

                              double? rate = selectedRateType == 'MRP' ? variant.sellingPrice 
                                                     : selectedRateType == 'WHOLESALE' ? variant.wholeSalePrice 
                                                       : selectedRateType == 'RETAIL' ? variant.retailPrice 
                                                         : selectedRateType == 'SPRETAIL' ? variant.spRetailPrice
                                                           : variant.retailPrice ;

                          return Container(
                            padding: const EdgeInsets.all(4),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 4),
                            width: MediaQuery.of(context).size.width / 3.5,
                            constraints: const BoxConstraints(
                                minHeight: 90, maxHeight: 120),
                            decoration: BoxDecoration(
                              border: Border.all(color: grey),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: IntrinsicHeight(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item.name ?? '',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontFamily: 'poppins',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    "\u{20B9} ${rate ?? 0}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        ref
                                            .read(cartItemProvider.notifier)
                                            .addItem(PosCartModel(
                                                id: item.id.toString(),
                                                name: item.name!,
                                                quantity: 1,
                                                rate: variant.sellingPrice ?? 0));
                                      });
                                      Navigator.of(context)
                                          .pushReplacement(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      PosHomePage(
                                                          selectedItems:
                                                              selectedItems)));
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      decoration: BoxDecoration(
                                        color: kPrimaryColor,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text('Add',
                                              style: TextStyle(color: white)),
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
