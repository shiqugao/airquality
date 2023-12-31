import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:convert';

class FolderListScreenAnalysis extends StatefulWidget {
  @override
  _FolderListScreenAnalysisState createState() =>
      _FolderListScreenAnalysisState();
}

class _FolderListScreenAnalysisState extends State<FolderListScreenAnalysis> {
  List<String> folders = [];

  @override
  void initState() {
    super.initState();
    fetchFolders().then((folderList) {
      setState(() {
        folders = folderList.toList(); // Reverse the order of folders
      });
    });
  }

  Future<List<String>> fetchFolders() async {
    List<String> folders = [];

    DateTime currentDate = DateTime.now();
    DateTime startDate = DateTime(2023, 7, 25); // Replace with your desired start date

    while (startDate.isBefore(currentDate)) {
      String folderName = DateFormat('yyyy-MM-dd').format(startDate);
      folders.add(folderName);
      startDate = startDate.add(Duration(days: 1));
    }

    print(folders);
    return folders;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(0),
        child: SizedBox(
          height: 800.0,
          child: Stack(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                  top: 120,
                ),
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: folders.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Card(
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: InkWell(
                          onTap: () {
                            String folderName = folders[index];

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    SingleDeviceGraph(folderName: folderName),
                              ),
                            );
                          },
                          child: ListTile(
                            leading: Icon(Icons.folder),
                            title: Text(
                              folders[index],
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Icon(Icons.arrow_forward),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(
                height: MediaQuery.of(context).padding.bottom,
              ),
            ],
          ),
        ),
      ),

    );
  }}

class DeviceData {
  final String date;
  final int PM1;
  final int PM25;
  final int PM10;
  final double temperature;
  final double humidity;

  DeviceData({
    required this.date,
    required this.PM1,
    required this.PM25,
    required this.PM10,
    required this.temperature,
    required this.humidity,
  });
}

class SingleDeviceGraph extends StatefulWidget {
  final String folderName;

  const SingleDeviceGraph({Key? key, required this.folderName})
      : super(key: key);

  @override
  _SingleDeviceGraphState createState() => _SingleDeviceGraphState();
}

class _SingleDeviceGraphState extends State<SingleDeviceGraph> {
  List<DeviceData> _data = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    print(widget.folderName.toString().substring(0, 8));
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection(
        widget.folderName.toString().substring(0, 10))
        .get();
    List<DeviceData> data = [];
    snapshot.docs.forEach((doc) {
String date=doc.id;
      Map<String, dynamic>? docData = doc.data() as Map<String, dynamic>?;

      if (docData != null) {
        String p = docData['p'] as String;

        Map<String, dynamic> jsonData = jsonDecode(p);

        int pm1 = jsonData['PM1'];
        int pm25 = jsonData['PM2.5'];
        int pm10 = jsonData['PM10'];
        int mq135SensorValue = jsonData['MQ135_SensorValue'];
        double mq135Voltage = jsonData['MQ135_Voltage'];
        double mq135PPM = jsonData['MQ135_PPM'];
        double temperature = jsonData['Temperature'];
        double humidity = jsonData['Humidity'];
        double pressure = jsonData['Pressure'];

        print('PM1: $pm1');
        print('PM2.5: $pm25');
        print('PM10: $pm10');
        print('MQ135 Sensor Value: $mq135SensorValue');
        print('MQ135 Voltage: $mq135Voltage');
        print('MQ135 PPM: $mq135PPM');
        print('Temperature: $temperature');
        print('Humidity: $humidity');
        print('Pressure: $pressure');

        data.add(
          DeviceData(
          date: date,
          PM1: pm1,
          PM25: pm25,
          PM10: pm10,
          temperature: temperature,
          humidity: humidity,
          ),
        );
      }
    });
    setState(() {
      _data = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body:
          SingleChildScrollView(
        child: Column(
          children: [
            _buildGraph(
                _data, 'Temperature', Colors.red, 'temperature'),
            _buildGraph(
                _data, 'Humidity', Colors.lightBlue, 'humidity'),
            _buildGraph(_data, 'PM1', Colors.orange, 'PM1'),
            _buildGraph(
                _data, 'PM2.5', Colors.blue, 'PM25'),
            _buildGraph(
                _data, 'PM10', Colors.blue, 'PM10'),
            SizedBox(
              height: MediaQuery.of(context).padding.bottom,
            ),
          ],
        ),
      ),

    );
  }

  Widget _buildGraph(List<DeviceData> data, String variable, Color color,
      String propertyName) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            offset: Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '$variable',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 16),
            Container(
              height: 300,
              child: SfCartesianChart(
                plotAreaBorderWidth: 0,
                primaryXAxis: CategoryAxis(
                  labelRotation: 45,
                  labelStyle: TextStyle(
                    color: Colors.black87,
                  ),
                  majorGridLines: MajorGridLines(
                    width: 0,
                  ),
                ),
                primaryYAxis: NumericAxis(
                  title: null,
                  labelStyle: TextStyle(
                    color: Colors.black87,
                  ),
                  majorGridLines: MajorGridLines(
                    width: 1,
                    color: Colors.grey.withOpacity(0.2),
                  ),
                  axisLine: AxisLine(
                    color: Colors.grey.withOpacity(0.4),
                  ),
                  numberFormat: NumberFormat.decimalPattern(),
                ),
                series: _createSeries(data, variable, color),
                trackballBehavior: TrackballBehavior(
                  enable: true,
                  activationMode: ActivationMode.singleTap,
                  tooltipSettings: InteractiveTooltip(
                    enable: true,
                    color: Colors.white,
                    textStyle: TextStyle(
                      color: Colors.black87,
                    ),
                    format: 'Time: point.x ; Value: point.y',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  List<LineSeries<DeviceData, String>> _createSeries(
      List<DeviceData> data, String variable, Color color) {
    data.sort((a, b) => a.date.compareTo(b.date));
    return [
      LineSeries<DeviceData, String>(
        dataSource: data,
        xValueMapper: (DeviceData data, _) => data.date,
        yValueMapper: (DeviceData data, _) {
          switch (variable) {
            case 'PM1':
              return data.PM1;
            case 'PM10':
              return data.PM10;
            case 'Humidity':
              return data.humidity;
            case 'Temperature':
              return data.temperature;
            case 'PM2.5':
              return data.PM25;
            default:
              return 0.0;
          }
        },
        color: color,
        markerSettings: MarkerSettings(
          isVisible: true,
          width: 2, // Adjust the width of the data points
          height: 2, // Adjust the height of the data points
        ),
      ),
    ];
  }
 }