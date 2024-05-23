import 'package:flutter/material.dart';
import 'package:flutter_settings_screen_ex/flutter_settings_screen_ex.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sheraccerp/models/company_user.dart';
import 'package:sheraccerp/service/api.dart';
import 'package:sheraccerp/util/res_color.dart';
import 'package:sheraccerp/widget/progress_hud.dart';

class UserLoginScreen extends StatefulWidget {
  const UserLoginScreen({Key? key}) : super(key: key);

  @override
  State<UserLoginScreen> createState() => _UserLoginScreenState();
}

class _UserLoginScreenState extends State<UserLoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _username = "", _password = "";
  String _regId = "", firm = "", firmCode = "";
  bool _isLoading = false, showPassword = true;
  ApiResponse? _apiResponse;

  @override
  void initState() {
    _load();
    super.initState();
  }

  _load() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      _regId = (pref.getString('regId') ?? "");
      firm = (pref.getString('CompanyName') ?? "");
      firmCode = (pref.getString('CustomerCode') ?? "");
    });
  }

  void _handleLogout() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout Company'),
        content: const Text('Do you want to logout'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              pref.remove('fId');
              pref.remove('api');
              pref.remove('apiV');
              pref.remove('regId');
              pref.remove('CompanyName');
              pref.remove('DBName');
              pref.remove('DBNameT');
              pref.remove('Active');
              pref.remove('UserName');
              pref.remove('Password');
              pref.remove('CustomerCode');
              Settings.clearCache();
              Navigator.pushNamedAndRemoveUntil(context, '/login_company',
                  ModalRoute.withName('/login_company'));
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            // backgroundColor: Theme.of(context).colorScheme.background,
            title: const Text(
              'Login',
              style: TextStyle(fontFamily: 'poppins'),
            ),
            // brightness: Brightness.dark,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  _handleLogout();
                },
              )
            ],
          ),
          body: ProgressHUD(
            inAsyncCall: _isLoading,
            color: red,
            opacity: 0.0,
            child: SingleChildScrollView(
              child: Container(
                alignment: Alignment.center,
                width: size.width,
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/images/baground_image.png'),
                        fit: BoxFit.cover)),
                // width: double.infinity,
                height: size.height,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Column(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 60,
                      ),
                      SizedBox(
                          width: 70,
                          height: 70,
                          child: Image.asset('assets/logo.png')),
                      SizedBox(
                          width: 130,
                          child: Image.asset(
                              'assets/images/shername_erp_image.png')),
                      Text(
                        'A Complete Accounting & Inventory Package',
                        style: TextStyle(
                            fontFamily: 'roman',
                            color: kPrimaryColor,
                            fontSize: 13),
                      ),
                      SizedBox(height: size.height * 0.09),
                      Form(
                        autovalidateMode: AutovalidateMode.always,
                        key: _formKey,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    // margin:
                                    //     const EdgeInsets.symmetric(vertical: 10),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 5),
                                    width: size.width,
                                    decoration: BoxDecoration(
                                      boxShadow: const [
                                        BoxShadow(
                                          offset: Offset(0, 5),
                                          color: Color.fromARGB(
                                              255, 222, 222, 222),
                                          spreadRadius: .1,
                                          blurRadius: 9,
                                        )
                                      ],
                                      color: white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: TextFormField(
                                      key: const Key("_username"),
                                      decoration: const InputDecoration(
                                        icon: Icon(
                                          Icons.person,
                                          color: kPrimaryColor,
                                        ),
                                        label: Text(
                                          "User Name",
                                          style: TextStyle(
                                              fontFamily: 'poppins',
                                              color: grey),
                                        ),
                                        border: InputBorder.none,
                                      ),
                                      keyboardType: TextInputType.text,
                                      onSaved: (String? value) {
                                        _username = value!.trim();
                                      },
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Username is required';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 5),
                                    width: size.width,
                                    decoration: BoxDecoration(
                                      boxShadow: const [
                                        BoxShadow(
                                          offset: Offset(0, 5),
                                          color: Color.fromARGB(
                                              255, 222, 222, 222),
                                          spreadRadius: .1,
                                          blurRadius: 9,
                                        )
                                      ],
                                      color: white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: TextFormField(
                                      decoration: InputDecoration(
                                        label: const Text(
                                          "Password",
                                          style: TextStyle(
                                              fontFamily: 'poppins',
                                              color: grey),
                                        ),
                                        icon: const Icon(
                                          Icons.lock,
                                          color: kPrimaryColor,
                                        ),
                                        suffixIcon: IconButton(
                                          icon: !showPassword
                                              ? const Icon(
                                                  Icons.visibility,
                                                  color: grey,
                                                )
                                              : const Icon(
                                                  Icons.visibility_off,
                                                  color: grey,
                                                ),
                                          color: kPrimaryColor,
                                          onPressed: () => setState(() =>
                                              showPassword = !showPassword),
                                        ),
                                        border: InputBorder.none,
                                      ),
                                      obscureText: showPassword,
                                      onSaved: (String? value) {
                                        _password = value!.trim();
                                      },
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Password is required';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 30),
                                  SizedBox(
                                    width: size.width,
                                    height: 45,
                                    child: TextButton(
                                      onPressed: _handleSubmitted,
                                      style: TextButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        foregroundColor: Colors.white,
                                        // padding: const EdgeInsets.symmetric(
                                        //     vertical: 20, horizontal: 40),
                                        backgroundColor: kPrimaryColor,
                                      ),
                                      child: const Text(
                                        "LOGIN",
                                        style: TextStyle(
                                            fontFamily: 'poppins',
                                            fontSize: 16),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                        foregroundColor: kPrimaryColor),
                                    child: const Text(
                                      "Create an account ?",
                                      style: TextStyle(fontFamily: 'poppins'),
                                    ),
                                    onPressed: () {
                                      Navigator.pushNamedAndRemoveUntil(
                                        context,
                                        '/register',
                                        ModalRoute.withName('/register'),
                                      );
                                    },
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Center(
                                    child: Text(
                                      'Welcome to $firm',
                                      style:
                                          const TextStyle(color: grey, fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ]),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )),
    );
  }

  void _handleSubmitted() async {
    setState(() {
      _isLoading = true;
    });
    final FormState form = _formKey.currentState!;
    if (!form.validate()) {
      showInSnackBar('Please fix the errors in red before submitting.');
    } else {
      if (_regId == "") {
        showInSnackBar('Sorry! your company not found');
      } else {
        form.save();
        _apiResponse = await authenticateUser(_username, _password, _regId);
        // if ((_apiResponse!.ApiError as ApiError).errori) {
        if ((_apiResponse!.apiError).error.isEmpty) {
          _saveAndRedirectToHome();
        } else {
          showInSnackBar((_apiResponse!.apiError).error);
          // (ApiError.fromJson((_apiResponse!.ApiError as List<dynamic>)[0]))
          //     .error);
        }
      }
    }
  }

  void _saveAndRedirectToHome() async {
    setState(() {
      _isLoading = false;
    });
    String _userId = (_apiResponse!.data as CompanyUser).userId;
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString("userId", _userId);

    if (_userId != "") {
      Navigator.pushNamedAndRemoveUntil(context, '/', ModalRoute.withName('/'));
      // ApiResponse _apiResponse = await getUserDetails(_userId);
      // if ((_apiResponse.ApiError as ApiError) == null) {
      //   Future.delayed(Duration(milliseconds: 3000), () {
      //     CompanyUser _user = _apiResponse.Data;
      //     if (_user.userType.toUpperCase() == 'ADMIN') {
      //       Navigator.pushNamedAndRemoveUntil(
      //           context, '/admin_home', ModalRoute.withName('/admin_home'),
      //           arguments: (_apiResponse.Data as CompanyUser));
      //     } else if (_user.userType.toUpperCase() == 'OWNER') {
      //   Navigator.pushNamedAndRemoveUntil(
      //       context, '/owner_home', ModalRoute.withName('/owner_home'),
      //       arguments: (_user));
      // } else if (_user.userType.toUpperCase() == 'STAFF') {
      //       Navigator.pushNamedAndRemoveUntil(
      //           context, '/staff_home', ModalRoute.withName('/staff_home'),
      //           arguments: (_apiResponse.Data as CompanyUser));
      //     } else if (_user.userType.toUpperCase() == 'SALESMAN') {
      //       Navigator.pushNamedAndRemoveUntil(context, '/salesMan_home',
      //           ModalRoute.withName('/salesMan_home'),
      //           arguments: (_apiResponse.Data as CompanyUser));
      //     } else {
      //       Navigator.pushNamedAndRemoveUntil(
      //           context, '/home', ModalRoute.withName('/home'));
      //     }
      //   });
      // }
    } else {
      showInSnackBar('your not a authorized user');
    }
  }

  void showInSnackBar(String value) {
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }
}
