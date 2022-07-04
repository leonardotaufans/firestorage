import 'package:firestorage/page_manager.dart';
import 'package:firestorage/pages/music_player/music_player.dart';
import 'package:flutter/material.dart';

class PlaylistBuilder extends StatelessWidget {
  const PlaylistBuilder({
    Key? key,
    required this.pageManager
  }) : super(key: key);
  final PageManager pageManager;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<String>>(
      valueListenable: pageManager.playlistNotifier,
      //todo: Use database instead
      builder: (context, playlistTitles, _) {
        return ListView.separated(
            padding: EdgeInsets.zero,
            separatorBuilder: (context, _) {
              return const Opacity(
                opacity: 0.5,
                child: Padding(
                  padding: EdgeInsets.only(top: 2.0),
                  child: Divider(
                    color: Colors.grey,
                  ),
                ),
              );
            },
            itemCount: playlistTitles.length + 1,
            itemBuilder: (context, index) {
              if (index == playlistTitles.length) {
                return TextButton.icon(
                    style: ButtonStyle(
                        minimumSize:
                        MaterialStateProperty.all(const Size(200, 60))),
                    onPressed: () {
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add another'));
              }
              return ListTile(
                title: Text(
                  playlistTitles[index],
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Campton_Light'),
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () => Navigator.pushNamed(context, MusicPlayer.name,
                    arguments: MusicPlayerArguments(index)),
                trailing: IconButton(
                    onPressed: () {

                    }, icon: const Icon(Icons.more_horiz)),
              );
            });
      },
    );
  }
}
