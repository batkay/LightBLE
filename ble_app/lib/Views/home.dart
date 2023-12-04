import 'dart:convert';

import 'package:ble_app/Controllers/ble_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';

var blue = Guid("52f09b90-df0f-4783-bc36-dca7e3a792f7");
var red = Guid("f0c34848-394f-44fd-8a5a-0e6f39d711fe");
var green = Guid("85a61293-1b8e-4127-b8bf-94e8f8c73d20");
var namerid = Guid("e25e0e65-52c1-4d10-9dc4-c0b52521e769");
var service = Guid("b41a63b1-23e5-490a-9366-5867c165fc2a");

class FindDevicePage extends StatefulWidget {
  const FindDevicePage({Key? key}) : super(key: key);

  @override
  FindDevicePageState createState() => FindDevicePageState();
}

class FindDevicePageState extends State<FindDevicePage> {
  Color light = Colors.lightBlue;
  Future _scanList() async {
    // start a 10 second scan
    await FlutterBluePlus.startScan(
        withServices: [Guid("b41a63b1-23e5-490a-9366-5867c165fc2a")],
        timeout: Duration(seconds: 15)); // end the scan after that time
    // await FlutterBluePlus.stopScan();
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("init");
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BLEDevice>(builder: (context, value, child) {
      if (!value.valid) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.pinkAccent,
            title: const Text("Find Lightstick"),
          ),
          body: SingleChildScrollView(
              child: Column(
            children: [
              Center(
                  child: TextButton(
                      onPressed: _scanList, child: const Text("Scan"))),

              StreamBuilder<List<ScanResult>>(
                  stream: FlutterBluePlus.scanResults,
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      final devices = snapshot
                          .data; // can be null if app closed then reopened, scan not updated
                      return ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        // scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: devices!.length,
                        itemBuilder: (context, index) {
                          return Card(
                            child: InkWell(
                              onTap: () {
                                final device = context.read<BLEDevice>();

                                device.connectDevice(devices[index]);
                              },
                              child: ListTile(
                                title: Text(devices[index].device.advName),
                              ),
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
      } else {
        return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.pinkAccent,
              title: Text(value.device!.device.advName),
            ),
            body: Column(
              children: [
                ElevatedButton(
                    onPressed: () {
                      final device = context.read<BLEDevice>();
                      device.disconnectDevice();
                    },
                    child: const Text("Back")),
                TextField(
                  onSubmitted: (str) async {
                    var id = value.dev!;
                    BluetoothCharacteristic name = BluetoothCharacteristic(
                        remoteId: id,
                        serviceUuid: service,
                        characteristicUuid: namerid);
                    for (var char in str.characters) {
                      await name.write(utf8.encode(char));
                    }

                    await name.write([00]);
                  },
                ),
                Container(
                  height: 400,
                  child: SingleChildScrollView(
                    child: MaterialPicker(
                        pickerColor: light,

                        // colorPickerWidth: 50,
                        // enableAlpha: false,
                        onColorChanged: (Color c) {
                          light = c;
                        }),
                  ),
                ),
                ElevatedButton(
                    onPressed: () async {
                      var id = value.dev!;
                      print(value.dev);
                      print(value.dev == null);
                      BluetoothCharacteristic r = BluetoothCharacteristic(
                          remoteId: id,
                          serviceUuid: service,
                          characteristicUuid: red);
                      BluetoothCharacteristic g = BluetoothCharacteristic(
                          remoteId: id,
                          serviceUuid: service,
                          characteristicUuid: green);
                      BluetoothCharacteristic b = BluetoothCharacteristic(
                          remoteId: id,
                          serviceUuid: service,
                          characteristicUuid: blue);

                      await r.write([light.red]);
                      await g.write([light.green]);
                      await b.write([light.blue]);
                    },
                    child: const Text("Send")),
                const Text("Test"),
              ],
            ));
      }
    });
  }
}
