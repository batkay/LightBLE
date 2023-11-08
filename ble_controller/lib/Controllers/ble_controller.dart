import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';

class BLEController extends GetxController {
  Future scanDevices() async {
    if (await FlutterBluePlus.isSupported == false) {
      print("Bluetooth not supported");
      return;
    }
    // start a 10 second scan
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
    // end the scan after that time
    FlutterBluePlus.stopScan();
  }
}
