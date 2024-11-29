import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sheraccerp/models/company_user.dart';
import 'package:sheraccerp/models/form_model.dart';
import 'package:sheraccerp/service/api_dio.dart';
import 'package:sheraccerp/widget/appbar_custom_widget.dart';
import 'package:sheraccerp/widget/user_control_list.dart';
import 'package:sheraccerp/service/api.dart';
import 'package:sheraccerp/util/dateUtil.dart';
import 'package:sheraccerp/util/res_color.dart';
import 'package:sheraccerp/widget/loading.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({Key? key}) : super(key: key);

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  var regId = "";
  bool nextWidget = false,changes = false;
  CompanyUser? userData;
  List<FormModel> form = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _load();
    super.initState();
    form = [];
  }

  _load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      regId = (prefs.getString('regId') ?? "0");
      // firm = (prefs.getString('CompanyName') ?? "");
      // firmCode = (prefs.getString('CustomerCode') ?? "");
    });
    // getCompanyUserControlList(userData.userId).then((value) => {form = value});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bagroundColor,
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(100),
          child: AppbarWidgget(
            headTxt: 'User List',
            onPressed: () {
              Navigator.pop(context);
            },
            iconSecondPath: Visibility(
              visible: nextWidget,
              child: Image.asset('assets/icons/Save instagram@2x.png',scale: 1.6,)
            ),
            onTapSecond: () {
              List<FormModel> forms = [];
                      forms = form
                          .where((element) => element.isChecked == true)
                          .toList();
                      var part = json.encode(forms);
                      var data = {'id': userData!.userId, 'data': part};
                      addUserControl(data).then((value) => {
                            value
                                ? ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Saved')),
                                  )
                                : ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Data Error')),
                                  )
                          });
                           var body = [
                    {
                      'id': userData!.registrationId.toString(),
                      'userId': userData!.userId.toString(),
                      'type': userData!.userType,
                      'insert': userData!.insertData ? 1 : 0,
                      'update': userData!.updateData ? 1 : 0,
                      'delete': userData!.deleteData ? 1 : 0
                    }
                  ];
                  if (changes) {
                    editCompanyUser(body).then((value) => null);
                  }
              // Visibility(        
              //       },
              //       icon: const Icon(
              //         Icons.save,
              //         color: white,
              //       )),
              // );
            
            },
          )),
      // AppBar(
      //   title: const Text('User List'),
      //   actions: [
      //     Visibility(
      //       visible: nextWidget,
      //       child: IconButton(
      //           onPressed: () {
      //             List<FormModel> forms = [];
      //             forms = form
      //                 .where((element) => element.isChecked == true)
      //                 .toList();
      //             var part = json.encode(forms);
      //             var data = {'id': userData!.userId, 'data': part};
      //             addUserControl(data).then((value) => {
      //                   value
      //                       ? ScaffoldMessenger.of(context).showSnackBar(
      //                           const SnackBar(content: Text('Saved')),
      //                         )
      //                       : ScaffoldMessenger.of(context).showSnackBar(
      //                           const SnackBar(content: Text('Data Error')),
      //                         )
      //                 });
      //           },
      //           icon: const Icon(Icons.save)),
      //     )
      //   ],
      // ),
      body: Container(
        child: nextWidget ? userDetails(userData!) : fetchUser(regId),
      ),
    );
  }

  Widget fetchUser(String id) {
    return FutureBuilder<List<CompanyUser>>(
      future: getCompanyUserList(id),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var data = snapshot.data;
          return Scaffold(
            backgroundColor: bagroundColor,
            body: Padding(
                padding: const EdgeInsets.only(left: 24, right: 24, top: 16),
                child: ListView.separated(
                  separatorBuilder: (context, index) {
                    return const SizedBox(
                      height: 10,
                    );
                  },
                  // physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: data!.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        setState(() {
                          userData = data[index];
                          nextWidget = true;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        width: MediaQuery.sizeOf(context).width,
                        height: 70,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'User: ${data[index].username}',
                              style: const TextStyle(
                                  fontFamily: 'poppins',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Logged In: ${DateUtil.dateTimeDMY(data[index].loginDate)}',
                                  style: const TextStyle(fontFamily: 'poppins'),
                                ),
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 2),
                                  alignment: Alignment.center,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(3),
                                    border: Border.all(
                                      color: const Color(0xff0008B3),
                                    ),
                                  ),
                                  child: Text(
                                    data[index].userType,
                                    style: const TextStyle(
                                        fontFamily: 'poppins',
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xff0008B3)),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                )
                // ListView.builder(
                //     itemCount: data!.length,
                //     itemBuilder: (BuildContext context, int index) {
                //       return Card(
                //         elevation: 2,
                //         child: ListTile(
                //           title: Text('User: ' + data[index].username),
                //           subtitle: Text('Logged In: ' +
                //               DateUtil.dateTimeDMY(data[index].loginDate)),
                //           trailing: Column(
                //             mainAxisAlignment: MainAxisAlignment.end,
                //             children: [
                //               Text(data[index].userType),
                //               Icon(Icons.circle,
                //                   size: 10,
                //                   color: data[index].active == "false"
                //                       ? red
                //                       : green),
                //             ],
                //           ),
                //           onTap: () {
                //             setState(() {
                //               userData = data[index];
                //               nextWidget = true;
                //             });
                //             // showEditDialog(context, data[index]);
                //           },
                //         ),
                //       );
                //     }),
                ),
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return const Loading();
      },
    );
  }

  showEditDialog(BuildContext context, CompanyUser user) async {
    TextEditingController _textFieldController = TextEditingController();
    TextEditingController _textFieldController1 = TextEditingController();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Change Password'),
            content: SizedBox(
              height: 110,
              child: Column(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textFieldController,
                      textInputAction: TextInputAction.go,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 8
                        ),
                          border: OutlineInputBorder(),
                          label: Text("Enter new password")),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _textFieldController1,
                      textInputAction: TextInputAction.go,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 8
                        ),
                          border: OutlineInputBorder(),
                          label: Text("Confirm password")),
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Submit'),
                onPressed: () {
                  if (_textFieldController.text == _textFieldController1.text &&
                      _textFieldController.text.isNotEmpty &&
                      _textFieldController1.text.isNotEmpty) {
                    var body = [
                      {
                        'id': user.registrationId.toString(),
                        'userId': user.userId.toString(),
                        'password': _textFieldController.text,
                      }
                    ];
                    changeCompanyUserPassword(body).then((value) {
                      String msg = "Error password update";
                      if (value) {
                        msg = "Password updated";
                        Navigator.of(context).pop();
                      }
                      Fluttertoast.showToast(msg: msg);
                    });
                  } else {
                    String msg = "Enter password";
                    if (_textFieldController.text
                            .compareTo(_textFieldController1.text) !=
                        0) {
                      msg = "Password not match";
                    }
                    Fluttertoast.showToast(msg: msg);
                  }
                },
              )
            ],
          );
        });
  }

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  List<String> roles = [
    'Staff',
    'SalesMan',
    'Delivery',
    'Collection',
    'Admin',
    'Manager',
    'Owner'
  ];
  String role = '';
  bool showPassword = true;

  userDetails(CompanyUser user) {
    _nameController.text = user.username.toString();
    _passwordController.text = user.password.toString();
    if (role == '') {
      role = user.userType;
    }
    return Form(
      autovalidateMode: AutovalidateMode.always,
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Row(
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                 
                  Container(
                    width: MediaQuery.of(context).size.width/2.9,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 2,
                      vertical: 5
                    ),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      border: Border.all(color: grey),
                      borderRadius: BorderRadius.circular(3)
                    ),
                    child: Text(
                      'No : ${user.userId}',
                      style: const TextStyle(
                        fontFamily: 'poppins'
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: MediaQuery.of(context).size.width/2.5,
                     padding: const EdgeInsets.symmetric(
                      horizontal: 2,
                      vertical: 5
                    ),
                      decoration: BoxDecoration(
                      border: Border.all(color: grey),
                      borderRadius: BorderRadius.circular(3)
                    ),
                    child: Text(
                      ' Date : ${DateUtil.dateDMY(user.atDate)}',
                      style: const TextStyle(
                        fontFamily: 'poppins'
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
              const Text(' Username',
              style: TextStyle(
                        fontFamily: 'poppins'
                      ),),
            Container(
              padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 10
                    ),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      border: Border.all(color: grey),
                      borderRadius: BorderRadius.circular(3)
                    ),
              child: Text(user.username.toString(),
              style: const TextStyle(
                        fontFamily: 'poppins'
                      ),
              )),
              const SizedBox(
                height: 10,
              ),
               const Text(' User Role',
              style: TextStyle(
                        fontFamily: 'poppins'
                      ),),
            Container(
              padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: grey),
                      borderRadius: BorderRadius.circular(3)
                    ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                    items: roles.map((String items) {
                      return DropdownMenuItem(
                        value: items,
                        child: Text(items,
                         style: const TextStyle(
                        fontFamily: 'poppins'
                      ),
                        ),
                      );
                    }).toList(),
                    value: role != '' ? role : roles[0],
                    onChanged: (value) {
                      setState(() {
                        role = value!;
                        user.userType = role;
                        changes = true;
                      });
                    }),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(' Options',
            style:  TextStyle(
                        fontFamily: 'poppins'
                      ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      border: Border.all(color: grey),
                      borderRadius: BorderRadius.circular(3)
                    ),
              child: Row(
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 10,
                  ),
                  const Text('Save',
                  style:  TextStyle(
                        fontFamily: 'poppins'
                      ),
                  ),
                  Checkbox(
                    activeColor: kPrimaryColor,
                    value: user.insertData,
                    onChanged: (value) {
                      setState(() {
                          user.insertData = value!;
                          changes = true;
                        });
                    }),
                  const Spacer(),
                  const Text('Edit',
                  style: TextStyle(
                        fontFamily: 'poppins'
                      ),
                  ),
                  Checkbox(
                    activeColor: kPrimaryColor,
                    value: user.updateData, 
                    onChanged: (value) {
                      setState(() {
                          user.updateData = value!;
                          changes = true;
                        });
                    }),
                  const Spacer(),
                  const Text('Delete',
                  style: TextStyle(
                        fontFamily: 'poppins'
                      ),
                  ),
                  Checkbox(
                    activeColor: kPrimaryColor,
                    value: user.deleteData, 
                    onChanged: (value) {
                       setState(() {
                          user.deleteData = value!;
                          changes = true;
                        });
                    }),
                ],
              ),
            ),
            // TextFormField(
            //   key: const Key("_username"),
            //   keyboardType: TextInputType.text,
            //   controller: _nameController,
            //   validator: (value) {
            //     if (value.isEmpty) {
            //       return 'Username is required';
            //     }
            //     return null;
            //   },
            // ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)
                  )
                ),
                  onPressed: () => showEditDialog(context, user),
                  child: const Text('Change Password',
                  style: TextStyle(
                        fontFamily: 'poppins',
                        color: white
                      ),
                  )),
              // TextFormField(
              //   decoration: InputDecoration(
              //     border: OutlineInputBorder(),label: Text("Password"),
              //     suffixIcon: IconButton(
              //       icon: const Icon(Icons.visibility),
              //       color: kPrimaryColor,
              //       onPressed: () => setState(() => showPassword = !showPassword),
              //     ),
              //   ),
              //   controller: _passwordController,
              //   obscureText: showPassword,
              //   validator: (value) {
              //     if (value.isEmpty) {
              //       return 'Password is required';
              //     }
              //     return null;
              //   },
              // ),
              const SizedBox(
                width: 10,
              ),
              const Padding(
                padding: EdgeInsets.all(2.0),
                child: Text(
                  'User Control',
                    style: TextStyle(
                        fontFamily: 'poppins',
                      ),
                ),
              ),
            ]),
            form.isEmpty
                ? userControlWidget(userData!.userId)
                : userControlWidgetLoad(),
          ],
        ),
      ),
    );
  }

  userControlWidgetLoad() {
    return Column(
        children: form
            .map(
              (FormModel item) => CheckboxListTile(
                activeColor: kPrimaryColor,
                title: Text(item.title!),
                value: item.isChecked,
                onChanged: (bool? val) {
                  setState(() => item.isChecked = val);
                },
              ),
            )
            .toList());
  }
  

  bool newControl = false;
  userControlWidget(id) {
    return FutureBuilder<List<FormModel>>(
      future: newControl
          ? getCompanyUserControlForms()
          : getCompanyUserControlList(id),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.isNotEmpty) {
            form = snapshot.data!;
            return Column(
                children: form
                    .map(
                      (FormModel item) => CheckboxListTile(
                        title: Text(item.title!),
                        value: item.isChecked,
                        onChanged: (bool? val) {
                          setState(() => item.isChecked = val);
                        },
                      ),
                    )
                    .toList());
          } else {
            return Align(
              alignment: Alignment.center,
              child: TextButton.icon(
                style: ButtonStyle(
                  shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)
                  )),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(kPrimaryColor),
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                ),
                onPressed: () {
                  setState(() {
                    newControl = true;
                  });
                },
                icon: const Icon(Icons.admin_panel_settings_outlined),
                label: const Text('Add'),
              ),
            );
          }
        } else {
          return const Loading();
        }
      },
    );
  }
}
