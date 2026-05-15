import 'package:flutter/material.dart';
import 'package:avaquran_app/app/services/audio_player_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:avaquran_app/resources/pages/audio_player_page.dart';

class MiniPlayerWidget extends StatelessWidget {
  const MiniPlayerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final audioService = QuranAudioPlayerService();

    return StreamBuilder<PlayerState>(
      stream: audioService.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final playing = playerState?.playing ?? false;
        final processingState = playerState?.processingState ?? ProcessingState.idle;

        if (processingState == ProcessingState.idle) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onTap: () => routeTo(AudioPlayerPage.path), // Needs current chapter data, maybe service should hold it
          child: Container(
            height: 65,
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(50),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: const Color(0xFF267B92),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(Icons.mic_external_on, color: Colors.white, size: 24),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        audioService.currentChapter?['name_simple'] ?? "Quran Recitation",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        audioService.currentChapter?['name_arabic'] ?? "Streaming live...",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontFamily: 'Amiri',
                        ),
                      ),
                    ],
                  ),
                ),
                if (processingState == ProcessingState.loading || processingState == ProcessingState.buffering)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    ),
                  )
                else
                  IconButton(
                    icon: Icon(
                      playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                    onPressed: () {
                      if (playing) {
                        audioService.pause();
                      } else {
                        audioService.resume();
                      }
                    },
                  ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 20),
                  onPressed: () => audioService.stop(),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        );
      },
    );
  }
}
