import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerHome extends StatefulWidget {
  const AudioPlayerHome({super.key});

  @override
  State<AudioPlayerHome> createState() => _AudioPlayerHomeState();
}

class _AudioPlayerHomeState extends State<AudioPlayerHome> {
  final _player = AudioPlayer();
  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    _setupAudioPlayer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Audio Home Page")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              _sliderPlayer(),
              Row(
                children: [
                  _volumSlider(),
                  _playBackControlButton(),
                ],
              ),
              _speedSlider(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _setupAudioPlayer() async {
    _player.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
          print("A stream error occurred: $e");
        });
    try {
      _player.setAudioSource(AudioSource.uri(
          Uri.parse("https://server12.mp3quran.net/tnjy/114.mp3")));
    } catch (e) {
      print("error loading audio source: $e");
    }
  }

  Widget _speedSlider() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        StreamBuilder(
            stream: _player.speedStream,
            builder: (context, snapshot) {
              return Row(
                children: [
                  const Icon(
                    Icons.speed,
                    color: Colors.red,
                  ),
                  Slider(
                      min: 0,
                      max: 4,
                      value: snapshot.data ?? 1,
                      divisions: 4,
                      onChanged: (value) async {
                        await _player.setSpeed(value);
                      })
                ],
              );
            })
      ],
    );
  }

  Widget _volumSlider() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        StreamBuilder(
            stream: _player.volumeStream,
            builder: (context, snapshot) {
              return Row(
                children: [
                  const Icon(
                    Icons.volume_up,
                  ),
                  Slider(
                      min: 0,
                      max: 4,
                      value: snapshot.data ?? 1,
                      divisions: 4,
                      onChanged: (value) async {
                        await _player.setVolume(value);
                      })
                ],
              );
            })
      ],
    );
  }

  Widget _sliderPlayer() {
    return StreamBuilder(
        stream: _player.positionStream,
        builder: (context, snapshot) {
          return ProgressBar(
            progress: snapshot.data ?? Duration.zero,
            buffered: _player.bufferedPosition,
            total: _player.duration ?? Duration.zero,
            onSeek: (duration) {
              _player.seek(duration);
            },
          );
        });
  }

  Widget _playBackControlButton() {
    return StreamBuilder<PlayerState>(
        stream: _player.playerStateStream,
        builder: (context, snapshot) {
          final processingState = snapshot.data?.processingState;
          final playing = snapshot.data?.playing;
          if (processingState == ProcessingState.loading ||
              processingState == ProcessingState.buffering) {
            return Container(
              margin: const EdgeInsets.all(8),
              height: 64,
              width: 64,
              child: const CircularProgressIndicator(),
            );
          } else if (playing != true) {
            return IconButton(
                onPressed: _player.play,
                icon: const Icon(
                  Icons.play_arrow,
                  color: Colors.red,
                ));
          } else if (processingState != ProcessingState.completed) {
            return IconButton(
                onPressed: _player.pause,
                color: Colors.red,
                icon: const Icon(
                  Icons.pause,
                ));
          } else {
            return IconButton(
                onPressed: () => _player.seek(Duration.zero),
                icon: const Icon(
                  Icons.replay,
                  color: Color.fromARGB(255, 2, 63, 114),
                ));
          }
        });
  }
}
