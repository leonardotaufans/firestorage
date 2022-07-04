import 'dart:ui';

import 'package:firestorage/page_manager.dart';
import 'package:flutter/material.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';

import 'package:firestorage/pages/home/notifiers/play_button_notifier.dart';
import 'package:firestorage/pages/home/notifiers/progress_notifier.dart';
import 'package:firestorage/pages/home/notifiers/repeat_button_notifier.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Row(
        children: [
          SizedBox(
            width: 45,
            child: FittedBox(
                child: Icon(Icons.play_arrow_outlined,
                    color: Colors.green.shade800),
                fit: BoxFit.fill),
          ),
          Text('Music',
              style: Theme.of(context)
                  .textTheme
                  .headline6
                  ?.copyWith(color: Colors.green.shade900))
        ],
      ),
    );
  }
}

class MusicPlayerArguments {
  final int index;

  MusicPlayerArguments(this.index);
}

class MusicPlayer extends StatefulWidget {
  static const name = 'Music';

  const MusicPlayer({Key? key}) : super(key: key);

  @override
  State<MusicPlayer> createState() => _MusicPlayerState();
}

PageManager? _pageManager;

class _MusicPlayerState extends State<MusicPlayer> {
  @override
  initState() {
    super.initState();
    _pageManager = PageManager();
  }

  @override
  void dispose() {
    _pageManager!.dispose();
    super.dispose();
  }

  Widget _buildWidgetAlbumCoverBlur(MediaQueryData mediaQuery) {
    return Container(
      width: double.infinity,
      height: mediaQuery.size.height / 1.8,
      decoration: const BoxDecoration(
        shape: BoxShape.rectangle,
        image: DecorationImage(
          image: AssetImage('assets/images/coverart.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 10.0,
          sigmaY: 10.0,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.0),
          ),
        ),
      ),
    );
  }

  Widget _buildWidgetContainerMusicPlayer(MediaQueryData mediaQuery) {
    return Padding(
      padding: EdgeInsets.only(top: mediaQuery.padding.top + 16.0),
      child: Column(
        children: <Widget>[
          _buildWidgetActionAppBar(),
          const SizedBox(height: 48.0),
          _buildWidgetPanelMusicPlayer(mediaQuery),
        ],
      ),
    );
  }

  Widget _buildWidgetActionAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          const Text(
            'Uruha Rushia',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Campton_Light',
              fontWeight: FontWeight.w900,
              fontSize: 16.0,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.info_outline,
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildWidgetPanelMusicPlayer(MediaQueryData mediaQuery) {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(48.0),
            topRight: Radius.circular(48.0),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Flex(
            direction: Axis.horizontal,
            children: [
              Flexible(
                flex: 3,
                child: Column(
                  children: const <Widget>[
                    SizedBox(
                      height: 40,
                    ),
                    Thumbnail(),
                    CurrentSongTitle(),
                    Spacer(),
                    AudioProgressBar(),
                    AudioControlButtons()
                  ],
                ),
              ),
              const SizedBox(
                width: 8.0,
              ),
              Visibility(
                visible: MediaQuery.of(context).size.width > 659,
                child: Flexible(
                    flex: 4,
                    child: ValueListenableBuilder<List<String>>(
                      valueListenable: _pageManager!.playlistNotifier,
                      builder: (context, playlistTitles, _) {
                        return ListView.separated(
                            padding: EdgeInsets.zero,
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                //shows at the top of the playlist
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    top: 36,
                                  ),
                                  child: Text('Width: ${MediaQuery.of(context).size.width}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline6!
                                          .copyWith(fontWeight: FontWeight.w200)),
                                );
                              }
                              return ListTile(
                                title: Text(
                                  playlistTitles[index - 1],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: const Text(
                                  'Uruha Rushia',
                                  style: TextStyle(color: Color(0xFF7D9AFF)),
                                ),
                                onTap: () {
                                  _pageManager!.changeSong(index - 1);
                                  _pageManager!.play();
                                },
                              );
                            },
                            separatorBuilder: (context, _) => const Opacity(
                                  opacity: 0.4,
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 2.0),
                                    child: Divider(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                            itemCount: playlistTitles.length + 1);
                      },
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    var args =
        ModalRoute.of(context)?.settings.arguments as MusicPlayerArguments?;
    _pageManager = PageManager.bySong(args?.index ?? 0);
    return Scaffold(
      body: Stack(
        children: [
          _buildWidgetAlbumCoverBlur(mediaQuery),
          _buildWidgetContainerMusicPlayer(mediaQuery)
        ],
      ),
    );
  }
}

class Thumbnail extends StatelessWidget {
  const Thumbnail({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.height / 2.5,
        height: MediaQuery.of(context).size.height / 2.5,
        decoration: const BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(
            Radius.circular(24.0),
          ),
          image: DecorationImage(
            image: AssetImage(
              "assets/images/coverart.jpg",
            ),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class CurrentSongTitle extends StatelessWidget {
  const CurrentSongTitle({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ValueListenableBuilder<String>(
            valueListenable: _pageManager!.currentSongTitleNotifier,
            builder: (_, title, __) {
              return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontFamily: "Campton_Light",
                        fontSize: 20.0,
                      )));
            }),
        const SizedBox(
          height: 4.0,
        ),
        const Text('Uruha Rushia') //todo: make this dynamic using db
      ],
    );
  }
}

class AudioProgressBar extends StatelessWidget {
  const AudioProgressBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ProgressBarState>(
        valueListenable: _pageManager!.progressNotifier,
        builder: (_, value, __) {
          return ProgressBar(
            thumbRadius: 5.0,
            thumbColor: Colors.lightBlue,
            barHeight: 3.0,
            onSeek: _pageManager!.seek,
            progress: value.current,
            buffered: value.buffered,
            total: value.total,
          );
        });
  }
}

class AudioControlButtons extends StatelessWidget {
  const AudioControlButtons({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          RepeatButton(),
          PreviousSongButton(),
          PlayButton(),
          NextSongButton(),
          ShuffleButton(),
        ],
      ),
    );
  }
}

