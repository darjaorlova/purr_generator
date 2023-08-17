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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cat.name),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/${widget.cat.filePrefix}.jpg',
              fit: BoxFit.cover,
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
                    FloatingActionButton(
                      onPressed: () => _triggerPlayer(),
                      tooltip: _playing ? 'Pause' : 'Play',
                      child: Icon(_playing ? Icons.pause : Icons.play_arrow),
                    ),
                    const SizedBox(width: 20.0),
                    FloatingActionButton(
                      onPressed: () => _toggleLoop(),
                      tooltip: 'Loop',
                      backgroundColor: _looping ? Colors.teal : Colors.grey,
                      child: const Icon(Icons.loop),
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
          /*Positioned(
            left: 20.0,
            right: 20.0,
            bottom: 20.0,
            child: Text(
              widget.cat.description,
              style: Theme.of(context).textTheme.subtitle2?.copyWith(
                color: Colors.white.withOpacity(0.4),
              ),
              textAlign: TextAlign.center,
              maxLines: 8,
              overflow: TextOverflow.ellipsis,
            ),
          ),*/
        ],
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

  void _toggleLoop() {
    setState(() {
      _looping = !_looping;
    });
  }
}

