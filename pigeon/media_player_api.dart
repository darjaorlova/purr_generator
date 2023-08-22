import 'package:pigeon/pigeon.dart';

@HostApi()
abstract class MediaPlayerApi {
  void play(String fileName);
  void stop();
  void loop(bool looping);
}