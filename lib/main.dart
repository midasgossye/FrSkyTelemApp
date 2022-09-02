import 'dart:math';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_tts/flutter_tts.dart';

import './btsetup.dart';
import './settings.dart';
import './telempages/batpage.dart';
import './telempages/altpage.dart';


void main() {
  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (context) => DashboardScreen(),
      '/btsetup': (context) => BtSetupScreen(),
      '/settings': (context) => SettingsScreen(),
    },
  ));
}

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  BluetoothDevice _information;
  num _batvoltage = 0.0;
  num _RSSIlevel = 0.0;
  num _altitude = 0.0;
  num _vvival = 0.0;
  String asciidata = '';
  bool _btconnected = false;
  bool _showconnection = false;
  FlutterTts flutterTts = FlutterTts();


  void updateInformation(BluetoothDevice information) {
    setState(() => _information = information);
    flutterTts.speak("Connected");
    connectBtDevice(information);
  }

  void updateBTconnectedstatus(bool btconnected) {
    setState(() {
      _btconnected = btconnected;
    });
  }

  void updateRSSI(num RSSIlevel) {
    setState(() {
      _RSSIlevel = RSSIlevel;
    });
  }

  void updateBAT(num BATlevel) {
    setState(() {
      _batvoltage = BATlevel;
    });
  }

  void handleTimeout() {
    flutterTts.speak("No telemetry connection");
    setState(() {
      _showconnection = false;
    });
  }

  void processSPort(var msg, var iconTimer) {
    String sensorId;
    String raw_DATA_ID_1;
    String raw_DATA_ID_2;
    String DATA_ID;
    String raw_DATA = '';
    double RSSI_level = 0.0;
    double BAT_level = 0.0;
    double alt = 0.0;
    double vvi = 0.0;

    if (msg.length > 4 && msg.startsWith('7e')) {
      //print(msg);
      setState(() {
        _showconnection = true;
      });
      iconTimer.reset();
      //toggleConnectionTimer();
      sensorId = msg.substring(2, 4);
      if (sensorId == '98' && msg.substring(4, 6) == '10') {
        // Data from XJT module containing RSSI & SWR
        raw_DATA_ID_1 = msg.substring(6, 8);
        raw_DATA_ID_2 = msg.substring(8, 10);
        DATA_ID = '$raw_DATA_ID_2$raw_DATA_ID_1';

        if (DATA_ID == 'f101') {
          for (var i = 16; i >= 10; i -= 2) {
            var tmp_DATA = msg.substring(i, i + 2);
            raw_DATA = '$raw_DATA$tmp_DATA';
          }

          RSSI_level = int.parse(raw_DATA, radix: 16).toDouble();
          print('RSSI: $RSSI_level');
          updateRSSI(RSSI_level);
        }
        if (DATA_ID == 'f104') {
          for (var i = 16; i >= 10; i -= 2) {
            var tmp_DATA = msg.substring(i, i + 2);
            raw_DATA = '$raw_DATA$tmp_DATA';
          }
          BAT_level = int.parse(raw_DATA, radix: 16).toDouble();
          print('BAT: $BAT_level');
          updateBAT(BAT_level * (5 / 255));
        }
      }

      if (sensorId == '00' && msg.substring(4, 6) == '10') {
        // Data from Vario sensor
        raw_DATA_ID_1 = msg.substring(6, 8);
        raw_DATA_ID_2 = msg.substring(8, 10);
        DATA_ID = '$raw_DATA_ID_2$raw_DATA_ID_1';
        print('Got DATA ID $DATA_ID from alt sen');
        print(msg);
        if (DATA_ID == '0100') {
          for (var i = 16; i >= 10; i -= 2) {
            var tmp_DATA = msg.substring(i, i + 2);
            raw_DATA = '$raw_DATA$tmp_DATA';
          }

          var tmp_byte = hex.decode(raw_DATA);
          var tmp_BYTEDATA = ByteData(4);
          var ByteOffset = 0;
          for(var BYTE in tmp_byte) {
            tmp_BYTEDATA.setUint8(ByteOffset++, BYTE);
          }

          setState(() {
            _altitude = tmp_BYTEDATA.getInt32(0)*0.01;
          });
          //alt = int.parse(raw_DATA, radix: 16).toDouble();
          //print('alt: $alt');

        }
        if (DATA_ID == '0110') {
          for (var i = 16; i >= 10; i -= 2) {
            var tmp_DATA = msg.substring(i, i + 2);
            raw_DATA = '$raw_DATA$tmp_DATA';
          }
          var tmp_byte = hex.decode(raw_DATA);
          var tmp_BYTEDATA = ByteData(4);
          var ByteOffset = 0;
          for(var BYTE in tmp_byte) {
            tmp_BYTEDATA.setUint8(ByteOffset++, BYTE);
          }

          setState(() {
            _vvival = tmp_BYTEDATA.getInt32(0)*0.01;
          });

        }
      }

    }
  }

  void connectBtDevice(BluetoothDevice btdevice) async {
    String buffer = '';
    var iconTimer = RestartableTimer(Duration(milliseconds: 500), handleTimeout);
    //var ttsTimer = RestartableTimer(Duration(seconds: 30), handleTTS);

    var SPort_messages = [];
    try {
      BluetoothConnection connection =
          await BluetoothConnection.toAddress(btdevice.address);
      print('Connected to the device');
      updateBTconnectedstatus(true);

      connection.input.listen((Uint8List data) {
        buffer += hex.encode(data);
        if (buffer.length > 100) {
          SPort_messages = buffer.split(RegExp(r"(\7e+)*(?=7e)"));
          buffer = '';

          SPort_messages.forEach((msg) => processSPort(msg, iconTimer));
        }

        //connection.output.add(data); // Sending data
      }).onDone(() {
        updateBTconnectedstatus(false);
        print('Disconnected by remote request');
      });
    } catch (exception) {
      updateBTconnectedstatus(false);
      print('Cannot connect, exception occured');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.settings_bluetooth),
          onPressed: () async {
            // Add your onPressed code here!
            final information = await Navigator.pushNamed(context, '/btsetup');
            updateInformation(information);
          },
        ),
        appBar: AppBar(
          title: Text('Telemetry Dashboard'),
          backgroundColor: Colors.indigo,
          actions: <Widget>[
            Visibility(
                visible: _showconnection,
                replacement: Icon(
                  Icons.compare_arrows,
                color: Colors.black12,
                ),
                child: Icon(Icons.compare_arrows, color: Colors.green)
            ),
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () async {
                await Navigator.pushNamed(context, '/settings');
              },
            ),
          ],
          bottom: TabBar(tabs: [
            Tab(icon: Icon(Icons.battery_unknown)),
            Tab(icon: Icon(Icons.satellite))
          ]),
        ),
        body: TabBarView(children: [
          BatPage(
            batvoltage: _batvoltage,
            rssilevel: _RSSIlevel,
            btinformation: _information,
            btconnected: _btconnected,
          ),
          AltPage(
            altitude: _altitude,
            vvi_value: _vvival,
            rssilevel: _RSSIlevel,
            btinformation: _information,
            btconnected: _btconnected,
          )
        ]),
      ),
    );
  }
}
