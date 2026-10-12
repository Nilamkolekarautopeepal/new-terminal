
import 'package:terminal/logic/controller/splashController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatelessWidget {
   SplashScreen({Key? key}) : super(key: key);
final SplashController controller=Get.put(SplashController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/new/00.png',
              fit: BoxFit.cover,
            ),
          ),         
        ],
      ),
    );
  }
}
