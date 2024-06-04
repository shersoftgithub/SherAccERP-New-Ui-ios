import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:sheraccerp/models/company.dart';

import 'package:sheraccerp/models/ledger_name_model.dart';
import 'package:sheraccerp/models/ledger_parent.dart';
import 'package:sheraccerp/models/other_registrations.dart';
import 'package:sheraccerp/scoped-models/main.dart';
import 'package:sheraccerp/service/api_dio.dart';
import 'package:sheraccerp/shared/constants.dart';
import 'package:sheraccerp/util/dateUtil.dart';
import 'package:sheraccerp/util/res_color.dart';
import 'package:sheraccerp/widget/container_textfield_widget.dart';
import 'package:sheraccerp/widget/progress_hud.dart';

class Ledger extends StatefulWidget {
  const Ledger({Key? key}) : super(key: key);

  @override
  State<Ledger> createState() => _LedgerState();
}

class _LedgerState extends State<Ledger> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _nameCtr = TextEditingController();
  final _add1Ctr = TextEditingController();
  final _add2Ctr = TextEditingController();
  final _add3Ctr = TextEditingController();
  final _add4Ctr = TextEditingController();
  final _cityCtr = TextEditingController();
  final _phoneNumberCtr = TextEditingController();
  final _emailCtr = TextEditingController();
  final _taxNoCtr = TextEditingController();
  final _routeCtr = TextEditingController();
  final _debitAmountCtr = TextEditingController();
  final _creditAmountCtr = TextEditingController();
  final _panCtr = TextEditingController();
  final _pinCtr = TextEditingController();
  final _secondNameCtr = TextEditingController();
  final _creditAmtCtr = TextEditingController();
  final _creditDaysCtr = TextEditingController();
  final _personCtr = TextEditingController();

  GlobalKey<AutoCompleteTextFieldState<String>> keyLedgerName = GlobalKey();
  GlobalKey<AutoCompleteTextFieldState<String>> keyCity = GlobalKey();
  GlobalKey<AutoCompleteTextFieldState<String>> keyRoute = GlobalKey();

  DioService api = DioService();
  bool _isLoading = false,
      valueActive = true,
      isUnderSelected = false,
      valueCostCenter = false,
      valueFranchisee = false,
      valueBillWise = false,
      isExist = false,
      buttonEvent = false;
  String ledgerId = '';
  List<LedgerModel> ledgerList = [];
  List<String> ledgerListDisplay = [];
  List<dynamic> ledgerGroupList = [];
  List<dynamic> salesManList = otherRegSalesManList;
  List<String> cityList = [];
  List<String> routeList = [];
  String obDate = '', lName = '';
  DateTime now = DateTime.now();
  int locationId = 1, salesManId = 0;
  String _dropDownState = 'KERALA';
  String _stateCode = '32';
  GSTStateModel? gstStateM;
  dynamic cityData, routeData;
  List<CompanySettings> settings = [];

  @override
  void initState() {
    super.initState();
    settings = ScopedModel.of<MainModel>(context).getSettings();
    // salesManId = ComSettings.appSettings(
    //         'int', 'key-dropdown-default-salesman-view', 1) -
    //     1;
    locationId = ComSettings.appSettings(
            'int', 'key-dropdown-default-location-view', 2) -
        1;
    // var isIn = salesManList.isEmpty
    //     ? null
    //     : salesManList.firstWhere((element) => element['Auto'] == 0,
    //         orElse: () => null);
    // if (isIn == null) {
    //   salesManList.add({'Auto': 0, 'Name': ''});
    // }
    String stateValue =
        ComSettings.getValue('COMP-STATE', settings) ?? _dropDownState;
    String stateCodeValue =
        ComSettings.getValue('COMP-STATECODE', settings) ?? _stateCode;

    obDate = DateUtil.datePickerDMY(now);
    api.getLedgerAll().then(
      (value) {
        setState(() {
          ledgerList.addAll(value);
          ledgerListDisplay.addAll(List<String>.from(ledgerList
              .map((item) => (item.name))
              .toList()
              .map((s) => s)
              .toList()));
        });
      },
    );
    api.getLedgerParent().then((value) {
      setState(() {
        ledgerGroupList.addAll(value);
        ledgerGroupList.add(LedgerParent(id: 0, name: ''));
      });
    });
    var gstState = stateCodeValue.isNotEmpty
        ? gstStateModels.lastWhere((element) => element.code == stateCodeValue)
        : gstStateModels.lastWhere((element) => element.code == '32');
    gstStateM = gstStateM ?? gstState;
    _dropDownState = gstStateM!.state!;
    _stateCode = gstStateM!.code!;
    cityList.addAll(otherRegAreaList.map((e) => e.name).toList());
    routeList.addAll(otherRegRouteList.map((e) => e.name).toList());
  }

  String? _result;

  @override
  Widget build(BuildContext context) {
    final routes = (ModalRoute.of(context)!.settings.arguments) != null
        ? (ModalRoute.of(context)!.settings.arguments) as Map<String, String>
        : {'parent': ''};
    if (!isUnderSelected) {
      if (routes.isNotEmpty) {
        var parentName =
            routes['parent']!.isNotEmpty ? routes['parent'].toString() : '';
        _dropDownValue = parentName.isNotEmpty
            ? ledgerGroupList
                .firstWhere((element) => element.name == parentName,
                    orElse: () => LedgerModel(id: 0, name: ''))
                .id
            : _dropDownValue;
      }
      int groupId = 0;
      groupId =
          ComSettings.appSettings('int', 'key-dropdown-default-group-view', 0) -
              1;
      if (groupId > 1) {
        _dropDownValue = groupId;
      }
    }
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings, color: white),
            onSelected: (value) {
              // Handle menu item selection
              setState(() {
                // Perform actions based on the selected value
                if (value == 'ReName Ledger') {
                  if (lName.isNotEmpty) {
                    _reNameLedgerDialog(context);
                  }
                }
              });
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'ReName Ledger',
                child: Text('ReName Ledger'),
              ),
            ],
          ),
        ],
        title: const Text(
          "Ledger",
          style: TextStyle(fontFamily: 'poppins'),
        ),
      ),
      body: ProgressHUD(
        inAsyncCall: _isLoading,
        opacity: 0.0,
        // child: detailWidget(),
        child: tabBarWidget(),
      ),
    );
  }

  void _deleteLedger(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });
    bool result = await api.spLedgerDelete(ledgerId);
    if (result) {
      setState(() {
        _isLoading = false;
        showInSnackBar('Deleted : Ledger removed.');
      });
    } else {
      showInSnackBar('error : Cannot delete this Ledger.');
    }
  }

  void _handleSubmitted(String action) async {
    setState(() {
      _isLoading = true;
    });

    var name = _nameCtr.text,
        add1 = _add1Ctr.text,
        add2 = _add2Ctr.text,
        add3 = _add3Ctr.text,
        add4 = _add4Ctr.text,
        city = cityData != null ? cityData.id : 0,
        route = routeData != null ? routeData.id : 0,
        state = _dropDownState,
        stateCode = _stateCode,
        mobile = _phoneNumberCtr.text,
        email = _emailCtr.text,
        taxNo = _taxNoCtr.text;
    double? crAmount = _creditAmountCtr.text.isNotEmpty
            ? double.tryParse(_creditAmountCtr.text)
            : 0,
        drAmount = _debitAmountCtr.text.isNotEmpty
            ? double.tryParse(_debitAmountCtr.text)
            : 0;
    var data = [
      {
        'name': name.toUpperCase(),
        'parent': _dropDownValue,
        'add1': add1,
        'add2': add2,
        'add3': add3,
        'add4': add4,
        'city': city,
        'route': route,
        'state': state.toUpperCase(),
        'stateCode': stateCode,
        'mobile': mobile,
        'salesMan': salesManId > 0 ? salesManId.toString() : '0',
        'email': email,
        'taxNo': taxNo,
        'active': valueActive ? 1 : 0,
        'obDate': DateUtil.dateDMY2YMD(obDate),
        'credit': crAmount,
        'debit': drAmount,
        'location': locationId > 0 ? locationId.toString() : '1',
        'id': ledgerId.isNotEmpty ? ledgerId : 0,
        'pan': _panCtr.text,
        'cDays':
            _creditDaysCtr.text.isNotEmpty ? int.parse(_creditDaysCtr.text) : 0,
        'cAmount': _creditAmtCtr.text.isNotEmpty
            ? double.parse(_creditAmtCtr.text)
            : 0,
        'cPerson': _personCtr.text,
        'costCenter': valueCostCenter ? 1 : 0,
        'franchisee': valueFranchisee ? 1 : 0,
        'billWise': valueBillWise ? 1 : 0,
        'pin': _pinCtr.text,
        'secondName': _secondNameCtr.text,
        'bpr': 0,
      }
    ];

    bool result = action == 'edit'
        ? await api.spLedgerEdit(data)
        : await api.spLedgerAdd(data);

    if (result) {
      _saveAndRedirectToHome(action);
    } else {
      showInSnackBar(action == 'edit'
          ? 'error : Cannot edit this Ledger.'
          : 'error : Cannot save this Ledger.');
    }
  }

  void _saveAndRedirectToHome(action) async {
    setState(() {
      _isLoading = false;
      showInSnackBar(action == 'edit'
          ? 'Updated : Ledger edited.'
          : 'Saved : Ledger created.');
    });
  }

  void showInSnackBar(String value) {
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  int _dropDownValue = 0;

  findLedger(id) {
    setState(() {
      _isLoading = true;
    });
    api.findLedger(id).then((value) {
      var data = value[0][0];
      List dataTransaction = value[1];
      setState(() {
        _nameCtr.text = data['LedName'] ?? '';
        _add1Ctr.text = data['add1'] ?? '';
        _add2Ctr.text = data['add2'] ?? '';
        _add3Ctr.text = data['add3'] ?? '';
        _add4Ctr.text = data['add4'] ?? '';
        if (data['city'] > 0) {
          cityData = otherRegAreaList
              .firstWhere((element) => element.id == data['city']);
          _cityCtr.text = cityData.name;
        }
        if (data['route'] > 0) {
          routeData = otherRegRouteList
              .firstWhere((element) => element.id == data['route']);
          _routeCtr.text = routeData.name;
        }
        if (data['lh_id'] > 0) {
          _dropDownValue = data['lh_id'];
        }
        _phoneNumberCtr.text = data['Mobile'];
        _panCtr.text = data['pan'];
        _emailCtr.text = data['Email'];
        _dropDownState = data['state'].toString();
        _stateCode = data['stateCode'].toString();
        _taxNoCtr.text = data['gstno'].toString();
        _creditDaysCtr.text = data['CDays'].toString();
        _creditAmtCtr.text = data['CAmount'].toString();
        valueActive = data['Active'] == 1 ? true : false;
        salesManId = data['SalesMan'] ?? 0;
        var _bpr = data['bpr'].toString();
        var _rent = data['Rent'].toString();
        locationId = data['Location'] ?? 0;
        var orderDate = data['OrderDate'];
        var deliveryData = data['DeliveryData'];
        _personCtr.text = data['CPerson'];
        valueCostCenter = data['CostCenter'] == 1 ? true : false;
        valueFranchisee = data['Franchisee'] == 1 ? true : false;
        var salesRate = data['SalesRate'];
        var subGroup = data['SubGroup'] == 1 ? true : false;
        _pinCtr.text = data['PinNo'];
        var TCS_Status = data['TCS_Status'];
        var TCSLimit = data['TCSLimit'];
        _secondNameCtr.text = data['SecondName'];

        if (dataTransaction.isNotEmpty) {
          var d = dataTransaction[0];
          obDate = DateUtil.dateDMY(d['atDate'].toString());
          double? dr = d['atDebitAmount'] != null
              ? double.tryParse(d['atDebitAmount'].toString())
              : 0;
          double? cr = d['atCreditAmount'] != null
              ? double.tryParse(d['atCreditAmount'].toString())
              : 0;
          if (dr! > 0) {
            _debitAmountCtr.text = dr.toStringAsFixed(2);
          }
          if (cr! > 0) {
            _creditAmountCtr.text = cr.toStringAsFixed(2);
          }
        }
      });
      setState(() {
        _isLoading = false;
      });
    });
  }

  Future _selectDate() async {
    DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100));
    if (picked != null) {
      setState(() => {obDate = DateUtil.datePickerDMY(picked)});
    }
  }

  tabBarWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          Expanded(
            flex: 0,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5))),
                    child: Text(
                      isExist ? 'Edit' : 'Save',
                      style:
                          const TextStyle(fontFamily: 'poppins', color: white),
                    ),
                    onPressed: () {
                      if (buttonEvent) {
                        return;
                      } else {
                        if (isExist) {
                          if (companyUserData!.updateData) {
                            if (ledgerId.isNotEmpty) {
                              setState(() {
                                _isLoading = true;
                                buttonEvent = true;
                              });
                              _handleSubmitted('edit');
                            } else {
                              showInSnackBar('Please select ledger');
                              setState(() {
                                buttonEvent = false;
                              });
                            }
                          } else {
                            showInSnackBar('Permission denied\ncan`t edit');
                            setState(() {
                              buttonEvent = false;
                            });
                          }
                        } else {
                          if (companyUserData!.insertData) {
                            if (ledgerId.isEmpty) {
                              setState(() {
                                _isLoading = true;
                                buttonEvent = true;
                              });
                              _handleSubmitted('save');
                            } else {
                              showInSnackBar('Please add ledger');
                              setState(() {
                                buttonEvent = false;
                              });
                            }
                          } else {
                            showInSnackBar('Permission denied\ncan`t save');
                            setState(() {
                              buttonEvent = false;
                            });
                          }
                        }
                      }
                    },
                  ),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5))),
                      onPressed: () => clear(),
                      child: const Text(
                        'Clear',
                        style: TextStyle(fontFamily: 'poppins', color: white),
                      )),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5))),
                    onPressed: isExist
                        ? () {
                            if (buttonEvent) {
                              return;
                            } else {
                              if (companyUserData!.deleteData) {
                                if (ledgerId.isNotEmpty) {
                                  setState(() {
                                    _isLoading = true;
                                    buttonEvent = true;
                                  });
                                  _deleteLedger(context);
                                } else {
                                  showInSnackBar('Please select ledger');
                                  setState(() {
                                    buttonEvent = false;
                                  });
                                }
                              } else {
                                showInSnackBar(
                                    'Permission denied\ncan`t delete');
                                setState(() {
                                  buttonEvent = false;
                                });
                              }
                            }
                          }
                        : null,
                    child: const Text(
                      'Delete',
                      style: TextStyle(fontFamily: 'poppins', color: white),
                    ),
                  ),
                  // PopupMenuButton<String>(
                  //   icon: const Icon(Icons.settings, color: blue),
                  //   onSelected: (value) {
                  //     // Handle menu item selection
                  //     setState(() {
                  //       // Perform actions based on the selected value
                  //       if (value == 'ReName Ledger') {
                  //         if (lName.isNotEmpty) {
                  //           _reNameLedgerDialog(context);
                  //         }
                  //       }
                  //     });
                  //   },
                  //   itemBuilder: (BuildContext context) => [
                  //     const PopupMenuItem<String>(
                  //       value: 'ReName Ledger',
                  //       child: Text('ReName Ledger'),
                  //     ),
                  //   ],
                  // ),
                ]),
          ),
          const SizedBox(
            height: 16,
          ),
          Expanded(
            flex: 1,
            child: DefaultTabController(
              length: 3,
              child: Scaffold(
                appBar: PreferredSize(
                  preferredSize: const Size.fromHeight(45),
                  child: AppBar(
                    excludeHeaderSemantics: false,
                    backgroundColor: kPrimaryColor,
                    automaticallyImplyLeading: false,
                    titleSpacing: -15,
                    shape: const BeveledRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(3))),
                    title: TabBar(
                      indicator: const BoxDecoration(
                        color: kPrimaryColor,
                      ),
                      // indicatorWeight: 5,
                      // indicatorColor: kPrimaryColor,
                      dividerColor: kPrimaryColor,
                      dividerHeight: 0,
                      // indicatorWeight: ,
                      // indicatorPadding: EdgeInsets.only(right: 10),
                      labelPadding: const EdgeInsets.only(right: 15),
                      indicatorSize: TabBarIndicatorSize.tab,
                      // tabAlignment: TabAlignment.center,
                      labelStyle:
                          const TextStyle(fontFamily: 'poppins', fontSize: 13),
                      splashFactory: NoSplash.splashFactory,
                      // isScrollable: true,
                      tabs: [
                        const Tab(
                          child: Padding(
                            padding: EdgeInsets.only(left: 25),
                            child: Text('Account'),
                          ),
                        ),
                        Tab(
                          child: Container(
                            // width: 220,
                            height: 90,
                            decoration: const BoxDecoration(
                                border: Border(
                                    left: BorderSide(color: white, width: 1.8),
                                    right:
                                        BorderSide(color: white, width: 1.8))),
                            child: const Center(child: Text('Address')),
                          ),
                        ),
                        const Tab(
                          child: Padding(
                            padding: EdgeInsets.only(right: 6),
                            child: Text("Opening Balance"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                body: TabBarView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          ContainerFieldWidget(
                              widget: SimpleAutoCompleteTextField(
                                key: keyLedgerName,
                                controller: _nameCtr,
                                clearOnSubmit: false,
                                suggestions: ledgerListDisplay,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                ),
                                textSubmitted: (data) {
                                  lName = data;
                                  if (lName.isNotEmpty) {
                                    int _id = ledgerList
                                        .firstWhere(
                                            (element) => element.name == lName,
                                            orElse: () =>
                                                LedgerModel(id: 0, name: ''))
                                        .id;
                                    if (_id > 0) {
                                      ledgerId = _id.toString();
                                      isExist = true;
                                      findLedger(ledgerId);
                                    }
                                  }
                                },
                              ),
                              headTxt: 'Ledger Name'),
                          const SizedBox(
                            height: 10,
                          ),
                          ContainerFieldWidget(
                              widget: Container(
                                // width: MediaQuery.sizeOf(context).width,
                                decoration: BoxDecoration(
                                    border: Border.all(color: grey),
                                    borderRadius: BorderRadius.circular(3)),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    isExpanded: true,
                                    hint: const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('Select under',
                                          textAlign: TextAlign.center),
                                    ),
                                    value: _dropDownValue.toString(),
                                    items: ledgerGroupList
                                        .map<DropdownMenuItem<String>>((item) {
                                      return DropdownMenuItem<String>(
                                        value: item.id.toString(),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(item.name,
                                              overflow: TextOverflow.ellipsis),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        isUnderSelected = true;
                                        _dropDownValue = int.parse(value!);
                                      });
                                    },
                                  ),
                                ),
                              ),
                              headTxt: 'Under'),
                          // Card(
                          //   elevation: 10,
                          //   child: DropdownButton<String>(
                          //     isExpanded: true,
                          //     hint: const Padding(
                          //       padding: EdgeInsets.all(8.0),
                          //       child: Text('Select under',
                          //           textAlign: TextAlign.center),
                          //     ),
                          //     value: _dropDownValue.toString(),
                          //     items: ledgerGroupList
                          //         .map<DropdownMenuItem<String>>((item) {
                          //       return DropdownMenuItem<String>(
                          //         value: item.id.toString(),
                          //         child: Padding(
                          //           padding: const EdgeInsets.all(8.0),
                          //           child: Text(item.name,
                          //               overflow: TextOverflow.ellipsis),
                          //         ),
                          //       );
                          //     }).toList(),
                          //     onChanged: (value) {
                          //       setState(() {
                          //         isUnderSelected = true;
                          //         _dropDownValue = int.parse(value!);
                          //       });
                          //     },
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                    ListView(
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        ContainerFieldWidget(
                            widget: TextFormField(
                              controller: _add1Ctr,
                              keyboardType: TextInputType.text,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                            ),
                            headTxt: 'Address'),
                        const SizedBox(
                          height: 10,
                        ),
                        ContainerFieldWidget(
                            widget: TextFormField(
                              controller: _add2Ctr,
                              keyboardType: TextInputType.text,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                            ),
                            headTxt: 'Address 2'),
                        const SizedBox(
                          height: 10,
                        ),
                        ContainerFieldWidget(
                            widget: TextFormField(
                              controller: _add3Ctr,
                              keyboardType: TextInputType.text,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                            ),
                            headTxt: 'Address 3'),
                        const SizedBox(
                          height: 10,
                        ),
                        ContainerFieldWidget(
                            widget: TextFormField(
                              controller: _add4Ctr,
                              keyboardType: TextInputType.text,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                            ),
                            headTxt: 'Address 4'),
                        const SizedBox(
                          height: 10,
                        ),
                        ContainerFieldWidget(
                            widget: TextFormField(
                              controller: _taxNoCtr,
                              keyboardType: TextInputType.text,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                            ),
                            headTxt: 'Tax No'),
                        const SizedBox(
                          height: 10,
                        ),
                        ContainerFieldWidget(
                            widget: SimpleAutoCompleteTextField(
                              clearOnSubmit: false,
                              key: keyCity,
                              suggestions: cityList,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                              textSubmitted: (data) {
                                cityData = otherRegAreaList.firstWhere(
                                  (element) => element.name == data,
                                  orElse: () =>
                                      OtherRegistrationModel.emptyData(),
                                );
                              },
                              controller: _cityCtr,
                            ),
                            headTxt: 'Select Area'),
                        const SizedBox(
                          height: 10,
                        ),
                        ContainerFieldWidget(
                            widget: SimpleAutoCompleteTextField(
                              clearOnSubmit: false,
                              key: keyRoute,
                              suggestions: routeList,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                              textSubmitted: (data) {
                                routeData = otherRegRouteList.firstWhere(
                                  (element) => element.name == data,
                                  orElse: () =>
                                      OtherRegistrationModel.emptyData(),
                                );
                              },
                              controller: _routeCtr,
                            ),
                            headTxt: 'Select Route'),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          controller: _phoneNumberCtr,
                          maxLength: 12,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Telephone",
                            icon: Icon(Icons.phone),
                          ),
                        ),
                        TextFormField(
                          controller: _emailCtr,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(50),
                          ],
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'E-mail',
                            icon: Icon(Icons.email),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Card(
                          // color: kPrimaryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(3))),
                          elevation: 2,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'State',
                                  style: TextStyle(
                                      decoration: TextDecoration.underline),
                                ),
                                Text(
                                  'Code',
                                  style: TextStyle(
                                      decoration: TextDecoration.underline),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                              border: Border.all(color: grey),
                              borderRadius: BorderRadius.circular(3)),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<GSTStateModel>(
                              isExpanded: true,
                              items: gstStateModels
                                  .map<DropdownMenuItem<GSTStateModel>>((item) {
                                return DropdownMenuItem<GSTStateModel>(
                                  value: item,
                                  child: Text(item.state!),
                                );
                              }).toList(),
                              onChanged: (item) {
                                setState(() {
                                  _dropDownState = item!.state!;
                                  _stateCode = item.code!;
                                  gstStateM = item;
                                });
                              },
                              value: gstStateM,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "State Code : $_stateCode",
                          style: const TextStyle(
                              fontFamily: 'poppins',
                              color: kPrimaryColor,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        ContainerFieldWidget(
                            widget: TextFormField(
                              controller: _panCtr,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(20),
                              ],
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                            ),
                            headTxt: 'PAN'),
                        const SizedBox(
                          height: 10,
                        ),
                        ContainerFieldWidget(
                            widget: TextFormField(
                              controller: _pinCtr,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(10),
                              ],
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                            ),
                            headTxt: "PIN"),
                        const SizedBox(
                          height: 10,
                        ),
                        ContainerFieldWidget(
                            widget: TextFormField(
                              controller: _secondNameCtr,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                            ),
                            headTxt: 'Second Name(native language)'),
                        const SizedBox(
                          height: 10,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                                width: 120,
                                height: 30,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(3),
                                    color: kPrimaryColor),
                                child: const Center(
                                  child: Text(
                                    'Credit Limit',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontFamily: 'poppins',
                                        fontWeight: FontWeight.w500,
                                        color: white),
                                  ),
                                )),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                Expanded(
                                    child: ContainerFieldWidget(
                                        widget: TextFormField(
                                          controller: _creditAmtCtr,
                                          keyboardType: const TextInputType
                                              .numberWithOptions(decimal: true),
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                        headTxt: 'Amount')),
                                const SizedBox(
                                  width: 5,
                                ),
                                Expanded(
                                    child: ContainerFieldWidget(
                                        widget: TextFormField(
                                          controller: _creditDaysCtr,
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                        headTxt: 'Days')),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        ContainerFieldWidget(
                            widget: TextFormField(
                              controller: _personCtr,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                            ),
                            headTxt: 'Contact Person'),
                        const SizedBox(
                          height: 10,
                        ),
                        // const Text('SalesMan'),
                        ContainerFieldWidget(
                            widget: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3),
                                  border: Border.all(color: grey)),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  hint: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Select SalesMan',
                                        textAlign: TextAlign.center),
                                  ),
                                  items: salesManList
                                      .map<DropdownMenuItem<String>>((item) {
                                    return DropdownMenuItem<String>(
                                      value: item['Auto'].toString(),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(item['Name'],
                                            overflow: TextOverflow.ellipsis),
                                      ),
                                    );
                                  }).toList(),
                                  // value: salesManId.toString(),
                                  onChanged: (value) {
                                    setState(() {
                                      salesManId = int.parse(value!);
                                    });
                                  },
                                ),
                              ),
                            ),
                            headTxt: 'Select Salesman'),
                        // const Divider(
                        //   height: 150,
                        // ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Column(
                        children: [
                          // const Card(
                          //     child: Text(
                          //   'Opening Balance',
                          //   style: TextStyle(
                          //       fontSize: 25,
                          //       decoration: TextDecoration.underline),
                          // )),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              const Text(
                                'Date',
                                style: TextStyle(
                                    fontFamily: 'poppins',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                    border: Border.all(color: grey),
                                    borderRadius: BorderRadius.circular(3)),
                                child: InkWell(
                                  child: Row(
                                    children: [
                                      Text(
                                        obDate,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontFamily: 'poppins',
                                            fontSize: 15),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      const Icon(
                                        Icons.calendar_month_outlined,
                                        color: grey,
                                      )
                                    ],
                                  ),
                                  onTap: () => _selectDate(),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: ContainerFieldWidget(
                                      widget: TextFormField(
                                        controller: _debitAmountCtr,
                                        inputFormatters: [
                                          LengthLimitingTextInputFormatter(50),
                                        ],
                                        keyboardType: const TextInputType
                                            .numberWithOptions(decimal: true),
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                      headTxt: 'Receive Amount')),
                              const SizedBox(
                                width: 5,
                              ),
                              Expanded(
                                  child: ContainerFieldWidget(
                                      widget: TextFormField(
                                        controller: _creditAmountCtr,
                                        inputFormatters: [
                                          LengthLimitingTextInputFormatter(50),
                                        ],
                                        keyboardType: const TextInputType
                                            .numberWithOptions(decimal: true),
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                      headTxt: 'Pay Amount')),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          IntrinsicHeight(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(3),
                                        color: kPrimaryColor),
                                    child: CheckboxListTile(
                                      title: const Text(
                                        'Active',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontFamily: 'poppins',
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: white),
                                      ),
                                      value: valueActive,
                                      activeColor: white,
                                      checkColor: kPrimaryColor,
                                      side: const BorderSide(color: white),
                                      onChanged: (value) {
                                        setState(() {
                                          valueActive = value!;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                // const VerticalDivider(
                                //   color: Colors.black,
                                //   thickness: 2,
                                // ),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(3),
                                        color: kPrimaryColor),
                                    child: CheckboxListTile(
                                      value: valueCostCenter,
                                      activeColor: white,
                                      checkColor: kPrimaryColor,
                                      side: const BorderSide(color: white),
                                      onChanged: (value) {
                                        setState(() {
                                          valueCostCenter = value!;
                                        });
                                      },
                                      title: const Text(
                                        'Cost Center',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontFamily: 'poppins',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: white),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          IntrinsicHeight(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(3),
                                        color: kPrimaryColor),
                                    child: CheckboxListTile(
                                        value: valueFranchisee,
                                        activeColor: white,
                                        checkColor: kPrimaryColor,
                                        side: const BorderSide(color: white),
                                        onChanged: (value) {
                                          setState(() {
                                            valueFranchisee = value!;
                                          });
                                        },
                                        title: const Text(
                                          'Franchisee',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontFamily: 'poppins',
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: white),
                                        )),
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(3),
                                        color: kPrimaryColor),
                                    child: CheckboxListTile(
                                      value: valueBillWise,
                                      activeColor: white,
                                      checkColor: kPrimaryColor,
                                      side: const BorderSide(color: white),
                                      onChanged: (value) {
                                        setState(() {
                                          valueBillWise = value!;
                                        });
                                      },
                                      title: const Text(
                                        'Bill Wise (Receipt/Payment)',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontFamily: 'poppins',
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: white),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  clear() {}
  final TextEditingController _textFieldController = TextEditingController();
  _reNameLedgerDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'ReName $lName',
            style: const TextStyle(fontSize: 12),
          ),
          content: TextField(
            controller: _textFieldController,
            decoration: const InputDecoration(
                border: OutlineInputBorder(), label: Text("Enter New Name")),
          ),
          actions: [
            TextButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () async {
                Navigator.pop(context);
                setState(() {
                  _isLoading = true; //
                });
                var body = {
                  'newName': _textFieldController.text.toUpperCase(),
                  'oldName': lName.toUpperCase()
                };
                bool _state = await api.renameLedger(body);
                _state
                    ? showInSnackBar('Ledger Name Renamed')
                    : showInSnackBar('Error');
                if (_state) {
                  _nameCtr.text = _textFieldController.text.toUpperCase();
                  lName = _textFieldController.text.toUpperCase();
                  _textFieldController.text = '';
                }
                setState(() {
                  _isLoading = false;
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    // _textFieldController.dispose();
    // _panCtr.dispose();
    // _pinCtr.dispose();
    // _add1Ctr.dispose();
    // _add2Ctr.dispose();
    // _add3Ctr.dispose();
    // _add4Ctr.dispose();
    // _cityCtr.dispose();
    // _nameCtr.dispose();
    // _emailCtr.dispose();
    // _routeCtr.dispose();
    // _taxNoCtr.dispose();
    // _personCtr.dispose();
    // _creditAmtCtr.dispose();
    // _creditDaysCtr.dispose();
    // _debitAmountCtr.dispose();
    // _phoneNumberCtr.dispose();
    // _secondNameCtr.dispose();
    // _taxNoCtr.dispose();

    super.dispose();
  }
}
