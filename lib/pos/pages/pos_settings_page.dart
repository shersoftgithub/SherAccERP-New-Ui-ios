import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sheraccerp/service/api_dio.dart';
import 'package:sheraccerp/shared/constants.dart';  
import 'package:sheraccerp/util/res_color.dart';

final rateTypeProvider = StateProvider<String>((ref) => 'RETAIL'); 

final locationProvider = StateProvider<String?>((ref) {
  // Fetch the default location ID from settings
  final defaultLocationId = ComSettings.appSettings('int', 'key-dropdown-default-location-view', 2) - 1;
  return null; // Default value will be set in initState
});

final isTaxProvider = StateProvider<bool>((ref) => true); 

final salesmanProvider = StateProvider<int>((ref) {
  return ComSettings.appSettings('int', 'key-dropdown-default-salesman-view', 1) - 1;
});

class PosSettingsPage extends ConsumerStatefulWidget {
  const PosSettingsPage({super.key});

  @override
  ConsumerState<PosSettingsPage> createState() => _PosSettingsPageState();
}

class _PosSettingsPageState extends ConsumerState<PosSettingsPage> {
  List<DataJson> locationDataList = [];
  List<DataJson> salesmanDataList = [];
  List<String> locationList = [];
  List<String> salesmanList = [];

  @override
  void initState() {
    super.initState();

    locationDataList.addAll(DataJson.fromJsonListX(otherRegistrationList[0]['location']));
    locationList = locationDataList
        .map((item) => item.name)
        .where((name) => name != null)
        .cast<String>()
        .toList();

    salesmanDataList = DataJson.fromJsonListX(otherRegistrationList[0]['salesMan']);
    salesmanList = salesmanDataList
        .map((item) => item.name)
        .where((name) => name != null)
        .cast<String>()
        .toList();

    final defaultLocationId = ComSettings.appSettings('int', 'key-dropdown-default-location-view', 2) - 1;
    if (defaultLocationId >= 0 && defaultLocationId < locationList.length) {
    Future.delayed(Duration.zero ,() {
        ref.read(locationProvider.notifier).state = locationList[defaultLocationId];
    },);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedRateType = ref.watch(rateTypeProvider);
    final selectedLocation = ref.watch(locationProvider);
    final isTax = ref.watch(isTaxProvider);
    final selectedSalesmanId = ref.watch(salesmanProvider);

    return Scaffold(
      backgroundColor: bagroundColor,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        centerTitle: true,
        title: const Text('Settings'),
        titleTextStyle: const TextStyle(
          fontFamily: 'poppins',
          color: white,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              ' Rate Type',
              style: TextStyle(fontFamily: 'poppins'),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                border: Border.all(color: grey),
                borderRadius: BorderRadius.circular(3),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  hint: const Text('Select rate type'),
                  style: const TextStyle(
                    fontFamily: 'poppins',
                    color: black,
                    fontSize: 15,
                  ),
                  items: rateTypeData.map((item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
                  onChanged: (value) {
                    ref.read(rateTypeProvider.notifier).state = value!;
                    debugPrint('Selected Rate Type: $value');
                  },
                  value: selectedRateType,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              ' Location',
              style: TextStyle(fontFamily: 'poppins'),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                border: Border.all(color: grey),
                borderRadius: BorderRadius.circular(3),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  hint: const Text('Select location'),
                  style: const TextStyle(
                    fontFamily: 'poppins',
                    color: black,
                    fontSize: 15,
                  ),
                  items: locationList.map((item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
                  onChanged: (value) {
                    ref.read(locationProvider.notifier).state = value;
                    debugPrint('Selected Location: $value');
                  },
                  value: selectedLocation,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              ' Salesman',
              style: TextStyle(fontFamily: 'poppins'),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                border: Border.all(color: grey),
                borderRadius: BorderRadius.circular(3),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  hint: const Text('Select Salesman'),
                  style: const TextStyle(
                    fontFamily: 'poppins',
                    color: black,
                    fontSize: 15,
                  ),
                  items: salesmanList.asMap().entries.map((entry) {
                    int idx = entry.key;
                    String name = entry.value;
                    return DropdownMenuItem<int>(
                      value: idx,
                      child: Text(name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    ref.read(salesmanProvider.notifier).state = value!;
                    debugPrint('Selected Salesman: $value');
                  },
                  value: selectedSalesmanId,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  'Tax',
                  style: TextStyle(
                    fontFamily: 'poppins',
                    fontSize: 15,
                  ),
                ),
                Checkbox(
                  activeColor: kPrimaryColor,
                  value: isTax,
                  onChanged: (value) {
                    ref.read(isTaxProvider.notifier).state = value!;
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}





// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:sheraccerp/shared/constants.dart';  
// import 'package:sheraccerp/util/res_color.dart';

// final rateTypeProvider = StateProvider<String>((ref) => 'RETAIL');

// class PosSettingsPage extends ConsumerStatefulWidget {
//   const PosSettingsPage({super.key});

//   @override 
//   ConsumerState<PosSettingsPage> createState() => _PosSettingsPageState();
// }

// class _PosSettingsPageState extends ConsumerState<PosSettingsPage> {
//   late SharedPreferences prefs;

//   @override
//   void initState() {
//     super.initState();
//     _loadRateType();  
//   }

//   Future<void> _loadRateType() async {
//     prefs = await SharedPreferences.getInstance();
//     final savedRateType = prefs.getString('rateType') ?? 'RETAIL';
//     ref.read(rateTypeProvider.notifier).state = savedRateType;
//   }

//   Future<void> _saveRateType(String rateType) async {
//     await prefs.setString('rateType', rateType);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final selectedRateType = ref.watch(rateTypeProvider);

//     return Scaffold(
//       backgroundColor: bagroundColor,
//       appBar: AppBar(
//         backgroundColor: kPrimaryColor,
//         centerTitle: true,
//         title: const Text('Settings'),
//         titleTextStyle: const TextStyle(
//           fontFamily: 'poppins',
//           color: white,
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         child: Column(
//           children: [
//             const Text(
//               'Rate Type',
//               style: TextStyle(fontFamily: 'poppins'),
//             ),
//             const SizedBox(height: 8),
//             Container(
//               width: MediaQuery.of(context).size.width,
//               decoration: BoxDecoration(
//                 border: Border.all(color: grey),
//                 borderRadius: BorderRadius.circular(3),
//               ),
//               child: DropdownButtonHideUnderline(
//                 child: DropdownButton<String>(
//                   hint: const Text('Select rate type'),
//                   style: const TextStyle(
//                     fontFamily: 'poppins',
//                     color: black,
//                     fontSize: 15,
//                   ),
//                   items: rateTypeData.map((item) {
//                     return DropdownMenuItem<String>(
//                       value: item,
//                       child: Text(item),
//                     );
//                   }).toList(),
//                   onChanged: (value) {
//                     if (value != null) {
//                       ref.read(rateTypeProvider.notifier).state = value;
//                       _saveRateType(value); 
//                     }
//                   },
//                   value: selectedRateType, 
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

