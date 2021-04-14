import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;


class TestScreen extends StatefulWidget {
  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {  
  @override
  void initState() {
    super.initState();
    initSocket();
  }

  void initSocket() async {
    // Dart client
    IO.Socket socket = IO.io('http://192.168.1.7:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    socket.onConnect((_) {
      print('connect');
      socket.emit('msg', 'test');
    });
    socket.on('event', (data) => print(data));
    socket.onDisconnect((_) => print('disconnect'));
    socket.onConnectError((data) => print(data));
    socket.onConnectTimeout((data) => print(data));
    socket.onError((data) => print(data));
    socket.on('fromServer', (_) => print(_));
    socket.connect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.red
      ),
    );
  }
}