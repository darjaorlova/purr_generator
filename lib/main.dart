import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const PurringApp());
}

class PurringApp extends StatelessWidget {
  const PurringApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pigeon Demo',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: const PlayerPage(),
    );
  }
}

class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  static const platform = MethodChannel('flutter_purr_channel');
  bool _playing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Purr generator'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _triggerPlayer(),
        tooltip: _playing ? 'Pause' : 'Play',
        child: Icon(_playing ? Icons.pause : Icons.play_arrow),
      ),
    );
  }

  Future<void> _triggerPlayer() async {
    if (_playing) {
      await platform.invokeMethod('pause');
    } else {
      await platform.invokeMethod('play');
    }

    setState(() {
      _playing = !_playing;
    });
  }
}
