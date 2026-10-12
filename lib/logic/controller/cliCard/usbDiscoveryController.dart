import 'dart:async';
import 'package:ap_dongle_comm/utils/commController.dart';
import 'package:ap_dongle_comm/utils/dongleComm.dart';
import 'package:ap_dongle_comm/utils/enums/connectivity.dart';
import 'package:terminal/logic/controller/cliCard/terminalController.dart';
import 'package:terminal/routes/routes_string.dart';
import 'package:terminal/services/usb_services.dart';
import 'package:terminal/services/usb_socket_services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:usb_serial/usb_serial.dart';

class UsbDiscoveryController extends GetxController {
  final UsbDiscoveryService _discoveryService = UsbDiscoveryService();
  UsbSerialService? usbSerialService;

  var discoveredDevices = <UsbDiscoveredDevice>[].obs;
  var isLoading = false.obs;
  var isConnecting = false.obs;
  var isConnected = false.obs;
  RxString selectedVciFromNav = "".obs;
  var selectedUsbDevice =
      UsbDiscoveredDevice(name: "", deviceId: 0, vid: 0, pid: 0).obs;
  late DongleComm dongleComm;
  @override
  void onInit() {
    super.onInit();
    _startListening();
    hardRefresh();
    final args = Get.arguments as Map<String, dynamic>?;
    selectedVciFromNav.value = args?['vciName'] ?? 'CAN2X';
    print("📌 VCI Selected via Navigation: $selectedVciFromNav");
  }

  void _startListening() {
    _discoveryService.discoveredDevices.listen((device) {
      if (!discoveredDevices.any((d) => d.deviceId == device.deviceId)) {
        discoveredDevices.add(device);
      }
    });

    _discoveryService.deviceOffline.listen((device) {
      discoveredDevices.removeWhere((d) => d.deviceId == device.deviceId);
      if (selectedUsbDevice.value.deviceId == device.deviceId) {
        isConnected.value = false;
        usbSerialService?.disconnect();
      }
    });
  }

  Future<void> hardRefresh() async {
    isLoading.value = true;
    discoveredDevices.clear();
    await _discoveryService.startDiscovery();
    await Future.delayed(const Duration(seconds: 1));
    isLoading.value = false;
  }

  RxInt index = 0.obs;

  String vciName = "";
  void updatePage(int i) {
    index.value = i;
    Get.back();
    final args = Get.arguments as Map<String, dynamic>?;
    vciName = args?['vciName'] ?? 'VCI';
  }

  bool _isProcessingConnection = false;

  /// 1. Standard USB Logic
  Future<bool> connectViaStandardUsb(
      UsbDiscoveredDevice discovered, String vciType) async {
    print("🔌 [USB] Opening Physical Port: VID ${discovered.vid}");
    try {
      // FIX: Request permission explicitly (Missing in your snippet)

      int targetBaud = (discovered.vid == 4292) ? 460800 : 115200;
      UsbPort? port = await discovered.device!.create();

      if (port == null) return false;

      final CommController comm = Get.find<CommController>();
      await comm.connectUsb(port, targetBaud, Connectivity.usb);

      comm.connectivity.value = Connectivity.usb;
      dongleComm = DongleComm(comm: comm, isChannel: true);

      return true;
    } catch (e) {
      print("💥 [Standard USB] Error: $e");
      return false;
    }
  }

  /// 2. RP1210 USB Logic
  Future<bool> connectRP1210Usb(
      UsbDiscoveredDevice discovered, String vciType) async {
    print("🛠️ [USB] Opening RP1210 Physical Port: VID ${discovered.vid}");
    try {
      // FIX: Request permission explicitly

      int targetBaud = 460800;
      UsbPort? port = await discovered.device!.create();

      if (port == null) return false;

      final CommController comm = Get.find<CommController>();
      await comm.connectUsb(port, targetBaud, Connectivity.rp1210Usb);

      comm.connectivity.value = Connectivity.rp1210Usb;
      dongleComm = DongleComm(comm: comm, isChannel: false);

      return true;
    } catch (e) {
      print("💥 [USB] RP1210 Error: $e");
      return false;
    }
  }

  /// MAIN ENTRY POINT
  Future<void> connectToDevice(
      UsbDiscoveredDevice discovered, int index) async {
    // Prevent double-triggering seen in logs
    if (_isProcessingConnection) return;

    try {
      _isProcessingConnection = true;
      isConnecting.value = true;

     String vciNameStr = selectedVciFromNav.value.toLowerCase();

    // This check will now correctly see "rp1210" if the user clicked it in CliCard
    bool isRP1210 =
        vciNameStr.contains("rp1210") || vciNameStr.contains("autopeepal");

    print(
        "🚀 [START] Desktop USB Connect | Mode: ${isRP1210 ? 'RP1210' : 'Standard/CAN2X'} | VCI: $vciNameStr");

      print("--------------------------------------------------");

      // FIX: Improved Detection Logic
      // Add 'autopeepal' if it should always be RP1210 mode

      print("❓ [DEBUG] Detected RP1210 Mode: $isRP1210");

      bool success = false;

      if (isRP1210) {
        success = await connectRP1210Usb(discovered, vciNameStr);
      } else {
        success = await connectViaStandardUsb(discovered, vciNameStr);
      }

      if (success) {
        // Wait for boot sequence (FWVERSION-5.0.2 etc) to finish
        print("⌛ [DEBUG] Waiting for boot strings to finish...");
        await Future.delayed(const Duration(seconds: 4));

        // DRAIN the buffer of the "FWVERSION" and "USER SSID" strings
        // seen in your RAW USB logs
        print("🧹 [DEBUG] Draining boot text from buffer...");
        Get.find<CommController>().clearBuffer();

        final terminal = Get.isRegistered<TerminalController>()
            ? Get.find<TerminalController>()
            : Get.put(TerminalController());

        terminal.dongleComm = dongleComm;
        terminal.isRp1210.value = isRP1210;
        terminal.firmwaron.value = vciNameStr;
        terminal.clearLogs();

        Get.toNamed(Routes.terminalScreen);
      } else {
        Fluttertoast.showToast(msg: "Connection Failed");
      }
    } catch (e) {
      print("🛑 [EXCEPTION] $e");
    } finally {
      isConnecting.value = false;
      _isProcessingConnection = false;
      print("--------------------------------------------------");
    }
  }
  // ... (Keep disconnectDevice and onClose)

  Future<void> disconnectDevice() async {
    if (usbSerialService != null) {
      await usbSerialService!.disconnect();
      usbSerialService = null;
    }
    isConnected.value = false;
  }

  @override
  void onClose() {
    _discoveryService.dispose();
    super.onClose();
  }
}
