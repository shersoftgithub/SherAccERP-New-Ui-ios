import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sheraccerp/models/sales_man_model.dart';
import 'package:sheraccerp/service/api_dio.dart';
import 'package:sheraccerp/shared/constants.dart';
import 'package:sheraccerp/util/dateUtil.dart';
import 'package:sheraccerp/util/option_radio_group.dart';
import 'package:sheraccerp/util/res_color.dart';
import 'package:sheraccerp/widget/appbar_custom_widget.dart';
import 'package:sheraccerp/widget/container_textfield_widget.dart';
import 'package:sheraccerp/widget/progress_hud.dart';
import 'package:intl/intl.dart';

class SalesmanRegistration extends StatefulWidget {
  const SalesmanRegistration({Key? key}) : super(key: key);

  @override
  State<SalesmanRegistration> createState() => _SalesmanRegistrationState();
}

class _SalesmanRegistrationState extends State<SalesmanRegistration> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final nameControl = TextEditingController();
  final sectionControl = TextEditingController();
  final addressControl = TextEditingController();
  final address2Control = TextEditingController();
  final address3Control = TextEditingController();
  final mobileControl = TextEditingController();
  final salaryControl = TextEditingController();
  final otRateControl = TextEditingController();
  final otHourControl = TextEditingController();
  final dailyAllowanceControl = TextEditingController();
  final liveDeductionControl = TextEditingController();
  final casualLeaveControl = TextEditingController();
  final commissionPercentageControl = TextEditingController();
  final workingHourControl = TextEditingController();
  final pfControl = TextEditingController();
  final userNameControl = TextEditingController();
  final passwordControl = TextEditingController();

  GlobalKey<AutoCompleteTextFieldState<String>> keyName = GlobalKey();
  GlobalKey<AutoCompleteTextFieldState<String>> keySection = GlobalKey();
  DioService api = DioService();
  bool _isLoading = false,
      isExist = false,
      active = true,
      isSelectedApp = false;
  String id = '', lName = '';
  String _dropDownValueType = 'Monthly';
  String _dropDownValueCommissionStatus = 'No';
  DateTime now = DateTime.now();
  late SalesManModel salesman;
  late EmployeeModel employee;
  late List<SalesManModel> salesmanList = [];
  List<String> nameListDisplay = [];
  List<String> typeData = [
    "Monthly",
    "Daily",
    "Work Basis",
    "Per Hour Basis",
    "Weekly"
  ];
  List<String> commissionStatus = ["No", "Yes"];
  int? selectedGender;
  late String formattedDate;
  int locationId = 1;

  @override
  void initState() {
    super.initState();
    formattedDate =
        getToDay.isNotEmpty ? getToDay : DateFormat('dd-MM-yyyy').format(now);

    api.getSalesManListAll().then((value) {
      salesmanList.addAll(value);
      nameListDisplay.addAll(List<String>.from(salesmanList
          .map((item) => (item.name))
          .toList()
          .map((s) => s)
          .toList()));
    });
    locationId = ComSettings.appSettings(
            'int', 'key-dropdown-default-location-view', 2) -
        1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(100),
          child: AppbarWidgget(
            headTxt: 'Salesman',
            onPressed: () {
              Navigator.pop(context);
            },
          )),
      body: ProgressHUD(
        inAsyncCall: _isLoading,
        opacity: 0.0,
        child: contentWidget(),
      ),
    );
  }

  contentWidget() {
    return DefaultTabController(
      length: 3,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(children: [
              Expanded(
                flex: 0,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)),
                            backgroundColor: kPrimaryColor),
                        child: Text(
                          isExist ? 'Edit' : 'Save',
                          style: TextStyle(fontFamily: 'poppins', color: white),
                        ),
                        onPressed: () {
                          if (isExist) {
                            if (id.isNotEmpty) {
                              setState(() {
                                _isLoading = true;
                              });
                              handleSubmitted('edit');
                            } else {
                              showInSnackBar('Please select Name');
                            }
                          } else {
                            if (id.isEmpty) {
                              setState(() {
                                _isLoading = true;
                              });
                              handleSubmitted('save');
                            } else {
                              showInSnackBar('Please add Name');
                            }
                          }
                        },
                      ),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5)),
                              backgroundColor: kPrimaryColor),
                          onPressed: () => clear(),
                          child: const Text(
                            'Clear',
                            style: TextStyle(fontFamily: 'poppins', color: white),
                          )),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)),
                            backgroundColor: kPrimaryColor),
                        onPressed: isExist
                            ? () {
                                if (id.isNotEmpty) {
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  deleteData(context);
                                } else {
                                  showInSnackBar('Please select Name');
                                }
                              }
                            : () {
                              
                            },
                        child: const Text(
                          'Delete',
                          style: TextStyle(fontFamily: 'poppins', color: white),
                        ),
                      ),
                      // PopupMenuButton<String>(
                      //   icon: const Icon(Icons.settings, color: blue),
                      //   onSelected: (value) {
                      //     setState(() {
                      //       if (value == 'ReName') {
                      //         if (lName.isNotEmpty) {
                      //           _reNameDialog(context);
                      //         }
                      //       }
                      //     });
                      //   },
                      //   itemBuilder: (BuildContext context) => [
                      //     const PopupMenuItem<String>(
                      //       value: 'ReName',
                      //       child: Text('ReName'),
                      //     ),
                      //   ],
                      // ),
                    ]),
              ),
              const SizedBox(
                height: 10,
              ),
              ContainerFieldWidget(
                  widget: SimpleAutoCompleteTextField(
                    key: keyName,
                    controller: nameControl,
                    clearOnSubmit: false,
                    suggestions: nameListDisplay,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 7
                      ),
                      border: OutlineInputBorder(),
                    ),
                    textSubmitted: (data) {
                      lName = data;
                      if (lName.isNotEmpty) {
                        int _id = salesmanList
                            .firstWhere((element) => element.name == lName,
                                orElse: () => SalesManModel.emptyData())
                            .id;
                        if (_id > 0) {
                          id = _id.toString();
                          isExist = true;
                          findSalesman(lName);
                        }
                      }
                    },
                  ),
                  headTxt: 'Employee Name'),
              const SizedBox(
                height: 10,
              ),
              // SimpleAutoCompleteTextField(
              //   key: keySection,
              //   controller: sectionControl,
              //   clearOnSubmit: false,
              //   suggestions: [''],
              //   decoration: const InputDecoration(
              //       border: OutlineInputBorder(), labelText: 'Section'),
              // ),
              const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Gender',
                    style: TextStyle(
                        fontFamily: 'poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w500),
                  )),
              const SizedBox(
                height: 7,
              ),
              Container(
                width: MediaQuery.sizeOf(context).width,
                decoration: BoxDecoration(
                    border: Border.all(color: grey),
                    borderRadius: BorderRadius.circular(5)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: OptionRadio(
                          text: 'Male',
                          index: 0,
                          selectedButton: selectedGender,
                          press: (val) {
                            setState(() {
                              selectedGender = val;
                            });
                          }),
                    ),
                    Expanded(
                      child: OptionRadio(
                          text: 'Female',
                          index: 1,
                          selectedButton: selectedGender,
                          press: (val) {
                            setState(() {
                              selectedGender = val;
                            });
                          }),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              ContainerFieldWidget(
                  widget: TextField(
                    controller: addressControl,
                    maxLines: null,
                    decoration: const InputDecoration(
                       contentPadding: EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 7
                      ),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  headTxt: 'Address'),
              const SizedBox(
                height: 10,
              ),
              ContainerFieldWidget(
                  widget: TextField(
                    controller: address2Control,
                    maxLines: null,
                    decoration: const InputDecoration(
                       contentPadding: EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 7
                      ),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  headTxt: 'Address2'),
              const SizedBox(
                height: 10,
              ),
              ContainerFieldWidget(
                  widget: TextField(
                    controller: address3Control,
                    maxLines: null,
                    decoration: const InputDecoration(
                       contentPadding: EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 7
                      ),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  headTxt: 'Address3'),
              const SizedBox(
                height: 10,
              ),
              ContainerFieldWidget(
                  widget: TextField(
                    keyboardType: TextInputType.number,
                    controller: mobileControl,
                    decoration: const InputDecoration(
                       contentPadding: EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 7
                      ),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  headTxt: 'Mobile'),
              // SizedBox(
              //   height: 230,
              //   child: ListView(
              //     children: [
              //       const Divider(
              //         height: 2,
              //       ),
              //       const Divider(
              //         height: 2,
              //       ),
              //       const Divider(
              //         height: 2,
              //       ),
        
              //     ],
              //   ),
              // ),
              const SizedBox(
                height: 15,
              ),
              Column(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(5),
                        ),
                        color: Color(0xFF010BCD)),
                    width: MediaQuery.sizeOf(context).width,
                    child: const TabBar(
                      dividerColor: kPrimaryColor,
                      labelColor: white,
                      unselectedLabelColor: white,
                      labelStyle: TextStyle(fontFamily: 'poppins'),
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: BoxDecoration(
                        color: Color(0xff0008B3),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(5),
                        ),
                      ),
                      tabs: [
                        Tab(
                          text: 'Payroll',
                        ),
                        Tab(
                          text: 'Details',
                        ),
                        Tab(
                          text: 'Payroll App',
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 500,
                    child: TabBarView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Expanded(
                                      child: ContainerFieldWidget(
                                          widget: Container(
                                            height: 45,
                                            decoration: BoxDecoration(
                                                border: Border.all(color: grey),
                                                borderRadius:
                                                    BorderRadius.circular(3)),
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton<String>(
                                                isExpanded: true,
                                                hint: const Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text('Select type',
                                                      textAlign:
                                                          TextAlign.center),
                                                ),
                                                value:
                                                    _dropDownValueType.toString(),
                                                items: typeData.map<
                                                        DropdownMenuItem<String>>(
                                                    (item) {
                                                  return DropdownMenuItem<String>(
                                                    value: item.toString(),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Text(item,
                                                          style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight.w500,
                                                              fontFamily:
                                                                  'poppins',
                                                              fontSize: 15),
                                                          overflow: TextOverflow
                                                              .ellipsis),
                                                    ),
                                                  );
                                                }).toList(),
                                                onChanged: (value) {
                                                  setState(() {
                                                    _dropDownValueType = value!;
                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                          headTxt: 'Type')),
                                  const SizedBox(
                                    width: 3,
                                  ),
                                  Expanded(
                                    child: ContainerFieldWidget(
                                        widget: InkWell(
                                          child: Container(
                                            height: 45,
                                            decoration: BoxDecoration(
                                                border: Border.all(color: grey),
                                                borderRadius:
                                                    BorderRadius.circular(3)),
                                            child: Center(
                                              child: Text(
                                                formattedDate,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontFamily: 'poppins',
                                                    fontSize: 15),
                                              ),
                                            ),
                                          ),
                                          onTap: () => _selectDate(),
                                        ),
                                        headTxt: 'Date Of Join'),
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              ContainerFieldWidget(
                                  widget: TextField(
                                    controller: salaryControl,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    decoration: const InputDecoration(
                                       contentPadding: EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 7
                      ),
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  headTxt: 'Basic Salary'),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                      child: ContainerFieldWidget(
                                          widget: TextField(
                                            controller: otHourControl,
                                            keyboardType: const TextInputType
                                                .numberWithOptions(decimal: true),
                                            decoration: const InputDecoration(
                                               contentPadding: EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 7
                      ),
                                              border: OutlineInputBorder(),
                                            ),
                                          ),
                                          headTxt: 'O.T Hour')),
                                  const SizedBox(
                                    width: 3,
                                  ),
                                  Expanded(
                                      child: ContainerFieldWidget(
                                          widget: TextField(
                                            controller: otRateControl,
                                            keyboardType: const TextInputType
                                                .numberWithOptions(decimal: true),
                                            decoration: const InputDecoration(
                                               contentPadding: EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 7
                      ),
                                                border: OutlineInputBorder(),
                                                labelText: 'O.T Rate'),
                                          ),
                                          headTxt: 'O.T Rate')),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                      child: ContainerFieldWidget(
                                          widget: TextField(
                                            controller: dailyAllowanceControl,
                                            keyboardType: const TextInputType
                                                .numberWithOptions(decimal: true),
                                            decoration: const InputDecoration(
                                               contentPadding: EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 7
                      ),
                                              border: OutlineInputBorder(),
                                            ),
                                          ),
                                          headTxt: 'Daily Allowance')),
                                  const SizedBox(
                                    width: 2,
                                  ),
                                  Expanded(
                                      child: ContainerFieldWidget(
                                          widget: TextField(
                                            controller: casualLeaveControl,
                                            keyboardType: const TextInputType
                                                .numberWithOptions(decimal: true),
                                            decoration: const InputDecoration(
                                               contentPadding: EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 7
                      ),
                                              border: OutlineInputBorder(),
                                            ),
                                          ),
                                          headTxt: 'Casual Leave/Year')),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                      child: ContainerFieldWidget(
                                          widget: TextField(
                                            controller: liveDeductionControl,
                                            keyboardType: const TextInputType
                                                .numberWithOptions(decimal: true),
                                            decoration: const InputDecoration(
                                               contentPadding: EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 7
                      ),
                                              border: OutlineInputBorder(),
                                            ),
                                          ),
                                          headTxt: 'Leave Deduction')),
                                  const SizedBox(
                                    width: 2,
                                  ),
                                  Flexible(
                                    child: Column(
                                      children: [
                                        const SizedBox(
                                          height: 25,
                                        ),
                                        Container(
                                          height: 50,
                                          width: 150,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(3),
                                            color: const Color(0xff0008B3),
                                          ),
                                          child: Row(
                                            children: [
                                              Checkbox(
                                                activeColor: Colors.white,
                                                checkColor:
                                                    const Color(0xff0008B3),
                                                side: const BorderSide(
                                                    color: Colors.white),
                                                value: active,
                                                onChanged: (value) {
                                                  setState(() {
                                                    active = value!;
                                                  });
                                                },
                                              ),
                                              const Text(
                                                'Active',
                                                style: TextStyle(
                                                  fontFamily: 'poppins',
                                                  fontSize: 15,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                      child: ContainerFieldWidget(
                                          widget: Container(
                                            height: 45,
                                            decoration: BoxDecoration(
                                                border: Border.all(color: grey),
                                                borderRadius:
                                                    BorderRadius.circular(3)),
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton<String>(
                                                isExpanded: true,
                                                value:
                                                    _dropDownValueCommissionStatus
                                                        .toString(),
                                                items: commissionStatus.map<
                                                        DropdownMenuItem<String>>(
                                                    (item) {
                                                  return DropdownMenuItem<String>(
                                                    value: item.toString(),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Text(item,
                                                          overflow: TextOverflow
                                                              .ellipsis),
                                                    ),
                                                  );
                                                }).toList(),
                                                onChanged: (value) {
                                                  setState(() {
                                                    _dropDownValueCommissionStatus =
                                                        value!;
                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                          headTxt: 'Commission Status')),
                                  const SizedBox(
                                    width: 4,
                                  ),
                                  Expanded(
                                    child: ContainerFieldWidget(
                                      widget: TextField(
                                      controller:
                                          commissionPercentageControl,
                                      keyboardType: const TextInputType
                                          .numberWithOptions(decimal: true),
                                      decoration: const InputDecoration(
                                         contentPadding: EdgeInsets.symmetric(
                                                          horizontal: 5,
                                                          vertical: 7
                                                        ),
                                          border: OutlineInputBorder(),
                                          labelText: '%'),
                                    ),
                                     headTxt: '')
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                      child: ContainerFieldWidget(
                                          widget: TextField(
                                            controller: pfControl,
                                            keyboardType: const TextInputType
                                                .numberWithOptions(decimal: true),
                                            decoration: const InputDecoration(
                                              contentPadding: EdgeInsets.symmetric(
                                                          horizontal: 5,
                                                          vertical: 7
                                                        ),
                                              border: OutlineInputBorder(),
                                            ),
                                          ),
                                          headTxt: 'P.F')),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Expanded(
                                      child: ContainerFieldWidget(
                                          widget: TextField(
                                            controller: workingHourControl,
                                            keyboardType: const TextInputType
                                                .numberWithOptions(decimal: true),
                                            decoration: const InputDecoration(
                                              contentPadding: EdgeInsets.symmetric(
                                                          horizontal: 5,
                                                          vertical: 7
                                                        ),
                                              border: OutlineInputBorder(),
                                            ),
                                          ),
                                          headTxt: 'Working Hours')),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              ContainerFieldWidget(
                                  widget: TextField(
                                    controller: userNameControl,
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                                          horizontal: 5,
                                                          vertical: 7
                                                        ),
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  headTxt: 'UserName'),
                              const SizedBox(
                                height: 10,
                              ),
                              ContainerFieldWidget(
                                  widget: TextField(
                                    controller: passwordControl,
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                                          horizontal: 5,
                                                          vertical: 7
                                                        ),
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  headTxt: 'Password'),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const Text(
                                    'App Enable',
                                    style: TextStyle(
                                        fontFamily: 'poppins',
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Switch(
                                      trackOutlineWidth:
                                          const MaterialStatePropertyAll(14),
                                      thumbIcon:
                                          MaterialStateProperty.all(const Icon(
                                        Icons.circle,
                                        color: Color.fromARGB(255, 244, 242, 242),
                                        size: 27,
                                      )),
                                      trackOutlineColor:
                                          const MaterialStatePropertyAll(white),
                                      thumbColor:
                                          MaterialStateProperty.all(white),
                                      activeTrackColor: kPrimaryColor,
                                      inactiveTrackColor: const Color(0xffD9D9D9),
                                      onChanged: (bool value) {
                                        setState(() {
                                          isSelectedApp = value;
                                        });
                                      },
                                      value: isSelectedApp),
                                ],
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ]),
          ),
        ),
      ),
    );
  }

  clear() {
    nameControl.text = '';
    address2Control.text = '';
    address3Control.text = '';
    addressControl.text = '';
    mobileControl.text = '';
    salaryControl.text = '';
    otRateControl.text = '';
    otHourControl.text = '';
    dailyAllowanceControl.text = '';
    liveDeductionControl.text = '';
    casualLeaveControl.text = '';
    commissionPercentageControl.text = '';
    workingHourControl.text = '';
    pfControl.text = '';
    userNameControl.text = '';
    passwordControl.text = '';
    lName = '';
    id = '';
    _dropDownValueType = typeData[0];
    setState(() {
      isExist = false;
    });
  }

  @override
  void dispose() {
    nameControl.dispose();
    addressControl.dispose();
    address2Control.dispose();
    address3Control.dispose();
    mobileControl.dispose();
    salaryControl.dispose();
    otRateControl.dispose();
    otHourControl.dispose();
    dailyAllowanceControl.dispose();
    liveDeductionControl.dispose();
    casualLeaveControl.dispose();
    commissionPercentageControl.dispose();
    workingHourControl.dispose();
    pfControl.dispose();
    userNameControl.dispose();
    passwordControl.dispose();
    super.dispose();
  }

  void deleteData(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });
    bool result = await api.deleteSalesman(id, nameControl.text);
    if (result) {
      setState(() {
        _isLoading = false;
        showInSnackBar('Deleted : Salesman removed.');
        salesmanList.remove(employee);
        nameListDisplay.remove(nameControl.text);
        clear();
      });
    } else {
      showInSnackBar('error : Cannot delete this Salesman.');
    }
  }

  void handleSubmitted(String action) async {
    if (nameControl.text.trim().isNotEmpty &&
        salaryControl.text.trim().isNotEmpty &&
        _dropDownValueType.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      var _gender = selectedGender == 0 ? "M" : "F";
      var data = {
        'auto': id.isNotEmpty ? id.toString() : '0',
        'name': nameControl.text.isNotEmpty
            ? nameControl.text.trim().toUpperCase()
            : '',
        'address1':
            addressControl.text.isNotEmpty ? addressControl.text.trim() : '',
        'address2':
            address2Control.text.isNotEmpty ? address2Control.text.trim() : '',
        'address3':
            address3Control.text.isNotEmpty ? address3Control.text.trim() : '',
        'mobile':
            mobileControl.text.isNotEmpty ? mobileControl.text.trim() : '',
        'section': '',
        'location': locationId,
        'gender': _gender,
        'date': DateUtil.dateYMD(formattedDate),
        'type': _dropDownValueType,
        'salary': salaryControl.text.isNotEmpty ? salaryControl.text.trim() : 0,
        'ot': otRateControl.text.isNotEmpty ? otRateControl.text.trim() : 0,
        'otHour': otHourControl.text.isNotEmpty ? otHourControl.text.trim() : 0,
        'liveDeduction': liveDeductionControl.text.isNotEmpty
            ? liveDeductionControl.text.trim()
            : 0,
        'dailyAllowance': dailyAllowanceControl.text.isNotEmpty
            ? dailyAllowanceControl.text.trim()
            : 0,
        'casualLeave': casualLeaveControl.text.isNotEmpty
            ? casualLeaveControl.text.trim()
            : 0,
        'active': active ? 1 : 0,
        'commissionStatus': _dropDownValueCommissionStatus,
        'commissionPercentage': commissionPercentageControl.text.isNotEmpty
            ? commissionPercentageControl.text.trim()
            : 0,
        'pf': pfControl.text.isNotEmpty ? pfControl.text.trim() : 0,
        'workingHour': workingHourControl.text.isNotEmpty
            ? workingHourControl.text.trim().toString()
            : '0',
        'telephone': '',
        'activate': isSelectedApp,
        'total': 0,
        'tickEligibility': 0,
        'min': '',
        'empCode': '0',
        'empId': '',
        'vehicleCommission': 0,
        'loadingCharge': 0,
        'mode': '',
        'lunchMin': 0,
        'sms': '',
        'esi': 0,
        'att': 0,
        'expDate': '2020-01-01',
        'expDateArabic': '2020-01-01',
        'baladiyaExpDate': '2020-01-01',
        'passportExpDate': '2020-01-01',
        'user': userIdC,
        'daysInaMonth': 0,
        'presentDays': 0,
      };

      bool result = action == 'edit'
          ? await api.editSalesman(data)
          : await api.addSalesman(data);

      if (result) {
        saveAndRedirectToHome(action);
      } else {
        showInSnackBar(action == 'edit'
            ? 'error : Cannot edit this Salesman.'
            : 'error : Cannot save this Salesman.');
      }
    } else {
      showInSnackBar(action == 'edit'
          ? 'error : Cannot edit select name.'
          : 'error : Cannot save select name.');
    }
  }

  void saveAndRedirectToHome(action) async {
    setState(() {
      _isLoading = false;
      showInSnackBar(action == 'edit'
          ? 'Edited : Salesman edited.'
          : 'Saved : Salesman created.');
    });
  }

  void showInSnackBar(String value) {
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  void findSalesman(String name) {
    setState(() {
      _isLoading = true;
    });
    api.findSalesman(name).then((valueData) {
      employee = valueData;
      setState(() {
        isExist = true;
        nameControl.text = employee.name ?? '';
        lName = nameControl.text;
        addressControl.text = employee.address1 ?? '';
        address2Control.text = employee.address2 ?? '';
        address3Control.text = employee.address3 ?? '';
        mobileControl.text = employee.mobile ?? '';
        salaryControl.text = employee.salary.toString();
        otRateControl.text = employee.ot.toString();
        otHourControl.text = employee.otHour.toString();
        dailyAllowanceControl.text = employee.dailyAllowance.toString();
        liveDeductionControl.text = employee.liveDeduction.toString();
        casualLeaveControl.text = employee.casualLeave.toString();
        commissionPercentageControl.text =
            employee.commissionPercentage.toString();
        workingHourControl.text = employee.workingHour;
        pfControl.text = employee.pf.toString();
        userNameControl.text = '';
        passwordControl.text = '';
        isSelectedApp = employee.activate;
        active = employee.active == 1 ? true : false;
        // .text = employee.att;
        id = employee.auto.toString();
        // .text = employee.baladiyaExpiryDate;
        _dropDownValueCommissionStatus = employee.commissionStatus;
        formattedDate = DateUtil.dateDMY(employee.date);
        // .text = employee.empCode;
        // .text = employee.empId;
        // .text = employee.employeeSection;
        // .text = employee.esi;
        // .text = employee.expiryDate;
        // .text = employee.expiryDateArabic;
        selectedGender = employee.gender == 'M' ? 0 : 1;
        // .text = employee.ledCode;
        // .text = employee.loadingCharge;
        locationId = employee.location;
        // .text = employee.lunchMin;
        // .text = employee.min;
        // .text = employee.mode;
        // .text = employee.passportExpiryDate;
        // .text = employee.sms;
        // .text = employee.telephone;
        // .text = employee.tickEligibility;
        // .text = employee.total;
        _dropDownValueType = employee.type;
        // .text = employee.vehicleCommission;

        _isLoading = false;
      });
    });
  }

  final TextEditingController _textFieldController = TextEditingController();

  _reNameDialog(BuildContext context) {
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
                bool _state = await api.renameSalesMan(body);
                _state
                    ? showInSnackBar('Ledger Name Renamed')
                    : showInSnackBar('Error');
                if (_state) {
                  nameControl.text = _textFieldController.text.toUpperCase();
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

  Future _selectDate() async {
    DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100));
    if (picked != null) {
      setState(() => {formattedDate = DateFormat('dd-MM-yyyy').format(picked)});
    }
  }
}
