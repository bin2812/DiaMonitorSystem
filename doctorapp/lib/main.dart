import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import './utilities/app_constans.dart';
import './helper/get_di.dart' as di;
import 'controller/theme_controller.dart';
import 'helper/route_helper.dart';
import 'theme/dark_theme.dart';
import 'theme/light_theme.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return
      GetBuilder<ThemeController>(builder: (themeController){
        return GetMaterialApp(
          title: AppConstants.appName,
          initialRoute:  RouteHelper.getLoginPageRoute(),//RouteHelper.getOnBoardingPageRoute(),//LoginPage(),
          debugShowCheckedModeBanner: false,
          theme: themeController.darkTheme ? dark : light,
          getPages: RouteHelper.routes,
        );
      });
  }
}
