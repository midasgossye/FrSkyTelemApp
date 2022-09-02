import 'package:async/async.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Colors.indigo,
      ),
      body: Column(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.info),
            title: Text("App info"),
            onTap: (){
              showAboutDialog(
                  context: context,
                applicationVersion: '0.0.2',
                applicationName: 'FrSky Telemetry Dashboard',
                applicationLegalese: 'This app is not endorsed or maintained by FrSky. Absolutely NO warranty is given!'
              );
            },
          )
        ],
      ),
    );
  }
}
