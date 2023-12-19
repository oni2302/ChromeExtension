import 'package:flutter/material.dart';
import 'package:manga/main.dart';
import 'package:manga/qr.dart';
import 'package:web_socket_channel/io.dart';

// ignore: must_be_immutable
class Remote extends StatefulWidget {
  static late int scroll;
  static late int speed;
  final Function(int index) callback;
  // ignore: prefer_typing_uninitialized_variables
  static var channel;
  const Remote(this.callback, {super.key});
  @override
  // ignore: library_private_types_in_public_api
  _RemoteState createState() => _RemoteState();
}

class _RemoteState extends State<Remote> {
  double verticalDragStart = 0.0;
  DateTime lastUpTime = DateTime.now();
  DateTime lastDownTime = DateTime.now();
  // Controller for the TextField
  TextEditingController scrollController = TextEditingController();
  TextEditingController speedController = TextEditingController();
  void jumpToQR() {
    MangaApp.pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.ease,
    );
    widget.callback(0);
  }

  ButtonStyle getButtonStyle() {
    return ButtonStyle(
      backgroundColor: MaterialStateColor.resolveWith(
          (states) => const Color.fromARGB(255, 209, 174, 255)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (Remote.channel == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Quét mã trên Extension để kết nối",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color.fromARGB(255, 173, 96, 7)),
            ),
            ElevatedButton(
              style: getButtonStyle(),
              onPressed: jumpToQR,
              child: const Text("Quay lại quét mã"),
            ),
          ],
        ),
      );
    }
// Tạo một Border với màu tím nhạt
    final purpleBorder = Border.all(
      color: Colors.purpleAccent,
      width: 2.0, // Điều chỉnh độ dày của viền
    );
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Sliders and TextField for scroll and speed values
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text('Scroll: ${Remote.scroll}'),
                    Slider(
                      value: Remote.scroll.toDouble(),
                      min: 0,
                      max: 1000, // Adjust the max value as needed
                      onChanged: (value) {
                        MangaApp.data.setInt("scroll", value.toInt());
                        setState(() {
                          Remote.scroll = value.toInt();
                          // Update the TextField value as well
                          scrollController.text = Remote.scroll.toString();
                        });
                      },
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text('Speed: ${Remote.speed}'),
                    Slider(
                      value: Remote.speed.toDouble(),
                      min: 0,
                      max: 1000, // Adjust the max value as needed
                      onChanged: (value) {
                        MangaApp.data.setInt("speed", value.toInt());
                        setState(() {
                          Remote.speed = value.toInt();
                          // Update the TextField value as well
                          speedController.text = Remote.speed.toString();
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
            // TextField for scroll and speed values
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Scroll: '),
                SizedBox(
                  width: 50,
                  child: TextField(
                    controller: scrollController,
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      MangaApp.data.setInt("scroll", int.parse(value));
                      setState(() {
                        Remote.scroll = int.tryParse(value) ?? 0;
                      });
                    },
                  ),
                ),
                const Text('Speed: '),
                SizedBox(
                  width: 50,
                  child: TextField(
                    controller: speedController,
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      MangaApp.data.setInt("speed", int.parse(value));
                      setState(() {
                        Remote.speed = int.tryParse(value) ?? 0;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: purpleBorder,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: IconButton(
                          onPressed: () {
                            SendRequest(
                              '{"action":"remote","to":"oni","command":"prev"}',
                            );
                          },
                          icon: const Icon(Icons.arrow_back),
                        ),
                      ),
                      const SizedBox(width: 30.0),
                      Container(
                        decoration: BoxDecoration(
                          border: purpleBorder,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: IconButton(
                          onPressed: () {
                            SendRequest(
                              '{"action":"remote","to":"oni","command":"next"}',
                            );
                          },
                          icon: const Icon(Icons.arrow_forward),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onVerticalDragStart: (details) {
                        verticalDragStart = details.localPosition.dy;
                      },
                      onVerticalDragUpdate: (details) {
                        final dy = details.localPosition.dy;
                        if (dy - verticalDragStart > 20) {
                          // Vuốt xuống
                          if (DateTime.now()
                                  .difference(lastUpTime)
                                  .inMilliseconds >
                              400) {
                            SendRequest(
                              '{"action":"remote","to":"oni","command":"up","scroll":${Remote.scroll},"speed":${Remote.speed}}',
                            );
                            lastUpTime = DateTime.now();
                          }
                        } else if (verticalDragStart - dy > 20) {
                          // Vuốt lên
                          if (DateTime.now()
                                  .difference(lastDownTime)
                                  .inMilliseconds >
                              400) {
                            SendRequest(
                              '{"action":"remote","to":"oni","command":"down","scroll":${Remote.scroll},"speed":${Remote.speed}}',
                            );
                            lastDownTime = DateTime.now();
                          }
                        }
                      },
                      child: Container(
                        color: const Color.fromARGB(255, 225, 207, 248),
                        child: const Center(
                          child: Icon(
                            Icons.swipe_vertical,
                            color: Color.fromARGB(255, 197, 197, 197),
                            size: 40.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  void SendRequest(request) {
    try {
      Remote.channel.sink.add(request);
    } catch (e) {
      Remote.channel = IOWebSocketChannel.connect("ws://${QRScanner.ip}:8080");
      try {
        Remote.channel.sink.add(request);
        // ignore: empty_catches
      } catch (e) {}
    }
  }

  @override
  void dispose() {
    if (Remote.channel != null) {
      Remote.channel.sink
          .close(); // Đóng kết nối WebSocket khi ứng dụng kết thúc
    }
    super.dispose();
  }
}
