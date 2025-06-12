import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:overlay_support/overlay_support.dart';

void main() {
  runApp(const OverlaySupport.global(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final PusherChannelsFlutter _pusher = PusherChannelsFlutter.getInstance();
  PusherChannel? _channel;
  String _status = 'Initializing...';

  @override
  void initState() {
    super.initState();
    _initPusher();
  }

  Future<void> _initPusher() async {
    try {
      await _pusher.init(
        apiKey: 'b8770a30b5b2f23ff5c3',
        cluster: 'ap2',
        onConnectionStateChange: (state, _) {
          debugPrint("Pusher connection state: $state");
          setState(() {
            _status = 'Connection state: $state';
          });
        },
        onError: (error, _, __) {
          debugPrint("Pusher error: $error");
          setState(() {
            _status = 'Error: $error';
          });
        },
      );

      await _pusher.connect();
      setState(() {
        _status = 'Connected to Pusher';
      });

      _channel = await _pusher.subscribe(
        channelName: 'my-channel',
        onEvent: (event) {
          final data = jsonDecode(event.data ?? '{}');
          final msg = data['message'] ?? 'No message';
          print(event.data);
          showSimpleNotification(Text("🔔 $msg"), background: Colors.green);
          setState(() {
            _status = 'Received: $msg';
          });

          print(event);
        },
      );
      setState(() {
        _status = 'Subscribed to my-channel';
      });
    } catch (e) {
      debugPrint('Pusher init error: $e');
      setState(() {
        _status = 'Initialization error: $e';
      });
    }
  }

  @override
  void dispose() {
    _pusher.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("🟢 Listening for real-time events..."),
              const SizedBox(height: 20),
              Text(_status),
            ],
          ),
        ),
      ),
    );
  }
}
