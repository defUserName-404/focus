import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();
  final AudioPlayer _bgPlayer = AudioPlayer();

  Future<void> playNotification() async {
    await _player.play(AssetSource('audio/notification.mp3'));
  }

  Future<void> startNoise(String noiseAsset) async {
    await _bgPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgPlayer.play(AssetSource('audio/$noiseAsset'));
  }

  Future<void> stopNoise() async {
    await _bgPlayer.stop();
  }

  Future<void> setNoiseVolume(double volume) async {
    await _bgPlayer.setVolume(volume);
  }

  void dispose() {
    _player.dispose();
    _bgPlayer.dispose();
  }
}
