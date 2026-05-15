import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:avaquran_app/app/services/audio_player_service.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerPage extends NyStatefulWidget {
  static RouteView path = ("/audio-player", (_) => AudioPlayerPage());
  
  AudioPlayerPage({super.key}) : super(child: () => _AudioPlayerPageState());
}

class _AudioPlayerPageState extends NyPage<AudioPlayerPage> {
  final QuranAudioPlayerService _audioService = QuranAudioPlayerService();
  late dynamic _chapter;

  @override
  void initState() {
    super.initState();
    _chapter = widget.data();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<dynamic>(
      stream: _audioService.currentChapterStream,
      initialData: _chapter,
      builder: (context, snapshot) {
        final currentChapter = snapshot.data;
        if (currentChapter == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

        return Scaffold(
          backgroundColor: const Color(0xFF0F172A),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 32),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
          body: Container(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                const Spacer(),
                // Artwork / Visualizer Placeholder
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF267B92), Color(0xFF1A5666)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF267B92).withAlpha(30),
                        blurRadius: 40,
                        offset: const Offset(0, 20),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      currentChapter['name_arabic'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 80,
                        fontFamily: 'Amiri',
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                
                // Info
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentChapter['name_simple'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Recited by Mishary Rashid Alafasy",
                                style: TextStyle(
                                  color: Colors.white.withAlpha(150),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.favorite_border, color: Colors.white, size: 28),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 30),

                // Progress Slider
                StreamBuilder<Duration>(
                  stream: _audioService.positionStream,
                  builder: (context, snapshot) {
                    final position = snapshot.data ?? Duration.zero;
                    return StreamBuilder<Duration?>(
                      stream: _audioService.durationStream,
                      builder: (context, snapshot) {
                        final duration = snapshot.data ?? Duration.zero;
                        return Column(
                          children: [
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 4,
                                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                                activeTrackColor: const Color(0xFF267B92),
                                inactiveTrackColor: Colors.white.withAlpha(30),
                                thumbColor: Colors.white,
                              ),
                              child: Slider(
                                value: position.inSeconds.toDouble(),
                                max: duration.inSeconds.toDouble() > 0 
                                    ? duration.inSeconds.toDouble() 
                                    : position.inSeconds.toDouble() + 1,
                                onChanged: (value) {
                                  _audioService.seek(Duration(seconds: value.toInt()));
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatDuration(position),
                                    style: TextStyle(color: Colors.white.withAlpha(150), fontSize: 12),
                                  ),
                                  Text(
                                    _formatDuration(duration),
                                    style: TextStyle(color: Colors.white.withAlpha(150), fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shuffle, color: Colors.white54),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_previous_rounded, color: Colors.white, size: 40),
                      onPressed: _audioService.playPrevious,
                    ),
                    StreamBuilder<PlayerState>(
                      stream: _audioService.playerStateStream,
                      builder: (context, snapshot) {
                        final playerState = snapshot.data;
                        final processingState = playerState?.processingState;
                        final playing = playerState?.playing;
                        
                        if (processingState == ProcessingState.loading ||
                            processingState == ProcessingState.buffering) {
                          return Container(
                            margin: const EdgeInsets.all(8.0),
                            width: 64.0,
                            height: 64.0,
                            child: const CircularProgressIndicator(color: Colors.white),
                          );
                        } else if (playing != true) {
                          return IconButton(
                            icon: const Icon(Icons.play_circle_filled, color: Colors.white, size: 80),
                            onPressed: _audioService.resume,
                          );
                        } else if (processingState != ProcessingState.completed) {
                          return IconButton(
                            icon: const Icon(Icons.pause_circle_filled, color: Colors.white, size: 80),
                            onPressed: _audioService.pause,
                          );
                        } else {
                          return IconButton(
                            icon: const Icon(Icons.replay_circle_filled, color: Colors.white, size: 80),
                            onPressed: () => _audioService.seek(Duration.zero),
                          );
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 40),
                      onPressed: _audioService.playNext,
                    ),
                    IconButton(
                      icon: const Icon(Icons.repeat, color: Colors.white54),
                      onPressed: () {},
                    ),
                  ],
                ),
                
                const SizedBox(height: 40),
                
                // Footer Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.share_outlined, color: Colors.white54),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.playlist_add, color: Colors.white54),
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}
