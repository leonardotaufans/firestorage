import 'package:firebase_storage/firebase_storage.dart';
import 'package:firestorage/pages/home/notifiers/play_button_notifier.dart';
import 'package:firestorage/pages/home/notifiers/progress_notifier.dart';
import 'package:firestorage/pages/home/notifiers/repeat_button_notifier.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class PageManager {
  FirebaseStorage storage = FirebaseStorage.instance;
  final currentSongTitleNotifier = ValueNotifier<String>('');
  final playlistNotifier = ValueNotifier<List<String>>([]);
  final progressNotifier = ProgressNotifier();
  final repeatButtonNotifier = RepeatButtonNotifier();
  final isFirstSongNotifier = ValueNotifier<bool>(true);
  final playButtonNotifier = PlayButtonNotifier();
  final isLastSongNotifier = ValueNotifier<bool>(true);
  final isShuffleModeEnabledNotifier = ValueNotifier<bool>(false);
  final listPlaylist = ValueNotifier<int>(0);
  AudioPlayer? _audioPlayer;
  ConcatenatingAudioSource? _playlist;
  int? _index;

  PageManager() {
    _init();
  }

  PageManager.bySong(int index) {
    _init();
    _index = index;
  }

  void _init() async {
    _audioPlayer = AudioPlayer();
    _setPlaylist();
    _listenForChangesInPlayerState();
    _listenForChangesInPlayerPosition();
    _listenForChangesInBufferedPosition();
    _listenForChangesInTotalDuration();
    _listenForChangesInSequenceState();
    _listPlaylist();
  }

  Future<List<Map<String, dynamic>>> firebaseStoragePlaylist() async {
    List<Map<String, dynamic>> files = [];

    final ListResult result = await storage.ref().child("music").list();
    final List<Reference> allFiles = result.items;

    await Future.forEach<Reference>(allFiles, (file) async {
      final String fileUrl = await file.getDownloadURL();
      files.add({
        "url": fileUrl,
        "tag": file.fullPath,
      });
    });

    return files;
  }

  void _listPlaylist() async {
    List<Map<String, dynamic>> allMusic = await firebaseStoragePlaylist();
    listPlaylist.value = allMusic.length;
  }

  void _setPlaylist() async {
    List<Map<String, dynamic>> allMusic = await firebaseStoragePlaylist();
    List<AudioSource> sauce = [];
    for (var a in allMusic) {
      sauce.add(AudioSource.uri(Uri.parse(a["url"]), tag: a["tag"]));
    }

    _playlist = ConcatenatingAudioSource(children: sauce);
    await _audioPlayer!.setAudioSource(_playlist!, initialIndex: _index ?? 0);
  }

  void _listenForChangesInPlayerState() {
    _audioPlayer!.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      final processingState = playerState.processingState;
      if (processingState == ProcessingState.loading ||
          processingState == ProcessingState.buffering) {
        playButtonNotifier.value = ButtonState.loading;
      } else if (!isPlaying) {
        playButtonNotifier.value = ButtonState.paused;
      } else if (processingState != ProcessingState.completed) {
        playButtonNotifier.value = ButtonState.playing;
      } else {
        _audioPlayer!.seek(Duration.zero);
        _audioPlayer!.pause();
      }
    });
  }

  void _listenForChangesInPlayerPosition() {
    _audioPlayer!.positionStream.listen((position) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: position,
        buffered: oldState.buffered,
        total: oldState.total,
      );
    });
  }

  void _listenForChangesInBufferedPosition() {
    _audioPlayer!.bufferedPositionStream.listen((bufferedPosition) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: bufferedPosition,
        total: oldState.total,
      );
    });
  }

  void _listenForChangesInTotalDuration() {
    _audioPlayer!.durationStream.listen((totalDuration) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: oldState.buffered,
        total: totalDuration ?? Duration.zero,
      );
    });
  }

  void _listenForChangesInSequenceState() {
    _audioPlayer!.sequenceStateStream.listen((sequenceState) {
      if (sequenceState == null) return;

      // update current song title
      final currentItem = sequenceState.currentSource;
      // final title = _audioPlayer!.icyMetadata?.headers?.name;
      final _titleData = currentItem?.tag as String? ?? "------Unknown Song";
      String title = _titleData.substring(6);
      currentSongTitleNotifier.value = title;

      // update playlist
      final playlist = sequenceState.effectiveSequence;
      final titles = playlist.map((item) => item.tag as String).toList();
      playlistNotifier.value = titles;

      // update shuffle mode
      isShuffleModeEnabledNotifier.value = sequenceState.shuffleModeEnabled;

      // update previous and next buttons
      if (playlist.isEmpty || currentItem == null) {
        isFirstSongNotifier.value = true;
        isLastSongNotifier.value = true;
      } else {
        isFirstSongNotifier.value = playlist.first == currentItem;
        isLastSongNotifier.value = playlist.last == currentItem;
      }
    });
  }

  void play() async {
    _audioPlayer!.play();
  }

  void pause() {
    _audioPlayer!.pause();
  }

  void seek(Duration position) {
    _audioPlayer!.seek(position);
  }

  void dispose() {
    _audioPlayer!.dispose();
  }

  void onRepeatButtonPressed() {
    repeatButtonNotifier.nextState();
    switch (repeatButtonNotifier.value) {
      case RepeatState.off:
        _audioPlayer!.setLoopMode(LoopMode.off);
        break;
      case RepeatState.repeatSong:
        _audioPlayer!.setLoopMode(LoopMode.one);
        break;
      case RepeatState.repeatPlaylist:
        _audioPlayer!.setLoopMode(LoopMode.all);
    }
  }

  void onPreviousSongButtonPressed() {
    _audioPlayer!.seekToPrevious();
  }

  void onNextSongButtonPressed() {
    _audioPlayer!.seekToNext();
  }

  void onShuffleButtonPressed() async {
    final enable = !_audioPlayer!.shuffleModeEnabled;
    if (enable) {
      await _audioPlayer!.shuffle();
    }
    await _audioPlayer!.setShuffleModeEnabled(enable);
  }

  void changeSong(int index) async {
    _audioPlayer!.seek(Duration.zero, index: index);
  }
}
