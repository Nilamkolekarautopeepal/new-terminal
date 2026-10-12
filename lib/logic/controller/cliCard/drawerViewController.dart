import 'dart:async';
import 'dart:typed_data';
import 'package:ap_dongle_comm/utils/enums/connectivity.dart';
import 'package:get/get.dart';
import 'package:convert/convert.dart';
import 'package:ap_dongle_comm/utils/commController.dart';
import 'package:ap_dongle_comm/utils/dongleComm.dart';
import 'package:terminal/logic/controller/cliCard/terminalController.dart';
import 'package:terminal/routes/routes_string.dart';
import 'package:terminal/services/hotspot_service.dart';

class DrawerViewController extends GetxController {
  RxInt index = 0.obs;
  RxBool isLoading = false.obs;
  String vciName = '';

  final MdnsDiscoveryService mdnsDiscoveryService = MdnsDiscoveryService();
  RxList<DiscoveredService> discoveredServices = <DiscoveredService>[].obs;
  final CommController comm = Get.find<CommController>();
  late DongleComm dongleComm;

  Rx<DiscoveredService> selectedDevice = DiscoveredService(
    name: '',
    host: '',
    port: 0,
    ip: '',
  ).obs;

  StreamSubscription<Uint8List>? _globalResponseSub;
RxString selectedVciFromNav = "".obs;
  @override
  Future<void> onInit() async {
    super.onInit();
    mdnsDiscoveryService.discoveredServices.listen(_onServiceFound);
    mdnsDiscoveryService.startDiscovery();
    _showLoader();
      final args = Get.arguments as Map<String, dynamic>?;
    selectedVciFromNav.value = args?['vciName'] ?? 'CAN2X';
    print("📌 VCI Selected via Navigation: $selectedVciFromNav");
  }

  void updatePage(int i) {
    index.value = i;
    Get.back();
    final args = Get.arguments as Map<String, dynamic>?;
    vciName = args?['vciName'] ?? 'VCI';
  }

  void refreshDiscovery() {
    print('🔄 Manual Discovery Reset triggered');
    discoveredServices.clear();
    mdnsDiscoveryService.startDiscovery();
  }

  void _showLoader() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 2));
    isLoading.value = false;
  }

  void _onServiceFound(DiscoveredService service) {
    final idx = discoveredServices.indexWhere((s) => s.name == service.name);
    if (idx == -1) {
      discoveredServices.add(service);
    } else {
      discoveredServices[idx] = service;
    }
    discoveredServices.refresh();
  }

  Future<bool> connectViaRP1210(DiscoveredService service, vciType) async {
    try {
      await comm.connectWifi(
          host: service.ip, port: 27015, selectedType: Connectivity.rp1210WiFi);
      comm.connectivity.value = Connectivity.rp1210WiFi;

      dongleComm = DongleComm(comm: comm, isChannel: false);

      print("✅ Socket Open. Ready for manual handshake on terminal.");
      return true; // Returns true immediately so you can reach the terminal
    } catch (e) {
      print("💥 Connection Error: $e");
      return false;
    }
  }

  Future<bool> connectViaStandardWifi(
      DiscoveredService service, vciType) async {
    print("🌐 [WiFi] Starting Standard Connection to: ${service.ip}");

    try {
      print("📡 [WiFi] Attempting socket connect on port 6888...");
      await comm.connectWifi(
          host: service.ip, port: 6888, selectedType: Connectivity.wiFi);

      comm.connectivity.value = Connectivity.wiFi;
      print("✅ [WiFi] Socket Connected. Mode set to wiFi.");

      dongleComm = DongleComm(comm: comm, isChannel: true);
      print("📦 [WiFi] DongleComm initialized (Channel: 00)");

      print("🏁 [WiFi] CONNECTION READY");
      return true;
    } catch (e) {
      print("💥 [WiFi] FATAL ERROR during connection: $e");
      return false;
    }
  }

  Future<void> connectToDevice(DiscoveredService service, int index) async {
    try {
      isLoading.value = true;

       String vciNameStr = selectedVciFromNav.value.toLowerCase();

      print("🚀 VCI DETECTED: $vciName");

      bool isRP1210 = vciNameStr.contains("rp1210");
      bool isCAN2X = vciNameStr.contains("can") || vciNameStr.contains("can2x");

      bool success = false;

      if (isRP1210) {
        success = await connectViaRP1210(service, vciNameStr);
      } else if (isCAN2X) {
        success = await connectViaStandardWifi(service, vciNameStr);
      } else {
        // fallback
        success = await connectViaStandardWifi(service, vciNameStr);
      }

      if (success) {
        final terminal = Get.isRegistered<TerminalController>()
            ? Get.find<TerminalController>()
            : Get.put(TerminalController());

        terminal.dongleComm = dongleComm;
        terminal.isRp1210.value = isRP1210;
        terminal.firmwaron.value = vciNameStr;

        Get.toNamed(Routes.terminalScreen);
      }
    } catch (e) {
      print("❌ Connection Exception: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> disconnectDevice() async {
    await comm.disconnect();
    _globalResponseSub?.cancel();
    selectedDevice.value =
        DiscoveredService(name: '', host: '', port: 0, ip: '');
    print('🔌 Disconnected.');
  }

  String bytesToHex(Uint8List bytes) => hex.encode(bytes).toUpperCase();

  @override
  void onClose() {
    mdnsDiscoveryService.stopDiscovery();
    _globalResponseSub?.cancel();
    super.onClose();
  }
}
