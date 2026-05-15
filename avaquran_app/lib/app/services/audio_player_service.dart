import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:avaquran_app/app/networking/quran_api_service.dart';
import 'package:rxdart/rxdart.dart';

class QuranAudioPlayerService {
  static final QuranAudioPlayerService _instance = QuranAudioPlayerService._internal();
  factory QuranAudioPlayerService() => _instance;
  QuranAudioPlayerService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  AudioPlayer get player => _audioPlayer;

  // State
  dynamic _currentChapter;
  dynamic get currentChapter => _currentChapter;
  
  final _currentChapterController = BehaviorSubject<dynamic>();
  Stream<dynamic> get currentChapterStream => _currentChapterController.stream;

  List<dynamic> _playlist = [];
  int _currentIndex = -1;
  int _currentReciterId = 2; // Default: AbdulBaset AbdulSamad (Mujawwad)

  // Streams for UI
  Stream<SequenceState?> get sequenceStateStream => _audioPlayer.sequenceStateStream;
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;
  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;

  Future<void> init() async {
    // Basic initialization
  }

  Future<void> playSurah(dynamic chapter, {int? reciterId}) async {
    _currentChapter = chapter;
    _currentChapterController.add(chapter);
    final int chapterNumber = chapter['id'];
    
    // Update index if in playlist
    _currentIndex = _playlist.indexWhere((c) => c['id'] == chapterNumber);
    
    if (reciterId != null) _currentReciterId = reciterId;

    try {
      final apiService = QuranApiService();
      final audioData = await apiService.fetchFullChapterAudio(
        recitationId: _currentReciterId,
        chapterNumber: chapterNumber,
      );

      if (audioData != null && audioData['audio_file'] != null) {
        final String audioUrl = audioData['audio_file']['audio_url'];
        
        await _audioPlayer.setUrl(audioUrl);
        _audioPlayer.play();
      }
    } catch (e) {
      NyLogger.error("Error playing surah: $e");
    }
  }

  Future<void> setPlaylist(List<dynamic> chapters, {int? reciterId}) async {
    _playlist = chapters;
    if (reciterId != null) _currentReciterId = reciterId;
    
    final audioSources = <AudioSource>[];
    for (var chapter in chapters) {
      // Note: We'd need to fetch URLs for all chapters to build a full AudioSource list
      // For simplicity in this demo, we'll just handle manual "Next"
    }
  }

  Future<void> playNext() async {
    if (_playlist.isEmpty) return;
    _currentIndex = (_currentIndex + 1) % _playlist.length;
    await playSurah(_playlist[_currentIndex]);
  }

  Future<void> playPrevious() async {
    if (_playlist.isEmpty) return;
    _currentIndex = (_currentIndex - 1 + _playlist.length) % _playlist.length;
    await playSurah(_playlist[_currentIndex]);
  }

  void pause() => _audioPlayer.pause();
  void resume() => _audioPlayer.play();
  void stop() => _audioPlayer.stop();
  void seek(Duration position) => _audioPlayer.seek(position);

  void dispose() {
    _audioPlayer.dispose();
  }
}
