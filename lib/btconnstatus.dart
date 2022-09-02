import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BtConnectStatus extends StatelessWidget {
  bool btconnected;
  BluetoothDevice btinformation;
  String btstatustext;

  BtConnectStatus({this.btconnected, this.btinformation});


  @override
  Widget build(BuildContext context) {
    if(!btconnected && btinformation != null) {
      if(btinformation.isBonded) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Connecting to ${btinformation.name} '),
            CircularProgressIndicator(
            ),
          ],
        );
      }
    }
    else {
      return btinformation != null
          ? Text('Connected device: ${btinformation.name}')
          : Text('No device selected');
    }
  }
}
