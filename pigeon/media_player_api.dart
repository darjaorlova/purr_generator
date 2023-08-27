import 'package:pigeon/pigeon.dart';

@HostApi()
abstract class MediaPlayerApi {
  bool play(MediaFile file);

  void stop();

  void loop(bool looping);
}

class MediaFile {
  String fileName;

  MediaFile({required this.fileName});
}

@FlutterApi()
abstract class MediaPlayerProgressApi {
  void onProgress(double progress);

  void complete();
}
