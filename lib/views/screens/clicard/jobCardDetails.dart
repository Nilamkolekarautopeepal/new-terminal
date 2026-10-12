import 'package:terminal/common_widgets/ui_helper_widgets.dart';
import 'package:terminal/logic/controller/cliCard/jobCardDetailsController.dart';
import 'package:terminal/routes/routes_string.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class JobCardDetailsPage extends StatelessWidget {
  JobCardDetailsPage({super.key});

  final JobCardDetailsController controller =
      Get.put(JobCardDetailsController());

  final Color primaryColor = const Color(0xFFFF7A00);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text("Job Card Details"),
        actions: [
          // VCI Name
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                controller.vciName,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),

          // Logout button
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: "Logout",
            onPressed: () {
              // Redirect to login page
              Get.offAllNamed(Routes
                  .loginScreen); // replace '/login' with your login route name
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // _detailsCard(),
            // C30(),
            const Text(
              "Start Diagnosis\nby connecting Dongle via",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            C20(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _connectionButton(
                  icon: Icons.bluetooth,
                  label: "Bluetooth",
                  onTap: () {
                    Get.toNamed(
                      Routes.blutoothDevices,
                      arguments: {
                        'vciName': controller.vciName,
                      },
                    );
                  },
                ),
                _connectionButton(
                  icon: Icons.usb,
                  label: "USB",
                  onTap: () {
                    Get.toNamed(
                      Routes.usbWebScreen,
                      arguments: {
                        'vciName': controller.vciName,
                      },
                    );
                  },
                ),
                // _connectionButton(
                //   icon: Icons.wifi,
                //   label: "WiFi",
                //   onTap: () {
                //     Get.toNamed(
                //       Routes.wifiScreen,
                //       arguments: {
                //         'vciName': controller.vciName,
                //       },
                //     );
                //   },
                // ),
                // Inside JobCardDetailsPage WiFi button onTap:
                _connectionButton(
                  icon: Icons.wifi,
                  label: "WiFi",
                  onTap: () {
                    // // Logic: If vciName contains "RP1210", set the flag to true

                    Get.toNamed(
                      Routes.wifiScreen,
                      arguments: {
                        'vciName': controller.vciName,
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _detailsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _rowItem("Job Card No", controller.jobCardNo),
          _divider(),
          _rowItem("Model", controller.model),
          _divider(),
          Row(
            children: [
              Expanded(
                child: _columnItem(
                  "Registration Number",
                  controller.registrationNumber,
                ),
              ),
              Expanded(
                child: _columnItem(
                  "KM Covered",
                  controller.kmCovered,
                ),
              ),
            ],
          ),
          _divider(),
          _rowItem("Chassis ID", controller.chassisId),
          _divider(),
          _rowItem("Complaints", controller.complaints),
        ],
      ),
    );
  }

  Widget _rowItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
              fontSize: 12, color: Colors.black, fontWeight: FontWeight.bold),
        ),
        C2(),
        Text(
          value,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade900

              // fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }

  Widget _columnItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
              fontSize: 12, color: Colors.black, fontWeight: FontWeight.bold),
        ),
        C2(),
        Text(
          value,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade900
              //fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Divider(color: Colors.grey.shade300, height: 1),
    );
  }

  Widget _connectionButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return Column(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(50),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: primaryColor, width: 2),
            ),
            child: Icon(
              icon,
              color: Colors.black,
              size: 28,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
