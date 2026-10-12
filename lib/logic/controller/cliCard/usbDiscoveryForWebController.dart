import 'dart:async';
import 'dart:typed_data';
import 'package:ap_dongle_comm/utils/commController.dart';
import 'package:ap_dongle_comm/utils/dongleComm.dart';
import 'package:flutter/material.dart';
import 'package:terminal/routes/routes_string.dart';
import 'package:terminal/services/usb_socket_service_web.dart';
import 'package:get/get.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:terminal/logic/controller/cliCard/terminalController.dart';
import 'package:ap_dongle_comm/utils/enums/connectivity.dart';

class UsbController extends GetxController {
  UsbSerialService? _service;
  var availablePorts = <String>[].obs;
  var isLoading = false.obs;
  var isConnected = false.obs;
  var selectedAddress = "".obs;
  RxString selectedVciFromNav = "".obs; // Default to CAN2X if not provided
  late DongleComm dongleComm;
  @override
  void onInit() {
    super.onInit();
    refreshPorts();
    final args = Get.arguments as Map<String, dynamic>?;
    selectedVciFromNav.value = args?['vciName'] ?? 'CAN2X';
    print("📌 VCI Selected via Navigation: $selectedVciFromNav");
  }

  void refreshPorts() {
    isLoading.value = true;

    final ports = SerialPort.availablePorts;
    List<String> detectedPorts = [];

    for (final address in ports) {
      try {
        final port = SerialPort(address);

        final vid = port.vendorId ?? 0;
        final pid = port.productId ?? 0;
        final name = port.productName ?? "Unknown";

        print("🔍 Checking Port: $address → $name | VID: $vid | PID: $pid");

        // CP210x (Silicon Labs)
        bool isCp210x = vid == 4292;

        // CH340
        bool isCh340 = vid == 6790;

        if (isCp210x || isCh340) {
          print("✅ VCI Detected on $address");
          detectedPorts.add(address);
        }

        port.dispose(); // VERY IMPORTANT
      } catch (e) {
        print("❌ Error reading port $address: $e");
      }
    }

    availablePorts.value = detectedPorts;
    isLoading.value = false;

    print("🎯 Final Detected VCI Ports: $detectedPorts");
  }

  Future<bool> openPhysicalUsbPort(String address, int baud, vciType) async {
    final CommController comm = Get.find<CommController>();
    print("🔌 [USB-HW] Attempting to open $address at $baud baud...");

    int attempt = 0;
    while (attempt < 3) {
      attempt++;
      try {
        await comm.connectDesktopUsb(address, baud, Connectivity.rp1210Usb);
        print("✅ [USB-HW] Port opened successfully on attempt $attempt.");
        return true;
      } catch (e) {
        print(
            "⚠️ [USB-HW] Attempt $attempt failed: Port busy. Retrying in 1s...");
        await Future.delayed(const Duration(seconds: 1));
      }
    }
    return false;
  }

  Future<void> connectToUsb(String address) async {
    print("--------------------------------------------------");

    // FIX: Use the value saved in onInit from the Navigation Arguments
    String vciNameStr = selectedVciFromNav.value.toLowerCase();

    // This check will now correctly see "rp1210" if the user clicked it in CliCard
    bool isRP1210 =
        vciNameStr.contains("rp1210") || vciNameStr.contains("autopeepal");

    print(
        "🚀 [START] Desktop USB Connect | Mode: ${isRP1210 ? 'RP1210' : 'Standard/CAN2X'} | VCI: $vciNameStr");

    isLoading.value = true;
    final CommController comm = Get.find<CommController>();

    try {
      // 1️⃣ Close existing connection
      if (comm.isConnected.value) {
        print("🧹 Closing existing connection...");
        await comm.disconnect();
        // Give Windows time to release the COM port handle
        await Future.delayed(const Duration(milliseconds: 500));
      }

      // 2️⃣ Detect hardware & decide baud
      final tempPort = SerialPort(address);
      final vid = tempPort.vendorId ?? 0;
      tempPort.dispose();

      // Ensure RP1210 always uses 460800
      int targetBaud = (vid == 4292 || isRP1210) ? 460800 : 115200;

      // 3️⃣ Open physical port
      // Passing vciNameStr instead of the parameter
      bool opened = await openPhysicalUsbPort(address, targetBaud, vciNameStr);
      if (!opened) {
        throw Exception(
            "Port busy or Access Denied. Unplug and replug the VCI.");
      }

      // 4️⃣ Initialize DongleComm
      // RP1210: isChannel = false | Standard: isChannel = true
      dongleComm = DongleComm(comm: comm, isChannel: !isRP1210);

      // 5️⃣ Update logic flags
      comm.connectivity.value =
          isRP1210 ? Connectivity.rp1210Usb : Connectivity.usb;

      print("⌛ Waiting for VCI stabilization...");
      await Future.delayed(const Duration(seconds: 3));
      comm.clearBuffer();

      // 6️⃣ Update Connection State
      isConnected.value = true;
      selectedAddress.value = address;
      comm.isConnected.value = true;

      // 7️⃣ Setup Terminal Controller
      final terminal = Get.isRegistered<TerminalController>()
          ? Get.find<TerminalController>()
          : Get.put(TerminalController());

      terminal.dongleComm = dongleComm;
      terminal.isRp1210.value = isRP1210;
      terminal.firmwaron.value = vciNameStr;
      terminal.clearLogs();

      print("🟢 USB Connection Successful as ${comm.connectivity.value}");

      // 8️⃣ Navigate
      Get.toNamed(Routes.terminalScreen);
    } catch (e) {
      print("🛑 USB Connection Error: $e");
      isConnected.value = false;
      comm.isConnected.value = false;
      await comm.disconnect();

      Get.snackbar(
        "Connection Failed",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.85),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
      print("--------------------------------------------------");
    }
  }

  Uint8List hexToBytes(String hex) {
    if (hex.length % 2 != 0) hex = '0' + hex;
    final result = Uint8List(hex.length ~/ 2);
    for (var i = 0; i < result.length; i++) {
      result[i] = int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16);
    }
    return result;
  }

  String bytesToHex(Uint8List bytes) {
    return bytes
        .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
        .join(' ');
  }

  @override
  void onClose() {
    _service?.dispose();
    super.onClose();
  }
}
