import 'package:pigeon/pigeon.dart';

@FlutterApi()
abstract class MediaPlayerProgressApi {
  void onProgress(double progress);
  void complete();
}

@HostApi()
abstract class MediaPlayerApi {
  void play(String fileName);
  void stop();
  void loop(bool looping);
}