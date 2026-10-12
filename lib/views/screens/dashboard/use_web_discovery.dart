// import 'package:flutter/material.dart';
// import 'package:flutter_libserialport/flutter_libserialport.dart';
// import 'package:get/get.dart';
// // Ensure this path matches your project structure
// import 'package:terminal/logic/controller/cliCard/usbDiscoveryForWebController.dart';

// class UsbDeviceList extends StatelessWidget {
//   // Use Get.find if the controller is already initialized, otherwise Get.put
//   final controller = Get.put(UsbController());

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text("Windows VCI Discovery"),
//         centerTitle: true,
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: controller.refreshPorts,
//           )
//         ],
//       ),
//       body: Obx(() {
//         if (controller.isLoading.value) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         if (controller.availablePorts.isEmpty) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.usb_off, size: 64, color: Colors.grey.shade400),
//                 const SizedBox(height: 16),
//                 const Text(
//                   "No USB VCI detected.\nPlease check your connection.",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(color: Colors.grey, fontSize: 16),
//                 ),
//               ],
//             ),
//           );
//         }

//         return ListView.separated(
//           padding: const EdgeInsets.all(16),
//           itemCount: controller.availablePorts.length,
//           separatorBuilder: (context, index) => const SizedBox(height: 10),
//           itemBuilder: (context, index) {
//             final address = controller.availablePorts[index];
//             final port = SerialPort(address);

//             final isThisConnected = controller.isConnected.value &&
//                 controller.selectedAddress.value == address;

//             // Extract info once
//             final deviceName = port.productName ?? 'Unknown USB Device';
//             final vid = port.vendorId
//                     ?.toRadixString(16)
//                     .padLeft(4, '0')
//                     .toUpperCase() ??
//                 "N/A";
//             final pid = port.productId
//                     ?.toRadixString(16)
//                     .padLeft(4, '0')
//                     .toUpperCase() ??
//                 "N/A";

//             return Card(
//               elevation: 3,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12)),
//               color:
//                   isThisConnected ? Colors.green.shade50 : Colors.grey.shade50,
//               child: ListTile(
//                 contentPadding:
//                     const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                 leading: CircleAvatar(
//                   backgroundColor:
//                       isThisConnected ? Colors.green : Colors.blueGrey,
//                   child: const Icon(Icons.usb, color: Colors.white),
//                 ),
//                 title: Text(
//                   deviceName,
//                   style: const TextStyle(
//                       fontWeight: FontWeight.bold, fontSize: 16),
//                 ),
//                 subtitle: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text("Port: $address",
//                         style: const TextStyle(color: Colors.blueAccent)),
//                     Text("VID: 0x$vid | PID: 0x$pid",
//                         style: TextStyle(
//                             color: Colors.grey.shade700, fontSize: 12)),
//                   ],
//                 ),
//                 trailing: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor:
//                         isThisConnected ? Colors.green : Colors.blue,
//                     foregroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8)),
//                   ),
//                   onPressed: controller.isLoading.value || isThisConnected
//                       ? null
//                       : () => controller.connectToUsb(
//                             address,
//                           ),
//                   child: controller.isLoading.value &&
//                           (controller.selectedAddress.value == address)
//                       ? const SizedBox(
//                           width: 20,
//                           height: 20,
//                           child: CircularProgressIndicator(
//                               color: Colors.white, strokeWidth: 2),
//                         )
//                       : Text(isThisConnected ? "Active" : "Connect"),
//                 ),
//               ),
//             );
//           },
//         );
//       }),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:get/get.dart';
import 'package:terminal/logic/controller/cliCard/usbDiscoveryForWebController.dart';
import 'package:terminal/themes/app_colors.dart'; // Ensure this matches your theme path

class UsbDeviceList extends StatelessWidget {
  final controller = Get.put(UsbController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Windows VCI Discovery"),
        centerTitle: true,
        backgroundColor: AppColors.primaryColor, // Matching your theme
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: controller.refreshPorts,
          )
        ],
      ),
      // Use Obx and Stack to show the loader over the content
      body: Obx(() {
        return Stack(
          children: [
            _buildContent(),
            // Full Screen Overlay Loader
            if (controller.isLoading.value) _buildLoadingOverlay(),
          ],
        );
      }),
    );
  }

  Widget _buildContent() {
    if (controller.availablePorts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.usb_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              "No USB VCI detected.\nPlease check your connection.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: controller.availablePorts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final address = controller.availablePorts[index];
        final port = SerialPort(address);

        final isThisConnected = controller.isConnected.value &&
            controller.selectedAddress.value == address;

        final deviceName = port.productName ?? 'Unknown USB Device';
        final vid = port.vendorId?.toRadixString(16).padLeft(4, '0').toUpperCase() ?? "N/A";
        final pid = port.productId?.toRadixString(16).padLeft(4, '0').toUpperCase() ?? "N/A";

        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: isThisConnected ? Colors.green.shade50 : Colors.grey.shade50,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            leading: CircleAvatar(
              backgroundColor: isThisConnected ? Colors.green : Colors.blueGrey,
              child: const Icon(Icons.settings_input_component, color: Colors.white),
            ),
            title: Text(
              deviceName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Port: $address", style: const TextStyle(color: Colors.blueAccent)),
                Text("VID: 0x$vid | PID: 0x$pid",
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
              ],
            ),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isThisConnected ? Colors.green : AppColors.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: isThisConnected ? null : () => controller.connectToUsb(address),
              child: Text(isThisConnected ? "Active" : "Connect"),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.5), // Dims the entire UI
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
              ),
              const SizedBox(height: 24),
              const Text(
                "Initializing VCI...",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "Configuring COM Port and Protocol",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}