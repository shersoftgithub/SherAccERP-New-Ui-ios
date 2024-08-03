import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_settings_screen_ex/flutter_settings_screen_ex.dart';
import 'package:provider/provider.dart' as provider;
import 'package:scoped_model/scoped_model.dart';
import 'package:sheraccerp/cache_provider.dart';
import 'package:sheraccerp/firebase_options.dart';
import 'package:sheraccerp/landing.dart';
import 'package:sheraccerp/models/expense_list_item_model.dart';
import 'package:sheraccerp/provider/app_provider.dart';
import 'package:sheraccerp/provider/ledger_provider.dart';
import 'package:sheraccerp/provider/product_provider.dart';
import 'package:sheraccerp/provider/purchase_provider.dart';
import 'package:sheraccerp/provider/sales_provider.dart';
import 'package:sheraccerp/provider/stock_provider.dart';
import 'package:sheraccerp/scoped-models/main.dart';
import 'package:sheraccerp/screens/accounts/bank_voucher.dart';
import 'package:sheraccerp/screens/accounts/journal.dart';
import 'package:sheraccerp/screens/accounts/salesman_report.dart';
import 'package:sheraccerp/screens/accounts/tax_report.dart';
import 'package:sheraccerp/screens/html_previews/purchase_return_preview.dart';
import 'package:sheraccerp/screens/html_previews/sales_return_preview.dart';
import 'package:sheraccerp/screens/inventory/delivery_note.dart';
import 'package:sheraccerp/screens/inventory/invoice_design.dart';
import 'package:sheraccerp/screens/inventory/jobcard/Replacement/jobcardreplacement.dart';
import 'package:sheraccerp/screens/inventory/jobcard/jobcardentry/Job_card_home.dart';
import 'package:sheraccerp/screens/inventory/jobcard/jobcardentry/job_card_entry.dart';
import 'package:sheraccerp/screens/inventory/jobcard/jobcardentry/jobcardmenu.dart';
import 'package:sheraccerp/screens/inventory/serial_no_list.dart';
import 'package:sheraccerp/screens/other_registration.dart';
import 'package:sheraccerp/screens/settings/software_settings.dart';
import 'package:sheraccerp/screens/html_previews/invoice_models.dart';
import 'package:sheraccerp/screens/inventory/alignment_entry.dart';
import 'package:sheraccerp/screens/inventory/bill_list.dart';
import 'package:sheraccerp/screens/inventory/inv_r_p_voucher.dart';
import 'package:sheraccerp/screens/home/delivery_home.dart';
import 'package:sheraccerp/screens/home/manager_home.dart';
import 'package:sheraccerp/screens/inventory/order_item_qty_list.dart';
import 'package:sheraccerp/screens/inventory/order_list.dart';
import 'package:sheraccerp/screens/inventory/price_list.dart';
import 'package:sheraccerp/screens/inventory/product_management.dart';
import 'package:sheraccerp/screens/inventory/purchase/opening_stock.dart';
import 'package:sheraccerp/screens/inventory/purchase/purchase_order.dart';
import 'package:sheraccerp/screens/inventory/purchase/purchase_return.dart';
import 'package:sheraccerp/screens/accounts/r_p_voucher.dart';
import 'package:sheraccerp/screens/home/sales_man_home.dart';
import 'package:sheraccerp/screens/home/admin_home.dart';
import 'package:sheraccerp/screens/inventory/cart_page.dart';
import 'package:sheraccerp/screens/inventory/confirm_order.dart';
import 'package:sheraccerp/screens/inventory/damage_entry.dart';
import 'package:sheraccerp/screens/inventory/damage_report.dart';
import 'package:sheraccerp/screens/dash_report/expense_list.dart';
import 'package:sheraccerp/screens/home/home.dart';
import 'package:sheraccerp/screens/accounts/ledger.dart';
import 'package:sheraccerp/screens/accounts/ledger_select.dart';
import 'package:sheraccerp/screens/inventory/service_entry.dart';
import 'package:sheraccerp/screens/inventory/stock_management.dart';
import 'package:sheraccerp/screens/login_screen.dart';
import 'package:sheraccerp/screens/home/owner_home.dart';
import 'package:sheraccerp/screens/passcode_authentication.dart';
import 'package:sheraccerp/screens/html_previews/sales_preview.dart';
import 'package:sheraccerp/screens/inventory/product_register.dart';
import 'package:sheraccerp/screens/inventory/product_report.dart';
import 'package:sheraccerp/screens/inventory/purchase/purchase.dart';
import 'package:sheraccerp/screens/inventory/purchase/purchase_list.dart';
import 'package:sheraccerp/screens/report_view.dart';
import 'package:sheraccerp/screens/inventory/sales/sale.dart';
import 'package:sheraccerp/screens/inventory/sales/sales_list.dart';
import 'package:sheraccerp/screens/inventory/sales/sales_return.dart';
import 'package:sheraccerp/screens/inventory/sales/sales_return_list.dart';
import 'package:sheraccerp/screens/home/staff_home.dart';
import 'package:sheraccerp/screens/inventory/sales/simple_sale.dart';
import 'package:sheraccerp/screens/inventory/stock_report.dart';
import 'package:sheraccerp/screens/inventory/products_list_page.dart';
import 'package:sheraccerp/screens/inventory/stock_transfer.dart';
import 'package:sheraccerp/screens/user_login_screen.dart';
import 'package:sheraccerp/shared/constants.dart';
import 'package:sheraccerp/util/res_color.dart';
import 'package:sheraccerp/widget/add_user_screen.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

