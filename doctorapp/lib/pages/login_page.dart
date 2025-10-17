import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../helper/route_helper.dart';
import '../service/login_screen_service.dart';
import '../service/login_service.dart';
import '../utilities/api_content.dart';
import '../widget/loading_Indicator_widget.dart';
import '../widget/toast_message.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import '../helper/theme_helper.dart';
import '../service/user_service.dart';
import '../utilities/app_constans.dart';
import '../utilities/colors_constant.dart';
import '../utilities/image_constants.dart';
import '../utilities/sharedpreference_constants.dart';
import '../widget/button_widget.dart';
import '../widget/input_label_widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final List _images=[];
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();
  bool obscureText=true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void initState() {
   // _emailController.text="doctor@gmail.com";
   // _passwordController.text="12345678";
    getAndSetData();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body:   _buildSlidingBody()
    );
  }
  _buildSlidingBody(){
  return  Stack(
    children: [
      _images.isEmpty?Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: ColorResources.bgColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(ImageConstants.logoImage,
                height: 200,
                width: 200,
              ),
              const SizedBox(height: 20),
              const Text(
                  '${AppConstants.appName} ',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 25
                  )),
            ],
          ),
        ),

      ) :  CarouselSlider.builder(
          itemCount:_images.length,
          options: CarouselOptions(
            height: MediaQuery.of(context).size.height,
            viewportFraction: 1,
            autoPlay: _images.length==1?false:true,
            enlargeCenterPage: false,
            onPageChanged: _callbackFunction,
          ),
          itemBuilder: (ctx, index, realIdx) {
            return
              CachedNetworkImage(
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
      child:
      SizedBox(
        height: 50,
        child:_isLoading?const ILoadingIndicatorWidget(): SmallButtonsWidget(
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
    final resImage=await LoginScreenService.getData();
    if(resImage!=null){
      for(int i=0;i<resImage.length;i++){
        _images.add("${ApiContents.imageUrl}/${resImage[i].image??""}");
      }
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final loggedIn = preferences.getBool(SharedPreferencesConstants.login) ?? false;
    final email = preferences.getString(SharedPreferencesConstants.email) ?? "";
    final password = preferences.getString(SharedPreferencesConstants.password) ?? "";
    if (loggedIn) {
      _handleSubmit(email,password);

    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }
  _openBottomSheetLogin(){
    return
      showModalBottomSheet(
        backgroundColor:  ColorResources.bgColor,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20.0),
            topLeft: Radius.circular(20.0),
          ),
        ),
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, setState) {
                return Padding(
                  padding: MediaQuery
                      .of(context)
                      .viewInsets,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SingleChildScrollView(
                      child:
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 20),
                            SizedBox(
                              width:double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildLogo(),
                                  const SizedBox(height: 20),
                                  const Text(
                                    '${AppConstants.appName} ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 25
                                    )),
                                  const SizedBox(height: 10),
                                  const   Text('Enter Credentials to login ',
                                      style:  TextStyle(
                                        color: ColorResources.secondaryFontColor,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14,
                                      )),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            InputLabel.buildLabelBox("Email "),
                            // const SizedBox(height: 10),
                            // InputLabel.buildLabelBox("Demo Email - doctor@gmail.com"),
                            const SizedBox(height: 10),
                            Container(
                              decoration: ThemeHelper().inputBoxDecorationShaddow(),
                              child: TextFormField(
                                keyboardType: TextInputType.emailAddress,
                                validator: (val) {
                                  if(val!.isEmpty){
                                    return "Enter email address";
                                  }
                                  else if((val.isNotEmpty) && !RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$").hasMatch(val)){
                                    return "Enter a valid email address";
                                  }
                                 else {return null;}
                                },
                                controller: _emailController,
                                decoration: ThemeHelper().textInputDecoration('Email'),
                              ),
                            ),
                            const SizedBox(height: 10),
                            InputLabel.buildLabelBox("Password"),
                            // const SizedBox(height: 10),
                            // InputLabel.buildLabelBox("Demo Password - 12345678"),
                            const SizedBox(height: 10),
                            Container(
                              decoration: ThemeHelper().inputBoxDecorationShaddow(),
                              child: TextFormField(
                                obscureText: obscureText,
                                keyboardType: TextInputType.text,
                                validator: (val){
                                  if(val!.isEmpty){
                                    return "Enter password";
                                  }
                                  else {return null;}
                                },
                                controller: _passwordController,
                                decoration: ThemeHelper().textInputDecorationWithSuffix('Password',
                                    IconButton(onPressed: (){
                                      setState((){
                                        obscureText=!obscureText;
                                      });
                                    },
                                        icon: const Icon(Icons.remove_red_eye,
                                        size: 20,))),
                              ),
                            ),
                            const SizedBox(height: 20),

                            SmallButtonsWidget(title: "Submit", onPressed:
                                (){
                              if(_formKey.currentState!.validate()){
                                Get.back();
                              _handleSubmit(_emailController.text,_passwordController.text);


                              }

                            }),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }
          );
        },

      ).whenComplete(() {

      });
  }
  _buildLogo() {
    return SizedBox(
      height: 130,
      child: Image.asset(ImageConstants.logoImage),
    );
  }

  void _handleSubmit(String email, String password) async{
    setState(() {
      _isLoading=true;
    });
    final resLogin=await LoginService.login(email: email,
        password: password);
    if(resLogin!=null){
      String? token=resLogin['token'];
      String? uid=resLogin['data']['id']?.toString();
      List? role=resLogin['data']['role'];
      bool assignedRole=false;
      if(role!=null){
        for(var e in role){
          if(e['name']=="Doctor"){
            assignedRole=true;
            break;
          }
        }
      }else{
        _handleErrorRes("The user has not been assigned a doctor role.");
        return;
      }
      if(!assignedRole){
        _handleErrorRes("The user has not been assigned a doctor role.");
        return;
      }
      String name="${resLogin['data']['f_name']} ${resLogin['data']['l_name']}";
      String clinicId="${resLogin['data']['assign_clinic_id']}";
      if(token==null||token==""||uid==null||uid==""||clinicId==""){
        _handleErrorRes("Something went wrong");
        return;
      }
      SharedPreferences preferences=await SharedPreferences.getInstance();
      await  preferences.setString(SharedPreferencesConstants.email,email);
      await  preferences.setString(SharedPreferencesConstants.password,password);
      await  preferences.setString(SharedPreferencesConstants.token,token);
      await  preferences.setString(SharedPreferencesConstants.uid,uid);
      await  preferences.setString(SharedPreferencesConstants.name,name);
      await  preferences.setBool(SharedPreferencesConstants.login,true);
      await  preferences.setString(SharedPreferencesConstants.clinicId,clinicId);

      UserService.updateFCM();
      Get.offAllNamed(RouteHelper.getHomePageRoute());

    }else{
      _openBottomSheetLogin();
    }
    setState(() {
      _isLoading=false;
    });
  }
  _handleErrorRes(String msg){
    _openBottomSheetLogin();
    IToastMsg.showMessage(msg);
    setState(() {
      _isLoading=false;
    });
  }
}
