import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/cats/api/media_player_api.dart',
    kotlinOut:
        'android/app/src/main/kotlin/com/example/purr_generator/MediaPlayerApi.kt',
    kotlinOptions: KotlinOptions(
      package: 'com.example.purr_generator'
    ),
    swiftOut: 'ios/Runner/MediaPlayerApi.swift',
    dartPackageName: 'purr_generator',
  ),
)
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
