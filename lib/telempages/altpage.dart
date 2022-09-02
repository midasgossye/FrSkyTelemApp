import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:customgauge/customgauge.dart';

import '../btconnstatus.dart';


class AltPage extends StatelessWidget {
  num rssilevel;
  num batvoltage;
  BluetoothDevice btinformation;
  bool btconnected;
  num altitude;
  num vvi_value;

  AltPage({this.rssilevel, this.altitude, this.vvi_value, this.btinformation, this.btconnected});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: <Widget>[
          CustomGauge(
            gaugeSize: 200,
            currentValue: altitude,
            minValue: 0,
            maxValue: 150,
            showMarkers: true,
            segments: [
              GaugeSegment('Low', 50, Colors.green, 135.0),
              GaugeSegment('Medium', 50, Colors.blue[900], 135.0),
              GaugeSegment('High', 50, Colors.lightBlue, 135.0),
            ],
            valueWidget: Text('${altitude.toStringAsFixed(1)}',
                style: TextStyle(
                    fontFamily: 'SevenSegment', fontSize: 25)),
            displayWidget:
            Text('Altitude [m]', style: TextStyle(fontSize: 20)),
          ),
          CustomGauge(
            gaugeSize: 200,
            currentValue: vvi_value,
            minValue: -5,
            maxValue: 5,
            showMarkers: true,
            gaugeAngle: 180.0,
            needleOffset: -45.0*(3.1415/180.0),
            segments: [
              GaugeSegment('Sink', 4.75, Colors.green, 90.0),
              GaugeSegment('Level', 0.5, Colors.blue[900], 90.0),
              GaugeSegment('Rise', 4.75, Colors.lightBlue, 90.0),
            ],
            valueWidget: Text('${vvi_value.toStringAsFixed(1)}',
                style: TextStyle(
                    fontFamily: 'SevenSegment', fontSize: 25)),
            displayWidget:
            Text('VVI [m/s]', style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );
  }
}
