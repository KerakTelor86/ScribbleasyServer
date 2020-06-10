import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Server/server.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Scribbleasy Server',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Scribbleasy Server'),
        ),
        body: Center(
          child: Config(),
        ),
      ),
    );
  }
}

class Config extends StatefulWidget {
  @override
  ConfigState createState() => ConfigState();
}

class ConfigState extends State<Config> {
  int maxUsers;
  int maxSessions;
  String ip;
  int port;
  Server sv;
  bool running = false;

  void startServer() {
    if (running) {
      return;
    }
    sv = Server(maxUsers, maxSessions);
    sv.start(ip, port);
    running = true;
  }

  void stopServer() {
    if (running) {
      sv.stop();
      running = false;
      exit(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxUsersField = TextField(
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Max users',
      ),
      onChanged: (str) {
        maxUsers = int.parse(str);
      },
    );
    final maxSessionsField = TextField(
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Max sessions',
      ),
      onChanged: (str) {
        maxSessions = int.parse(str);
      },
    );
    final ipField = TextField(
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'IP address',
      ),
      onChanged: (str) {
        ip = str;
      },
    );
    final portField = TextField(
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Port',
      ),
      onChanged: (str) {
        port = int.parse(str);
      },
    );
    final startButton = RaisedButton(
      onPressed: () => startServer(),
      child: Text('Start server'),
    );
    final stopButton = RaisedButton(
      onPressed: () => stopServer(),
      child: Text('Stop and exit'),
    );
    return Row(
      children: <Widget>[
        Expanded(
          flex: 2,
          child: Container(),
        ),
        Expanded(
          flex: 6,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              maxUsersField,
              SizedBox(height: 10),
              maxSessionsField,
              SizedBox(height: 10),
              ipField,
              SizedBox(height: 10),
              portField,
              SizedBox(height: 10),
              startButton,
              stopButton,
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(),
        ),
      ],
    );
  }
}
