// import 'package:terminal/logic/controller/cliCard/drawerViewController.dart';
// import 'package:terminal/routes/routes_string.dart';
// import 'package:terminal/services/hotspot_service.dart';
// import 'package:terminal/themes/app_colors.dart';
// import 'package:terminal/utils/app_assets.dart';
// import 'package:terminal/utils/extension/extension/text_extension.dart';
// import 'package:terminal/utils/responsive_helper.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class DeviceList extends StatelessWidget {
//   DeviceList({Key? key}) : super(key: key);
//   final controller = Get.put(DrawerViewController());
//   @override
//   Widget build(BuildContext context) {
//     bool isMobile = ResponsiveHelper.isMobile(context);

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         toolbarHeight: isMobile ? 60 : 80,
//         centerTitle: true,
//         backgroundColor: AppColors.primaryColor,
//         title: ("Devices").toInter(
//           fontWeight: FontWeight.w700,
//           fontSize: isMobile ? 20 : 28,
//           color: AppColors.white,
//         ),
//         leading: GestureDetector(
//           onTap: () => Get.back(),
//           child: const Icon(Icons.arrow_back_ios, color: Colors.white),
//         ),
//         actions: [
//           IconButton(
//             onPressed: () {
//               controller.refreshDiscovery();
//             },
//             icon: Icon(Icons.refresh, color: Colors.white),
//           ),
//         ],
//       ),
//       body: Obx(() {
//         if (controller.isLoading.value) {
//           // While searching for devices
//           return Center(
//             child: SizedBox(
//               width: 30,
//               height: 30,
//               child: CircularProgressIndicator(
//                 strokeWidth: 3,
//                 backgroundColor: AppColors.primaryColor.withValues(alpha: 0.3),
//                 valueColor: AlwaysStoppedAnimation<Color>(
//                   AppColors.primaryColor,
//                 ),
//               ),
//             ),
//           );
//         } else if (controller.discoveredServices.isEmpty) {
//           // No devices found
//           return Center(
//             child: "No devices found".toInter(
//               fontSize: 16,
//               color: AppColors.pinkishGrey,
//               fontWeight: FontWeight.w500,
//             ),
//           );
//         } else {
//           // List of found devices
//           return ListView.builder(
//             itemCount: controller.discoveredServices.length,
//             itemBuilder: (context, index) {
//               return Obx(() {
//                 DiscoveredService service =
//                     controller.discoveredServices[index];
//                 bool isSelected = service == controller.selectedDevice.value;

//                 return Container(
//                   margin: EdgeInsets.symmetric(
//                     horizontal: isMobile ? 20 : 134,
//                     vertical: isMobile ? 10 : 15,
//                   ),
//                   padding: EdgeInsets.symmetric(
//                     horizontal: 24,
//                     vertical: 10,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Color(0xffF5F5F5),
//                     borderRadius: BorderRadius.circular(20),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withValues(alpha: 0.25),
//                         offset: Offset(0, 4),
//                         blurRadius: 4,
//                       ),
//                     ],
//                   ),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             service.name.toInter(
//                               color: Colors.black,
//                               fontSize: 15,
//                               fontWeight: FontWeight.w400,
//                             ),
//                             SizedBox(height: 15),
//                             service.ip.toInter(
//                               color: Colors.black,
//                               fontSize: 15,
//                               fontWeight: FontWeight.w400,
//                             ),
//                           ],
//                         ),
//                       ),
//                       GestureDetector(
//                         onTap: () async {
//                           if (!isSelected) {
//                             // Show a loading snackbar or indicator if you want
//                             Get.rawSnackbar(
//                                 message: "Connecting to ${service.name}...");

//                             // Use the port from the service!
//                             // await controller.connectToDevice(service, index);
//                             // This forces the RP1210 logic path
//                             await controller.connectToDevice(
//                               service,
//                               index,
//                             );

//                             // Check if the controller now says we are connected
//                             // if (controller.isSocketConnected.value) {
//                             Get.toNamed(Routes.terminalScreen);
//                             // } else {
//                             //   Get.snackbar("Error", "Failed to connect to device");
//                             // }
//                           }
//                         },
//                         child: Image.asset(
//                           AppAssets.linkImage,
//                           height: 40,
//                           width: 40,
//                           color: !isSelected
//                               ? AppColors.primaryColor
//                               : Colors.green,
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               });
//             },
//           );
//         }
//       }),
//     );
//   }
// }
import 'package:terminal/logic/controller/cliCard/drawerViewController.dart';
import 'package:terminal/routes/routes_string.dart';
import 'package:terminal/services/hotspot_service.dart';
import 'package:terminal/themes/app_colors.dart';
import 'package:terminal/utils/app_assets.dart';
import 'package:terminal/utils/extension/extension/text_extension.dart';
import 'package:terminal/utils/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeviceList extends StatelessWidget {
  DeviceList({Key? key}) : super(key: key);
  final controller = Get.put(DrawerViewController());

  @override
  Widget build(BuildContext context) {
    bool isMobile = ResponsiveHelper.isMobile(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: isMobile ? 60 : 80,
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
        title: ("Devices").toInter(
          fontWeight: FontWeight.w700,
          fontSize: isMobile ? 20 : 28,
          color: AppColors.white,
        ),
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () => controller.refreshDiscovery(),
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
      // Use Stack to layer the loading overlay on top of the list
      body: Obx(() {
        return Stack(
          children: [
            _buildDeviceContent(isMobile),
            if (controller.isLoading.value) _buildLoadingOverlay(),
          ],
        );
      }),
    );
  }

  // Separated the Device List building logic
  Widget _buildDeviceContent(bool isMobile) {
    if (controller.discoveredServices.isEmpty && !controller.isLoading.value) {
      return Center(
        child: "No devices found".toInter(
          fontSize: 16,
          color: AppColors.pinkishGrey,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    return ListView.builder(
      itemCount: controller.discoveredServices.length,
      itemBuilder: (context, index) {
        DiscoveredService service = controller.discoveredServices[index];
        bool isSelected = service == controller.selectedDevice.value;

        return Container(
          margin: EdgeInsets.symmetric(
            horizontal: isMobile ? 20 : 134,
            vertical: isMobile ? 10 : 15,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xffF5F5F5),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                offset: const Offset(0, 4),
                blurRadius: 4,
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    service.name.toInter(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                    const SizedBox(height: 15),
                    service.ip.toInter(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () async {
                  if (!isSelected && !controller.isLoading.value) {
                    // Logic for the long connection process
                    await controller.connectToDevice(service, index);
                    // Navigation only happens if connection is successful
                    Get.toNamed(Routes.terminalScreen);
                  }
                },
                child: Image.asset(
                  AppAssets.linkImage,
                  height: 40,
                  width: 40,
                  color: !isSelected ? AppColors.primaryColor : Colors.green,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // The Full Screen Loader that blocks UI interaction
  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.4), // Dims the background
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
              ),
              const SizedBox(height: 20),
              "Establishing Connection...".toInter(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              const SizedBox(height: 8),
              "This may take a few seconds".toInter(
                color: Colors.grey,
                fontSize: 12,
              ),
            ],
          ),
        ),
      ),
    );
  }
}