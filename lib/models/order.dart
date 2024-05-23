import 'package:sheraccerp/models/cart_item.dart';
import 'package:sheraccerp/models/customer_model.dart';

class Order {
  final String otherDiscount;
  final String otherCharges;
  final String cashReceived;
  final List<CartItem> lineItems;
  final List<CustomerModel> customerModel;
  final String loadingCharge;
  final String narration;
  final String balanceAmount;
  final String labourCharge;
  final String creditPeriod;
  final String takeUser; //1
  final String cashAC;
  final String dated;
  final String location; //1
  final String salesMan; //0
  final String roundOff; //0
  final String billType; //0
  final String sType; //0
  final String grossValue; //0
  final String discount; //0
  final String discountPer; //0
  final String rDiscount; //0
  final String net; //0
  final String cess; //0
  final String cGST; //0
  final String sGST; //0
  final String iGST; //0
  final String fCess; //0
  final String adCess; //0
  final String total; //0
  final String profit; //0
  final List<dynamic> otherAmountData;
  final String grandTotal;

  Order(
      {required this.customerModel,
      required this.lineItems,
      required this.grossValue,
      required this.discount,
      required this.discountPer,
      required this.rDiscount,
      required this.net,
      required this.cess,
      required this.cGST,
      required this.sGST,
      required this.iGST,
      required this.fCess,
      required this.adCess,
      required this.total,
      required this.profit,
      required this.otherDiscount,
      required this.loadingCharge,
      required this.otherCharges,
      required this.cashReceived,
      required this.narration,
      required this.balanceAmount,
      required this.labourCharge,
      required this.creditPeriod,
      required this.takeUser,
      required this.cashAC,
      required this.dated,
      required this.location,
      required this.salesMan,
      required this.roundOff,
      required this.billType,
      required this.sType,
      required this.otherAmountData,
      required this.grandTotal});

  // Order.fromData(CustomerModel customerModel,CartItem){
  //   return()
  // }
}