ValueNotifier<Color> accentColor = ValueNotifier(kPrimaryColor);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runZonedGuarded(() {
    initSettings().then((_) {
      runApp(ProviderScope(
        child: provider.MultiProvider(
            providers: [
              provider.ChangeNotifierProvider(
                  create: (context) => AppProvider()),
              // ChangeNotifierProvider(create: (context) => LedgerProvider()),
              // ChangeNotifierProvider(create: (context) => ProductProvider()),
              // ChangeNotifierProvider(create: (context) => StockProvider()),
              // ChangeNotifierProvider(create: (context) => SalesProvider()),
              // ChangeNotifierProvider(create: (context) => PurchaseProvider()),
            ],
            child: MyApp(
              model: MainModel(),
            )),
      ));
    });
  }, (error, stackTrace) {
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
  });
}

Future<void> initSettings() async {
  await Settings.init(
    cacheProvider: isUsingHive ? HiveCache() : SharePreferenceCache(),
  );

  isDarkTheme =
      false; //ComSettings.appSettings('int', 'key-dropdown-them-view', 2) == 2
  //? false
  //: true;
  _initializeFirebase();
}

Future<void> _initializeFirebase() async {
  if (kDebugMode) {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
  } else {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  } 
}

class MyApp extends StatelessWidget {
  final MainModel? model;
  const MyApp({Key? key, @required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScopedModel<MainModel>(
        model: model!,
        child: ValueListenableBuilder<Color>(
          valueListenable: accentColor,
          builder: (_, color, __) => MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'SherAcc',
            routes: {
              '/': (context) => const Landing(),
              '/login_company': (context) => const LoginScreen(),
              '/login': (context) => const UserLoginScreen(),
              '/register': (context) => const Register(),
              '/home': (context) => const Home(),
              '/admin_home': (context) => const AdminHome(title: 'SherAcc'),
              '/manager_home': (context) => const ManagerHome(title: 'SherAcc'),
              '/staff_home': (context) => const StaffHome(title: 'SherAcc'),
              '/expense_list': (context) =>
                  ExpenseList(ExpenseListItemModel.emptyData(), 0),
              '/sales': (context) =>
                  const Sale(oldSale: false, thisSale: false),
              '/AlignmentEntry': (context) => AlignmentEntry(),
              '/ServiceEntry': (context) => ServiceEntry(),
              '/purchase': (context) => const Purchase(
                    oldPurchase: false,
                  ),
              '/add_product': (context) => const ProductsListPage(),
              '/cart': (context) => const CartPage(),
              '/check_out': (context) => const ConfirmOrder(),
              '/ledger': (context) => const Ledger(),
              '/preview_show': (context) => const SalesPreviewShow(),
              '/return_preview_show': (context) =>
                  const SalesReturnPreviewShow(),
              '/purchase_return_preview_show': (context) =>
                  const PurchaseReturnPreviewShow(),
              '/select_ledger': (context) => const LedgerSelect(),
              '/report_view': (context) => const ReportView(
                  '0',
                  '0',
                  '2020-01-01',
                  '2020-01-01',
                  'ledger',
                  '',
                  '',
                  '0',
                  [0],
                  '0',
                  '0'),
              '/RPVoucher': (context) => const RPVoucher(),
              '/SalesList': (context) => const SalesList(),
              '/PurchaseList': (context) => const PurchaseList(),
              '/StockReport': (context) => const StockReport(),
              '/salesMan_home': (context) => const SalesManHome(),
              '/salesManReport': (context) => const SalesManReport(),
              '/delivery_home': (context) => const DeliveryHome(),
              '/product': (context) => const ProductRegister(),
              '/salesReturn': (context) =>
                  const SalesReturn(data: [], fromSale: false),
              '/damageEntry': (context) => const DamageEntry(),
              '/openingStock': (context) => const OpeningStock(),
              '/damageReport': (context) => const DamageReport(),
              '/priceList': (context) => const PriceList(),
              '/SalesReturnList': (context) => const SalesReturnList(),
              '/ProductReport': (context) => const ProductReport(),
              '/owner_home': (context) => const OwnerHome(),
              '/passCode_Auth': (context) => const PassCodeAuth(),
              '/SimpleSale': (context) => const SimpleSale(),
              '/OrderList': (context) => const OrderList(),
              '/OrderItemList': (context) => const OrderItemList(),
              '/BillList': (context) => const BillList(),
              '/purchaseReturn': (context) => const PurchaseReturn(),
              '/purchaseOrder': (context) => const PurchaseOrder(),
              '/stockTransfer': (context) => const StockTransfer(),
              '/StockManagement': (context) => const StockManagement(),
              '/InvRPVoucher': (context) => const InvRPVoucher(),
              '/InvoiceModels': (context) => const InvoiceModels(),
              '/ProductManagement': (context) => ProductManagement(),
              '/journal': (context) => const Journal(),
              '/settings': (context) => const SoftwareSettings(),
              '/InvoiceDesign': (context) => const InvoiceDesign(),
              '/OtherRegistration': (context) => const OtherRegistration(),
              '/DeliveryNote': (context) => const DeliveryNote(),
              '/jobcardmenu': (context) => const Jobcardmenu(),
              '/jobcardhome': (context) => const JobCardHome(),
              '/jobcardentry': (context) => const Jobcardentry(),
              '/jobcardreplacement': (context) => const JobCardReplacement(),
              '/TaxReport': (context) => const TaxReport(),
              '/BankVoucher': (context) => const BankVoucher(),
              '/serialNoList': (context) => const SerialNoList(),
            },
            theme: themeData(),
          ),
        ));
  }
}

