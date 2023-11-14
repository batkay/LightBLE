import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BLEDevice extends ChangeNotifier {
  ScanResult? device;
  BluetoothDevice? bd;
  DeviceIdentifier? dev;

  bool valid = false;
  int selectedIndex = 0;
  List<BluetoothService>? services;
  // List<ScanResult>? deviceList = [];

  // Future<void> search() async {
  //   deviceList!.clear();
  //   var subscription = FlutterBluePlus.scanResults.listen((event) {
  //     // deviceList!.clear();
  //     if (event.isNotEmpty) {
  //       for (var device in event) {
  //         for (var adv in device.advertisementData.serviceUuids) {
  //           // if (adv == "b41a63b1-23e5-490a-9366-5867c165fc2a") {
  //           // add to device stream
  //           deviceList!.add(device);
  //           notifyListeners();
  //           break;
  //           // }
  //         }
  //       }
  //     } else {
  //       print("empty");
  //     }
  //   });

  //   FlutterBluePlus.startScan(scanMode: ScanMode.balanced, withServices: [Guid("yourSpecificServiceUUIDString")], timeout: Duration(seconds: 30))
  //   // await FlutterBluePlus.stopScan();
  //   print("cancel sub");
  //   await subscription.cancel();
  //   // await for (var scan in FlutterBluePlus.scanResults) {
  //   //   if (scan.isNotEmpty) {
  //   //     for (var device in scan) {
  //   //       for (var adv in device.advertisementData.serviceUuids) {
  //   //         // if (adv == "b41a63b1-23e5-490a-9366-5867c165fc2a") {
  //   //         // add to device stream
  //   //         deviceList!.add(device);
  //   //         break;
  //   //         // }
  //   //       }
  //   //     }
  //   //   } else {
  //   //     print("empty");
  //   //   }
  //   // }
  //   notifyListeners();
  // }

  void connectDevice(ScanResult d) async {
    selectedIndex = 2;
    device = d;
    bd = d.device;
    dev = bd!.remoteId;

    valid = true;
    await bd!.connect();
    await bd!.discoverServices();
    notifyListeners();
  }

  void disconnectDevice() {
    selectedIndex = 0;
    valid = false;
    device!.device.disconnect();
    notifyListeners();
  }
}
