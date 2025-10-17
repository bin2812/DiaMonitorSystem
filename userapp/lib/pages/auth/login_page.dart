import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:country_picker/country_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../controller/user_controller.dart';
import '../../helpers/route_helper.dart';
import '../../helpers/theme_helper.dart';
import '../../services/login_screen_service.dart';
import '../../services/user_service.dart';
import '../../services/user_subscription.dart';
import '../../utilities/api_content.dart';
import '../../utilities/app_constans.dart';
import '../../utilities/colors_constant.dart';
import '../../utilities/image_constants.dart';
import '../../utilities/sharedpreference_constants.dart';
import '../../widget/button_widget.dart';
import '../../widget/input_label_widget.dart';
import '../../widget/loading_Indicator_widget.dart';
import '../../widget/toast_message.dart';

class LoginPage extends StatefulWidget {
  final Function? onSuccessLogin;

  const LoginPage({super.key, required this.onSuccessLogin});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final List _images = [];
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  bool obscureText = true;
  String phoneCode = "+";
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _fNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  String phoneNumberWithCode = "";

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void initState() {
    phoneCode = AppConstants.defaultCountyCode;
    // _mobileController.text="1234567890";
    // _otpController.text="123456";
    getAndSetData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildSlidingBody());
  }

  _buildSlidingBody() {
    return Stack(
      children: [
        _images.isEmpty
            ? Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                color: ColorResources.bgColor,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        ImageConstants.logoImage,
                        height: 200,
                        width: 200,
                      ),
                      const SizedBox(height: 20),
                      const Text('${AppConstants.appName} ',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 25)),
                    ],
                  ),
                ),
              )
            : CarouselSlider.builder(
                itemCount: _images.length,
                options: CarouselOptions(
                  height: MediaQuery.of(context).size.height,
                  viewportFraction: 1,
                  autoPlay: _images.length == 1 ? false : true,
                  enlargeCenterPage: false,
                  onPageChanged: _callbackFunction,
                ),
                itemBuilder: (ctx, index, realIdx) {
                  return CachedNetworkImage(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    fit: BoxFit.fill,
                    imageUrl: _images[index],
                    placeholder: (context, url) => const Center(child: Icon(Icons.image)),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  );
                },
              ),
        Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: SizedBox(
              height: 50,
              child: _isLoading
                  ? const ILoadingIndicatorWidget()
                  : SmallButtonsWidget(
                      title: "Login",
                      onPressed: () {
                        _openBottomSheetLogin();
                      }),
            ))
      ],
    );
  }

  _callbackFunction(int index, CarouselPageChangedReason reason) {
    // setState(() {
    //   _currentIndex = index;
    // });
  }

  void getAndSetData() async {
    setState(() {
      _isLoading = true;
    });
    final resImage = await LoginScreenService.getData();
    if (resImage != null) {
      for (int i = 0; i < resImage.length; i++) {
        _images.add("${ApiContents.imageUrl}/${resImage[i].image ?? ""}");
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  _openBottomSheetLogin() {
    return showModalBottomSheet(
      backgroundColor: ColorResources.bgColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20.0),
          topLeft: Radius.circular(20.0),
        ),
      ),
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (BuildContext context, setState) {
          return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildLogo(),
                            const SizedBox(height: 20),
                            const Text('${AppConstants.appName} ',
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 25)),
                            const SizedBox(height: 10),
                            const Text('Enter Credential to login ',
                                style: TextStyle(
                                  color: ColorResources.secondaryFontColor,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                )),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      InputLabel.buildLabelBox("Enter Phone Number"),
                      // const SizedBox(height: 20),
                      // InputLabel.buildLabelBox("Enter Demo Number to login"),
                      // const SizedBox(height: 20),
                      // InputLabel.buildLabelBox("Demo Country Code - +91"),
                      // const SizedBox(height: 20),
                      // InputLabel.buildLabelBox("Demo Phone - 1234567890"),
                      const SizedBox(height: 10),
                      Container(
                        decoration: ThemeHelper().inputBoxDecorationShaddow(),
                        child: TextFormField(
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                            ],
                            keyboardType: Platform.isIOS
                                ? const TextInputType.numberWithOptions(decimal: true, signed: true)
                                : TextInputType.number,
                            validator: (item) {
                              return item!.length > 5 ? null : "Enter valid number";
                            },
                            controller: _mobileController,
                            decoration: InputDecoration(
                              prefixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(width: 9),
                                  GestureDetector(
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 8.0),
                                      child: Text(
                                        phoneCode,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black),
                                      ),
                                    ),
                                    onTap: () {
                                      showCountryPicker(
                                        context: context,
                                        showPhoneCode:
                                            true, // optional. Shows phone code before the country name.
                                        onSelect: (Country country) {
                                          phoneCode = "+${country.phoneCode}";
                                          //  print('Select country: ${country.phoneCode}');
                                          setState(() {});
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                              hintText: "Ex 1234567890",
                              fillColor: Colors.white,
                              filled: true,
                              contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(color: Colors.grey)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(color: Colors.grey.shade400)),
                              errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(color: Colors.red, width: 2.0)),
                              focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(color: Colors.red, width: 2.0)),
                            )),
                      ),
                      const SizedBox(height: 20),
                      SmallButtonsWidget(
                          title: "Submit",
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              Get.back();
                              phoneNumberWithCode = "$phoneCode${_mobileController.text}";
                              _handleLogin();
                            }
                          }),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
      },
    ).whenComplete(() {});
  }

  _openBottomSheetForRegisterUser() {
    return showModalBottomSheet(
      backgroundColor: ColorResources.bgColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20.0),
          topLeft: Radius.circular(20.0),
        ),
      ),
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (BuildContext context, setState) {
          return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 10),
                            Text('Register $phoneNumberWithCode',
                                style: const TextStyle(
                                  color: ColorResources.secondaryFontColor,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                )),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        decoration: ThemeHelper().inputBoxDecorationShaddow(),
                        child: TextFormField(
                          keyboardType: TextInputType.name,
                          validator: (item) {
                            return item!.length > 3 ? null : "Enter first name";
                          },
                          controller: _fNameController,
                          decoration: ThemeHelper().textInputDecoration('First Name*'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: ThemeHelper().inputBoxDecorationShaddow(),
                        child: TextFormField(
                          keyboardType: TextInputType.name,
                          validator: (item) {
                            return item!.length > 3 ? null : "Enter Last name";
                          },
                          controller: _lastNameController,
                          decoration: ThemeHelper().textInputDecoration('Last Name*'),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SmallButtonsWidget(
                          title: "Submit",
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              Get.back();
                              _handleRegister();
                              //   _handleAuth();
                            }
                          }),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
      },
    ).whenComplete(() {});
  }

  _buildLogo() {
    return SizedBox(
      height: 130,
      child: Image.asset(ImageConstants.logoImage),
    );
  }

  void _handleRegister() async {
    setState(() {
      _isLoading = true;
    });
    final res = await UserService.addUser(
        fName: _fNameController.text,
        lName: _lastNameController.text,
        isdCode: phoneCode,
        phone: _mobileController.text);
    if (res != null) {
      IToastMsg.showMessage("Successfully Registered");
      _handleLogin();
    } else {
      setState(() {
        _isLoading = false;
      });
      _openBottomSheetForRegisterUser();
    }
  }

  void _handleLogin() async {
    setState(() {
      _isLoading = true;
    });
    final res = await UserService.loginUser(phone: _mobileController.text);
    if (res != null) {
      //    'message' => "Not Exists",
      if (res['message'] == "Not Exists") {
        setState(() {
          _isLoading = false;
        });
        _openBottomSheetForRegisterUser();
      } else if (res['message'] == "Successfully") {
        IToastMsg.showMessage("Logged in");
        _handleSuccessLogin(res);
      }
    } else {
      IToastMsg.showMessage("Something went wrong");
      setState(() {
        _isLoading = false;
      });
    }
  }

  _handleSuccessLogin(var res) async {
    setState(() {
      _isLoading = true;
    });
    final userData = res;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(SharedPreferencesConstants.token, userData['token']);
    await preferences.setString(SharedPreferencesConstants.uid, userData['data']['id'].toString());
    await preferences.setString(SharedPreferencesConstants.name,
        "${userData['data']['f_name']} ${userData['data']['l_name']}");
    await preferences.setString(SharedPreferencesConstants.phone, userData['data']['phone']);
    await preferences.setBool(SharedPreferencesConstants.login, true);
    UserController userController = Get.find(tag: "user");
    userController.getData();
    UserService.updateFCM();
    UserSubscribe.toTopi(topicName: "PATIENT_APP");
    // Close any open overlays (bottom sheets) then pop LoginPage
    if (Get.isOverlaysOpen) {
      Get.back();
    }
    if (Get.key.currentState?.canPop() == true) {
      Get.back();
    }
    // Trigger caller's intent if provided (they usually navigate to target)
    if (widget.onSuccessLogin != null) {
      widget.onSuccessLogin!.call();
    } else {
      // If no callback, ensure we land on Home
      Get.offAllNamed(RouteHelper.getHomePageRoute());
    }
    setState(() {
      _isLoading = false;
    });
  }
}
