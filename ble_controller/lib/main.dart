import 'package:ble_controller/Controllers/ble_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import 'Views/home.dart';
import 'dart:io' show Platform;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    print("Starting");
    return MaterialApp(
      title: 'Lightstick Companion',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: ChangeNotifierProvider(
          create: (context) => BLEDevice(),
          child: Consumer<BLEDevice>(
            builder: (context, value, child) => MyHomePage(),
          )),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget page;

    // check if bluetooth is supported by your hardware
    // Note: The platform is initialized on the first call to any FlutterBluePlus method.
    if (FlutterBluePlus.isSupported == false) {
      print("Bluetooth not supported by this device");
      return Placeholder();
    }

    // handle bluetooth on & off
    // note: for iOS the initial state is typically BluetoothAdapterState.unknown
    // note: if you have permissions issues you will get stuck at BluetoothAdapterState.unauthorized
    FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
      if (state != BluetoothAdapterState.on) {
        // usually start scanning, connecting, etc
        selectedIndex = 2;
      }
    });

    // turn on bluetooth ourself if we can
    // for iOS, the user controls bluetooth enable/disable
    if (Platform.isAndroid) {
      FlutterBluePlus.turnOn();
    }

    switch (selectedIndex) {
      // can be null
      case 0:
        page = FindDevicePage();
        break;
      case 1:
        page = Placeholder(); // bluetooth is not on state
        break;
      case 2:
        page = Placeholder();
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(children: [
          SafeArea(
              child: NavigationRail(
            extended: constraints.maxWidth >= 600,
            destinations: [
              const NavigationRailDestination(
                  icon: const Icon(Icons.home), label: const Text("Home")),
              const NavigationRailDestination(
                  icon: const Icon(Icons.info), label: const Text("Info"))
            ],
            selectedIndex: selectedIndex,
            onDestinationSelected: (value) {
              setState(() => selectedIndex = value);
              print(value);
            },
          )),
          Expanded(
            child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page),
          )
        ]),
      );
    });
  }
}
