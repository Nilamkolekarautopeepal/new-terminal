
// import 'package:terminalApp/utils/app_constants.dart';
import 'package:terminal/routes/routes_string.dart';
import 'package:terminal/utils/app_constants.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    Future.delayed(Duration(seconds: Constants.splashDelay), () {
      getScreen();
    });
    super.onInit();
  }

  Future<void> getScreen() async { 
       Get.offAndToNamed(Routes.loginScreen);
    }
     
  }