import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:doctorapp/helper/route_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utilities/sharedpreference_constants.dart';
import '../widget/toast_message.dart';
import 'package:get/get.dart';
class PostService{
  static Future postReq(url,body)async {
    if (kDebugMode) {
      print("======Url==========");
      print(url);
      print("======Send Data==========");
      print(body);
    }
    SharedPreferences preferences=await SharedPreferences.getInstance();
    final token=  preferences.getString(SharedPreferencesConstants.token)??"";
    try {
      var dio = Dio();
      dio.options.headers["authorization"] = "Bearer $token";
       dio.options.headers["contentType"] = "application/x-www-form-urlencoded";
      dio.options.validateStatus = (status) {
        // Allow 200 and 401 status codes, so they don't throw exceptions
        return status! < 500;
      };
      final response = await dio.post(url, data: body);
      if (kDebugMode) {
        print("==========URL Response==========");
        print(response);
      }
      if (response.statusCode == 401) {
        IToastMsg.showMessage("Session expired. Please log in again.");
        logOut();
        return null;
      }
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.toString());
        if (kDebugMode) {
          print("==========Response==========");
          print(jsonData);
        }
        if (jsonData['response'] == 201) {
          if (jsonData['message'] == "error") {
            IToastMsg.showMessage("Something went wrong");
          } else {
            IToastMsg.showMessage(jsonData['message']);
          }
          return null;
        }
        else if (jsonData['response'] == 200){
          return jsonData;
       }
      }else {
        IToastMsg.showMessage("Something went wrong");
        return null;
      }
    }catch(e){
       if (kDebugMode) {
         print(e);
       }
       IToastMsg.showMessage("Something went wrong");
       return null;
    }

  }
  static logOut()async{
    SharedPreferences prefs=await SharedPreferences.getInstance();
    prefs.clear();
    IToastMsg.showMessage("Logout");
    Get.offAllNamed(RouteHelper.getLoginPageRoute());
  }
}