import 'package:terminal/logic/controller/cliCard/terminalController.dart';
import 'package:ap_dongle_comm/utils/commController.dart';
import 'package:get/get.dart';


class TerminalBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TerminalController>(() => TerminalController());
    Get.put<CommController>(CommController(), permanent: true);
  }
}