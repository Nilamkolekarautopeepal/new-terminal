import 'package:terminal/dev/dev_screen.dart';
import 'package:terminal/logic/bindings/drawer_bindings.dart';
import 'package:terminal/logic/bindings/login_bindings.dart';
import 'package:terminal/logic/bindings/terminal_bindings.dart';
import 'package:terminal/views/screens/auth/login.dart';
import 'package:terminal/views/screens/clicard/clicard.dart';
import 'package:terminal/views/screens/clicard/jobCard.dart';
import 'package:terminal/views/screens/clicard/jobCardDetails.dart';
import 'package:terminal/views/screens/clicard/terminalView.dart';
import 'package:terminal/views/screens/dashboard/usb_discovery.dart';
import 'package:terminal/views/screens/dashboard/use_web_discovery.dart';
import 'package:terminal/views/screens/dashboard/wifi_connect_screen.dart';
import 'package:get/get.dart';
import 'package:terminal/routes/routes_string.dart';
import 'package:terminal/views/screens/splash_screen.dart';


class AppRoutes {
  static final routes = [
    GetPage(name: Routes.splashScreen, page: () => SplashScreen()),
    GetPage(name: Routes.devScreen, page: () => DevScreen()),
     GetPage(
      name: Routes.loginScreen,
      binding: LoginBindings(),
      page: () => LoginScreen(),
    ),
     GetPage(
      name: Routes.cliCard,
      //binding: LoginBindings(),
      page: () => CliCard(),
    ),
    GetPage(
      name: Routes.jobCard,
      //binding: LoginBindings(),
      page: () => JobCardPage(),
    ),
    GetPage(
      name: Routes.jobCardDetails,
      //binding: LoginBindings(),
      page: () => JobCardDetailsPage(),
    ),
    // GetPage(
    //   name: Routes.blutoothDevices,
    //   //binding: LoginBindings(),
    //  // page: () => BluetoothDevicesPage(),
    // ),
    // GetPage(
    //   name: Routes.dashboardScreen,
    //   //binding: SplashBindings(),
    //   page: () => const DashboardScreen(),
    // ),
    GetPage(
      name: Routes.wifiScreen,
      binding: DrawerBinding(),
      page: () =>  DeviceList(),
    ),
     GetPage(
      name: Routes.loginScreen,
      //binding: SplashBindings(),
      page: () =>  LoginScreen(),
    ),
    //  GetPage(
    //   name: Routes.usbScreen,
    //   //binding: SplashBindings(),
    //   page: () =>  UsbDiscoveryPage(),
    // ),
    // GetPage(
    //   name: Routes.usbWebScreen,
    //   //binding: SplashBindings(),
    //   page: () =>  UsbDeviceList(),
    // ),
   GetPage(
  name: Routes.usbWebScreen,
  page: () {
    if (GetPlatform.isWindows) {
      return UsbDeviceList();
    } else {
      return UsbDiscoveryPage();
    }
  },
),
 GetPage(
      name: Routes.terminalScreen,
      binding: TerminalBinding(),
      page: () =>  TerminalView(),
    ),
  ];

}
