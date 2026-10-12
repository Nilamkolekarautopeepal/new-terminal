import 'package:terminal/api/app_envirments.dart';
import 'package:terminal/app.dart';

void main() async {
  App.instance.initAndRunApp(
    devMode: true,
    appLog: true,
    apiLog: false,
    setDefault: true,
    samplePayment: true,
    baseURLType: AtomURLType.PROD, 
  );
}
