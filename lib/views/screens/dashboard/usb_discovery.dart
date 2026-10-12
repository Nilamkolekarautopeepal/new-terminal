import 'package:terminal/logic/controller/cliCard/usbDiscoveryController.dart';
import 'package:terminal/themes/app_colors.dart';
import 'package:terminal/utils/app_assets.dart';
import 'package:terminal/utils/extension/extension/text_extension.dart';
import 'package:terminal/utils/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UsbDiscoveryPage extends StatelessWidget {
  UsbDiscoveryPage({Key? key}) : super(key: key);

  final controller = Get.put(UsbDiscoveryController());

  @override
  Widget build(BuildContext context) {
    bool isMobile = ResponsiveHelper.isMobile(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: isMobile ? 60 : 80,
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
        title: ("USB Devices").toInter(
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
            onPressed: () => controller.hardRefresh(),
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
      // Use Obx and Stack to overlay the loader
      body: Obx(() {
        return Stack(
          children: [
            _buildDeviceList(isMobile),
            // Global Loader Overlay
            if (controller.isConnecting.value) _buildLoadingOverlay(),
          ],
        );
      }),
    );
  }

  Widget _buildDeviceList(bool isMobile) {
    if (controller.isLoading.value) {
      return Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryColor,
        ),
      );
    }

    if (controller.discoveredDevices.isEmpty) {
      return Center(
        child: "No USB devices detected".toInter(
          fontSize: 16,
          color: AppColors.pinkishGrey,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    return ListView.builder(
      itemCount: controller.discoveredDevices.length,
      itemBuilder: (context, index) {
        final device = controller.discoveredDevices[index];
        bool isSelected = controller.isConnected.value &&
            controller.selectedUsbDevice.value.deviceId == device.deviceId;

        return Container(
          margin: EdgeInsets.symmetric(
            horizontal: isMobile ? 20 : 134,
            vertical: isMobile ? 10 : 15,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                    device.name.toInter(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    const SizedBox(height: 8),
                    "Path: /usb/dev/${device.deviceId}".toInter(
                      color: Colors.black54,
                      fontSize: 13,
                    ),
                    const SizedBox(height: 4),
                    "Status: ${isSelected ? 'Active' : 'Disconnected'}".toInter(
                      color: isSelected ? Colors.green : Colors.black54,
                      fontSize: 13,
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (!isSelected && !controller.isConnecting.value) {
                    controller.connectToDevice(device, index);
                  }
                },
                child: Image.asset(
                  AppAssets.linkImage,
                  height: 40,
                  width: 40,
                  color: isSelected ? Colors.green : AppColors.primaryColor,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Full Screen Loader for USB Connection
  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.5), // Dim the background
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
              ),
              const SizedBox(height: 20),
              "Opening USB Port...".toInter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
              const SizedBox(height: 8),
              "Stabilizing VCI hardware".toInter(
                fontSize: 13,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
