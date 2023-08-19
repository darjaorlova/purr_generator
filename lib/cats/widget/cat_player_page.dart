import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purr_generator/cats/model/cat.dart';

class CatPlayerPage extends StatefulWidget {
  final Cat cat;

  const CatPlayerPage({Key? key, required this.cat}) : super(key: key);

  @override
  State<CatPlayerPage> createState() => _CatPlayerPageState();
}

class _CatPlayerPageState extends State<CatPlayerPage> {
  static const platform = MethodChannel('flutter_purr_channel');
  bool _playing = false;
  bool _looping = false;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();

    platform.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'updateProgress':
          final progress = call.arguments as double;
          setState(() {
            _progress = progress;
          });
          break;
        case 'complete':
          setState(() {
            _playing = false;
            _progress = 0.0;
          });
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cat.name),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Hero(
              tag: widget.cat.name,
              child: Image.asset(
                'assets/images/${widget.cat.filePrefix}.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          ColorFiltered(
            colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.6), BlendMode.srcOver),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () => _triggerPlayer(),
                      child: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                        radius: 28.0,
                        child: Icon(
                          _playing ? Icons.stop : Icons.play_arrow,
                          color: Theme.of(context).iconTheme.color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20.0),
                    InkWell(
                      onTap: () => _toggleLoop(),
                      child: CircleAvatar(
                        backgroundColor: _looping ? Colors.teal : Colors.grey,
                        radius: 28.0,
                        child: const Icon(
                          Icons.loop,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20.0),
                // Progress bar mockup
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: Colors.grey,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.teal),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _triggerPlayer() async {
    if (_playing) {
      await platform.invokeMethod('stop');
    } else {
      await platform.invokeMethod('play');
    }

    setState(() {
      _playing = !_playing;
    });
  }

  void _toggleLoop() {
    platform.invokeMethod('loop', {'looping': !_looping});
    setState(() {
      _looping = !_looping;
    });
  }
}

