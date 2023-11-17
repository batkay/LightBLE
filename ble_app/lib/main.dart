import 'package:ble_app/Controllers/ble_controller.dart';
import 'package:ble_app/Views/about.dart';
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
      debugShowCheckedModeBanner: false,
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
  var notOn = 0;
  @override
  void initState() {
    super.initState();
    tryBLE();
  }

  void tryBLE() async {
// check if bluetooth is supported by your hardware
    // Note: The platform is initialized on the first call to any FlutterBluePlus method.
    if (await FlutterBluePlus.isSupported == false) {
      print("Bluetooth not supported by this device");
      setState(
        () {
          notOn = 3;
        },
      );
      return;
    }

    // handle bluetooth on & off
    // note: for iOS the initial state is typically BluetoothAdapterState.unknown
    // note: if you have permissions issues you will get stuck at BluetoothAdapterState.unauthorized
    FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
      if (state != BluetoothAdapterState.on) {
        // usually start scanning, connecting, etc
        print("ble not on");
        setState(() {
          notOn = 2;
        });
        return;
      } else {
        setState(() {
          notOn = 0;
        });
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
    Widget page;

    switch (notOn) {
      case 2:
        print("not on");
        return Scaffold(
            appBar: AppBar(
              title: const Text("Error"),
              backgroundColor: Colors.pink,
            ),
            body: SingleChildScrollView(
                child: Column(children: [
              Center(
                child: const Text("Bluetooth not on"),
              )

              // TextButton(onPressed: tryBLE, child: const Text("Try Again"))
            ])));
      case 3:
        return Scaffold(
            appBar: AppBar(
              title: const Text("Error"),
              backgroundColor: Colors.pink,
            ),
            body: SingleChildScrollView(
                child: Column(children: [
              Center(
                child: const Text("Bluetooth not supported"),
              )

              // TextButton(onPressed: tryBLE, child: const Text("Try Again"))
            ])));
    }
    switch (selectedIndex) {
      // can be null
      case 0:
        page = FindDevicePage();
        break;
      case 1:
        page = AboutPage(); // bluetooth is not on state
        break;

      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        backgroundColor: Colors.teal,
        body: Container(
            color: Theme.of(context).colorScheme.primaryContainer, child: page),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            const BottomNavigationBarItem(
                icon: const Icon(Icons.home), label: "Home"),
            const BottomNavigationBarItem(
                icon: const Icon(Icons.info), label: "Info")
          ],
          currentIndex: selectedIndex,
          onTap: (value) {
            setState(() => selectedIndex = value);
            print(value);
          },
        ),
      );
    });
    // return LayoutBuilder(builder: (context, constraints) {
    //   return Scaffold(
    //     backgroundColor: Colors.teal,
    //     body: Row(children: [
    //       SafeArea(
    //           child: NavigationRail(
    //         backgroundColor: Colors.teal,
    //         extended: constraints.maxWidth >= 1000,
    //         destinations: [
    //           const NavigationRailDestination(
    //               icon: const Icon(Icons.home), label: const Text("Home")),
    //           const NavigationRailDestination(
    //               icon: const Icon(Icons.info), label: const Text("Info"))
    //         ],
    //         selectedIndex: selectedIndex,
    //         onDestinationSelected: (value) {
    //           setState(() => selectedIndex = value);
    //           print(value);
    //         },
    //       )),
    //       Expanded(
    //         child: Container(
    //             color: Theme.of(context).colorScheme.primaryContainer,
    //             child: page),
    //       )
    //     ]),
    //   );
    // });
  }
}