class RepeatButton extends StatelessWidget {
  const RepeatButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<RepeatState>(
        valueListenable: _pageManager!.repeatButtonNotifier,
        builder: (context, value, child) {
          Icon icon = const Icon(Icons.repeat);
          switch (value) {
            case RepeatState.off:
              icon = const Icon(Icons.repeat, color: Colors.grey);
              break;
            case RepeatState.repeatSong:
              icon = const Icon(Icons.repeat_one);
              break;
            case RepeatState.repeatPlaylist:
              icon = const Icon(Icons.repeat);
              break;
          }
          return IconButton(
            icon: icon,
            onPressed: _pageManager!.onRepeatButtonPressed,
          );
        });
  }
}

class PreviousSongButton extends StatelessWidget {
  const PreviousSongButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _pageManager!.isFirstSongNotifier,
      builder: (_, isFirst, __) {
        return IconButton(
          icon: const Icon(Icons.skip_previous),
          onPressed:
              (isFirst) ? null : _pageManager!.onPreviousSongButtonPressed,
        );
      },
    );
  }
}

class PlayButton extends StatelessWidget {
  const PlayButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ButtonState>(
      valueListenable: _pageManager!.playButtonNotifier,
      builder: (_, value, __) {
        switch (value) {
          case ButtonState.loading:
            return Container(
              margin: const EdgeInsets.all(8.0),
              width: 32.0,
              height: 32.0,
              child: const CircularProgressIndicator(),
            );
          case ButtonState.paused:
            return IconButton(
              icon: const Icon(Icons.play_arrow),
              iconSize: 32.0,
              onPressed: _pageManager!.play,
            );
          case ButtonState.playing:
            return IconButton(
              icon: const Icon(Icons.pause),
              iconSize: 32.0,
              onPressed: _pageManager!.pause,
            );
        }
      },
    );
  }
}

class NextSongButton extends StatelessWidget {
  const NextSongButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _pageManager!.isLastSongNotifier,
      builder: (_, isLast, __) {
        return IconButton(
          icon: const Icon(Icons.skip_next),
          onPressed: (isLast) ? null : _pageManager!.onNextSongButtonPressed,
        );
      },
    );
  }
}

class ShuffleButton extends StatelessWidget {
  const ShuffleButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _pageManager!.isShuffleModeEnabledNotifier,
      builder: (context, isEnabled, child) {
        return IconButton(
          icon: (isEnabled)
              ? const Icon(Icons.shuffle)
              : const Icon(Icons.shuffle, color: Colors.grey),
          onPressed: _pageManager!.onShuffleButtonPressed,
        );
      },
    );
  }
}
