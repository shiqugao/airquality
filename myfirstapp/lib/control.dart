import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'dart:convert';

const String username = 'student';
const String password = 'ce2021-mqtt-forget-whale';
final client = MqttServerClient('mqtt.cetools.org', '11');

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