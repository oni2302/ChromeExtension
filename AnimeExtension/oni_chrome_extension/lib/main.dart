import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart'; // Import IO WebSocket channel

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyWebSocketApp(),
    );
  }
}

class MyWebSocketApp extends StatefulWidget {
  @override
  _MyWebSocketAppState createState() => _MyWebSocketAppState();
}

class _MyWebSocketAppState extends State<MyWebSocketApp> {
  final channel = IOWebSocketChannel.connect('ws://localhost:8080');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WebSocket Example'),
      ),
      body: StreamBuilder(
        stream: channel.stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.hasData) {
            return Text('Received: ${snapshot.data}');
          }

          return Row(
            children: [
              CircularProgressIndicator(),
              IconButton(
                onPressed: () {
                  channel.sink.add('01h32lgxenr7zdq8ar7dhao|prev');
                },
                // Gửi dữ liệu qua WebSocket
                icon: const Icon(Icons.skip_previous),
              ),
              IconButton(
                onPressed: () {
                  channel.sink.add('01h32lgxenr7zdq8ar7dhao|playpause');
                },
                // Gửi dữ liệu qua WebSocket
                icon: const Icon(Icons.play_arrow),
              ),
              IconButton(
                onPressed: () {
                  channel.sink.add('01h32lgxenr7zdq8ar7dhao|next');
                },
                // Gửi dữ liệu qua WebSocket
                icon: const Icon(Icons.skip_next),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    channel.sink.close(); // Đóng kết nối WebSocket khi ứng dụng kết thúc
    super.dispose();
  }
}
