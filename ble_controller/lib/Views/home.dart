import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

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
                  return ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    // scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: devices!.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          title: Text(devices![index].device.advName),
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
