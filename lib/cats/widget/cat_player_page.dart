import 'package:flutter/material.dart';
import 'package:purr_generator/cats/api/media_player_api.dart';
import 'package:purr_generator/cats/model/cat.dart';

class CatPlayerPage extends StatefulWidget {
  final Cat cat;

  const CatPlayerPage({Key? key, required this.cat}) : super(key: key);

  @override
  State<CatPlayerPage> createState() => _CatPlayerPageState();
}

class _CatPlayerPageState extends State<CatPlayerPage> implements MediaPlayerProgressApi {
  final MediaPlayerApi _mediaPlayerApi = MediaPlayerApi();

  bool _playing = false;
  bool _looping = false;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    MediaPlayerProgressApi.setup(this);
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

  @override
  void dispose() {
    _stop();
    super.dispose();
  }

  Future<void> _triggerPlayer() async {
    if (_playing) {
      await _mediaPlayerApi.stop();
    } else {
      await _mediaPlayerApi.play(
        MediaFile(
          fileName: '${widget.cat.filePrefix}.m4a',
        ),
      );
    }

    setState(() {
      _playing = !_playing;
    });
  }

  Future<void> _stop() async {
    if (_playing) {
      _mediaPlayerApi.stop();
    }
  }

  void _toggleLoop() {
    _mediaPlayerApi.loop(!_looping);
    setState(() {
      _looping = !_looping;
    });
  }

  @override
  void complete() {
    if (mounted) {
      setState(() {
        _playing = false;
        _progress = 0.0;
      });
    }
  }

  @override
  void onProgress(double progress) {
    if (mounted) {
      setState(() {
        _progress = progress;
      });
    }
  }
}