ThemeData themeData() {
  // TextTheme basicTextTheme(TextTheme base) {
  //   return base.copyWith(
  //     displayLarge: base.displayLarge!.copyWith(
  //       fontSize: 20.0,
  //       fontWeight: FontWeight.bold,
  //       color: Colors.white,
  //     ),
  //     titleLarge: base.titleLarge!.copyWith(
  //       fontSize: 18.0,
  //     ),
  //     bodyMedium: base.bodyMedium!.copyWith(
  //       fontSize: 14.0,
  //       color: kPrimaryColor,
  //     ),
  //     headlineMedium: base.headlineMedium!.copyWith(
  //       fontSize: 13.0,
  //       color: black,
  //     ),
  //     headlineSmall: base.headlineMedium!.copyWith(
  //       fontSize: 12.0,
  //       color: black,
  //     ),
  //     bodySmall: base.headlineSmall!.copyWith(
  //       fontSize: 11.0,
  //     ),
  //     bodyLarge: base.bodyLarge!.copyWith(
  //       color: kPrimaryColor,
  //       fontSize: 14,
  //     ),
  //     labelSmall: base.labelSmall!.copyWith(color: black),
  //     labelMedium: base.labelMedium!.copyWith(color: black),
  //     labelLarge: base.labelLarge!.copyWith(color: black),
  //   );
  // }

  final ThemeData base = ThemeData.light();
  return base.copyWith(
    primaryColor: kPrimaryColor,
    hintColor: kPrimaryColor,
    iconTheme: const IconThemeData(
      color: kPrimaryColor,
      // size: 20.0,
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: kPrimaryColor,
      shape: RoundedRectangleBorder(),
      textTheme: ButtonTextTheme.normal,
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: kPrimaryColor,
      overlayColor: kPrimaryColor.withAlpha(32),
      thumbColor: kPrimaryColor,
    ),
    scaffoldBackgroundColor: white,
    tabBarTheme: TabBarTheme(
        indicatorColor: blue,
        unselectedLabelColor: whiteDark,
        labelColor: white,
        dividerColor: redAccent,
        overlayColor: MaterialStateColor.resolveWith((states) => blue)),
    appBarTheme: const AppBarTheme(
        backgroundColor: kPrimaryColor,
        foregroundColor: white,
        titleTextStyle: TextStyle(fontSize: 15),
        actionsIconTheme: IconThemeData(color: white)),
    // textTheme: ThemeData.dark().textTheme.copyWith(
    //       //body 1 for any Text Widget
    //       bodyMedium: const TextStyle(fontSize: 16),
    //       bodyLarge: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
    //       // table header
    //       headlineMedium: const TextStyle(
    //         fontSize: 20,
    //       ),
    //       displaySmall: const TextStyle(
    //         fontSize: 20,
    //       ),
    //       displayMedium: const TextStyle(
    //         fontSize: 24,
    //       ),
    //       displayLarge: const TextStyle(
    //         fontSize: 28,
    //       ),

    //       /// Used for the primary text in app bars and dialogs (e.g., AppBar.title
    //       ///AlertDialog.title).
    //       titleLarge: const TextStyle(
    //         fontSize: 20,
    //       ),
    //       //error label under txt
    //       bodySmall: const TextStyle(
    //         fontSize: 14,
    //       ),
    //       //for app bar
    //       headlineSmall: const TextStyle(fontSize: 20, color: Colors.white),
    //       //titles in lists
    //       titleMedium: const TextStyle(fontSize: 20),
    //       //under title
    //       titleSmall: const TextStyle(
    //         fontSize: 20,
    //       ),
    //       labelSmall: const TextStyle(
    //         fontSize: 28,
    //       ),
    //     ),
    textSelectionTheme: const TextSelectionThemeData(
      selectionColor: Color(0xffffB59B),
    ),
  );
}
