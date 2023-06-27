// import 'package:flutter/material.dart';
// import 'package:mqtt_client/mqtt_client.dart';
// import 'package:mqtt_client/mqtt_server_client.dart';
// import 'dart:convert';
// import 'package:concentric_transition/concentric_transition.dart';
//
// const String username = 'student';
// const String password = 'ce2021-mqtt-forget-whale';
// final client = MqttServerClient('mqtt.cetools.org', '11');
//
// class PageData {
//   final String? title;
//   final IconData? icon;
//   final Color bgColor;
//   final Color textColor;
//
//   const PageData({
//     this.title,
//     this.icon,
//     this.bgColor = Colors.white,
//     this.textColor = Colors.black,
//   });
// }
//
// class User {
//   int PM1;
//   int PM25;
//   int PM10;
//
//   User(this.PM1, this.PM25, this.PM10);
//
//   factory User.fromJson(dynamic json) {
//     return User(
//       json['PM1'] as int,
//       json['PM2.5'] as int,
//       json['PM10'] as int,
//     );
//   }
//
//   @override
//   String toString() {
//     return '{ ${this.PM1}, ${this.PM25}, ${this.PM10} }';
//   }
// }
//
// class PMPage extends StatefulWidget {
//   @override
//   _PMPageState createState() => _PMPageState();
// }
//
// class _PMPageState extends State<PMPage> {
//   int PM1 = 0;
//   int PM25 = 0;
//   int PM10 = 0;
//
//   PMSection selectedSection = PMSection.PM1;
//
//   @override
//   void initState() {
//     super.initState();
//     startMQTT();
//   }
//
//   @override
//   void dispose() {
//     client.disconnect();
//     super.dispose();
//   }
//
//   Future<void> startMQTT() async {
//     client.port = 1884;
//     client.setProtocolV311();
//     client.keepAlivePeriod = 10;
//
//     try {
//       await client.connect(username, password);
//     } catch (e) {
//       print('client exception - $e');
//       client.disconnect();
//     }
//
//     if (client.connectionStatus!.state == MqttConnectionState.connected) {
//       print('Mosquitto client connected');
//     } else {
//       print(
//           'ERROR Mosquitto client connection failed - disconnecting, state is ${client.connectionStatus!.state}');
//       client.disconnect();
//     }
//
//     const topic1 = 'student/ucfnaob/AirQuality';
//     client.subscribe(topic1, MqttQos.atMostOnce);
//
//     client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
//       final receivedMessage = c![0].payload as MqttPublishMessage;
//       final messageString =
//       MqttPublishPayload.bytesToStringAsString(receivedMessage.payload.message);
//       User convert = User.fromJson(jsonDecode(messageString));
//
//       if (c[0].topic == topic1) {
//         print('Change notification:: topic is <${c[0].topic}>, payload is <-- $convert -->');
//         setState(() {
//           PM1 = convert.PM1;
//           PM25 = convert.PM25;
//           PM10 = convert.PM10;
//         });
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final screenHeight = MediaQuery.of(context).size.height;
//     final pages = [
//       PageData(
//         icon: Icons.food_bank_outlined,
//         title: "PM1: $PM1",
//         bgColor: Color(0xff3b1791),
//         textColor: Colors.white,
//       ),
//       PageData(
//         icon: Icons.shopping_bag_outlined,
//         title: "PM2.5: $PM25",
//         bgColor: Color(0xfffab800),
//         textColor: Color(0xff3b1790),
//       ),
//       PageData(
//         icon: Icons.delivery_dining,
//         title: "PM10: $PM10",
//         bgColor: Color(0xffffffff),
//         textColor: Color(0xff3b1790),
//       ),
//     ];
//
//     return ConcentricAnimationOnboarding(pages: pages);
//   }
// }
//
// class ConcentricAnimationOnboarding extends StatelessWidget {
//   final List<PageData> pages;
//
//   const ConcentricAnimationOnboarding({Key? key, required this.pages}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     return Scaffold(
//       body: ConcentricPageView(
//         colors: pages.map((p) => p.bgColor).toList(),
//         radius: screenWidth * 0.1,
//         nextButtonBuilder: (context) => Padding(
//           padding: const EdgeInsets.only(left: 3), // visual center
//           child: Icon(
//             Icons.navigate_next,
//             size: screenWidth * 0.08,
//           ),
//         ),
//         itemCount: pages.length,
//         itemBuilder: (index) {
//           final page = pages[index % pages.length];
//           return SafeArea(
//             child: _Page(page: page),
//           );
//         },
//       ),
//     );
//   }
// }
//
// enum PMSection {
//   PM1,
//   PM25,
//   PM10,
// }
//
// class _Page extends StatelessWidget {
//   final PageData page;
//
//   const _Page({Key? key, required this.page}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final screenHeight = MediaQuery.of(context).size.height;
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Container(
//           padding: const EdgeInsets.all(16.0),
//           margin: const EdgeInsets.all(16.0),
//           decoration: BoxDecoration(shape: BoxShape.circle, color: page.textColor),
//           child: Icon(
//             page.icon,
//             size: screenHeight * 0.1,
//             color: page.bgColor,
//           ),
//         ),
//         Text(
//           page.title ?? "",
//           style: TextStyle(
//               color: page.textColor,
//               fontSize: screenHeight * 0.035,
//               fontWeight: FontWeight.bold),
//           textAlign: TextAlign.center,
//         ),
//       ],
//     );
//   }
// }
//
// void main() {
//   runApp(MaterialApp(
//     home: PMPage(),
//   ));
// }
//

import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'dart:convert';
import 'package:concentric_transition/concentric_transition.dart';
import 'secrets.dart';

final client = MqttServerClient('mqtt.cetools.org', '11');

class PageData {
  final String? title;
  final IconData? icon;
  final Color bgColor;
  final Color textColor;

  const PageData({
    this.title,
    this.icon,
    this.bgColor = Colors.white,
    this.textColor = Colors.black,
  });
}

class User {
  int PM1;
  int PM25;
  int PM10;

  User(this.PM1, this.PM25, this.PM10);

  factory User.fromJson(dynamic json) {
    return User(
      json['PM1'] as int,
      json['PM2.5'] as int,
      json['PM10'] as int,
    );
  }

  @override
  String toString() {
    return '{ ${this.PM1}, ${this.PM25}, ${this.PM10} }';
  }
}

class PMPage extends StatefulWidget {
  @override
  _PMPageState createState() => _PMPageState();
}

class _PMPageState extends State<PMPage> {
  int PM1 = 0;
  int PM25 = 0;
  int PM10 = 0;

  PMSection selectedSection = PMSection.PM1;

  @override
  void initState() {
    super.initState();
    startMQTT();
  }

  @override
  void dispose() {
    client.disconnect();
    super.dispose();
  }

  Future<void> startMQTT() async {
    client.port = 1884;
    client.setProtocolV311();
    client.keepAlivePeriod = 10;

    try {
      await client.connect(username, password);
    } catch (e) {
      print('client exception - $e');
      client.disconnect();
    }

    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print('Mosquitto client connected');
    } else {
      print(
          'ERROR Mosquitto client connection failed - disconnecting, state is ${client.connectionStatus!.state}');
      client.disconnect();
    }

    const topic1 = 'student/ucfnaob/AirQuality';
    client.subscribe(topic1, MqttQos.atMostOnce);

    client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final receivedMessage = c![0].payload as MqttPublishMessage;
      final messageString =
      MqttPublishPayload.bytesToStringAsString(receivedMessage.payload.message);
      User convert = User.fromJson(jsonDecode(messageString));

      if (c[0].topic == topic1) {
        print('Change notification:: topic is <${c[0].topic}>, payload is <-- $convert -->');
        setState(() {
          PM1 = convert.PM1;
          PM25 = convert.PM25;
          PM10 = convert.PM10;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final pages = [
      PageData(
        icon: Icons.cloud_outlined, // Use cloud icon for PM1
        title: "PM1: $PM1",
        bgColor: Color(0xff3b1791),
        textColor: Colors.white,
      ),
      PageData(
        icon: Icons.cloud_queue_outlined, // Use cloud queue icon for PM2.5
        title: "PM2.5: $PM25",
        bgColor: Color(0xfffab800),
        textColor: Color(0xff3b1790),
      ),
      PageData(
        icon: Icons.cloud_sharp, // Use cloud icon for PM10
        title: "PM10: $PM10",
        bgColor: Color(0xffffffff),
        textColor: Color(0xff3b1790),
      ),
    ];

    return ConcentricAnimationOnboarding(pages: pages);
  }
}

class ConcentricAnimationOnboarding extends StatelessWidget {
  final List<PageData> pages;

  const ConcentricAnimationOnboarding({Key? key, required this.pages}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: ConcentricPageView(
        colors: pages.map((p) => p.bgColor).toList(),
        radius: screenWidth * 0.1,
        nextButtonBuilder: (context) => Padding(
          padding: const EdgeInsets.only(left: 3), // visual center
          child: Icon(
            Icons.navigate_next,
            size: screenWidth * 0.08,
          ),
        ),
        itemCount: pages.length,
        itemBuilder: (index) {
          final page = pages[index % pages.length];
          return SafeArea(
            child: _Page(page: page),
          );
        },
      ),
    );
  }
}

enum PMSection {
  PM1,
  PM25,
  PM10,
}

class _Page extends StatelessWidget {
  final PageData page;

  const _Page({Key? key, required this.page}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          margin: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(shape: BoxShape.circle, color: page.textColor),
          child: Icon(
            page.icon,
            size: screenHeight * 0.1,
            color: page.bgColor,
          ),
        ),
        Text(
          page.title ?? "",
          style: TextStyle(
              color: page.textColor,
              fontSize: screenHeight * 0.035,
              fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: PMPage(),
  ));
}
