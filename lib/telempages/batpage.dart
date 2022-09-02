import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:customgauge/customgauge.dart';
import '../btconnstatus.dart';

class BatPage extends StatelessWidget {
  num rssilevel;
  num batvoltage;
  BluetoothDevice btinformation;
  bool btconnected;

  BatPage({this.rssilevel, this.batvoltage, this.btinformation, this.btconnected});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          BtConnectStatus(btinformation: btinformation, btconnected: btconnected),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CustomGauge(
                gaugeSize: 200,
                currentValue: batvoltage,
                minValue: 9.0,
                maxValue: 12.6,
                showMarkers: true,
                segments: [
                  GaugeSegment('Low', 2.1, Colors.red, 135.0),
                  GaugeSegment('Medium', 0.3, Colors.orange, 135.0),
                  GaugeSegment('High', 1.2, Colors.green, 135.0),
                ],
                valueWidget: Text('${batvoltage.toStringAsFixed(1)}',
                    style: TextStyle(
                        fontFamily: 'SevenSegment', fontSize: 25)),
                displayWidget:
                Text('Voltage', style: TextStyle(fontSize: 20)),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CustomGauge(
                gaugeSize: 200,
                currentValue: rssilevel,
                minValue: 0,
                maxValue: 100,
                showMarkers: true,
                segments: [
                  GaugeSegment('Low', 40, Colors.red, 135.0),
                  GaugeSegment('Medium', 20, Colors.orange, 135.0),
                  GaugeSegment('High', 40, Colors.green, 135.0),
                ],
                valueWidget: Text('${rssilevel.toStringAsFixed(0)}',
                    style: TextStyle(
                        fontFamily: 'SevenSegment', fontSize: 25)),
                displayWidget:
                Text('RSSI', style: TextStyle(fontSize: 20)),
              ),
            ],
          )
        ],
      ),
    );
  }
}
