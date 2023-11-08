import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:io' show Platform;

class FindDevicePage extends StatefulWidget {
  const FindDevicePage({Key? key}) : super(key: key);

  @override
  FindDevicePageState createState() => FindDevicePageState();
}

class FindDevicePageState extends State<FindDevicePage> {
  Future _scanList() async {
    // start a 10 second scan
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
    // end the scan after that time
    // await FlutterBluePlus.stopScan();
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("init");
    // check if bluetooth is supported by your hardware
    // Note: The platform is initialized on the first call to any FlutterBluePlus method.
    if (FlutterBluePlus.isSupported == false) {
      print("Bluetooth not supported by this device");
      return;
    }

    // handle bluetooth on & off
    // note: for iOS the initial state is typically BluetoothAdapterState.unknown
    // note: if you have permissions issues you will get stuck at BluetoothAdapterState.unauthorized
    FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
      print(state);
      if (state == BluetoothAdapterState.on) {
        // usually start scanning, connecting, etc
        print("good");
      } else {
        // show an error to the user, etc
        print("bad");
      }
    });

    // turn on bluetooth ourself if we can
    // for iOS, the user controls bluetooth enable/disable
    if (Platform.isAndroid) {
      FlutterBluePlus.turnOn();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        title: const Text("Find Lightstick"),
      ),
      body: SingleChildScrollView(
          child: Column(
        children: [
          Center(
              child:
                  TextButton(onPressed: _scanList, child: const Text("Scan"))),
          StreamBuilder<List<ScanResult>>(
              stream: FlutterBluePlus.scanResults,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final devices = snapshot.data;
                  print("Len ");
                  print(devices!.length);
                  return ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: devices!.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          title: Text(devices![index].toString()),
                        ),
                      );
                    },
                  );
                } else {
                  return const Text("No Devices Found");
                }
              })
          // for (BluetoothDevice ble in FlutterBluePlus.connectedDevices)
          //   ListTile(title: Text(ble.advName)),
        ],
      )),
    );
  }
}
