import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firestorage/pages/music_player/music_player.dart';
import 'package:firestorage/widgets/playlist.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:palette_generator/palette_generator.dart';

import 'package:firestorage/page_manager.dart';

class HomeScreen extends StatefulWidget {
  static const name = '/';

  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

PageManager _pageManager = PageManager();

class _HomeScreenState extends State<HomeScreen> {
  UploadTask? task;
  bool storageAllowed = true;

  @override
  void initState() {
    super.initState();
    _pageManager = PageManager();
  }

  @override
  void dispose() {
    _pageManager.dispose();
    super.dispose();
  }

  GlobalKey<ScaffoldState> scaffoldState = GlobalKey();

  Widget _buildWidgetAlbumCover(MediaQueryData mediaQuery) {
    return Container(
      width: double.infinity,
      height: mediaQuery.size.height / 1.8,
      decoration: const BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(48.0),
        ),
        image: DecorationImage(
          image: AssetImage('assets/images/coverart.jpg'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildWidgetActionAppBar(MediaQueryData mediaQuery) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16.0,
        top: mediaQuery.padding.top + 16.0,
        right: 16.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const <Widget>[
          Icon(
            Icons.menu,
            color: Colors.white,
          ),
          Icon(
            Icons.info_outline,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildWidgetArtistName(MediaQueryData mediaQuery) {
    return SizedBox(
      height: mediaQuery.size.height / 1.8,
      child: Padding(
        padding: const EdgeInsets.only(left: 20.0),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Stack(
              children: <Widget>[
                Positioned(
                  child: const Text(
                    'Rushia',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'CoralPen',
                      fontSize: 72.0,
                    ),
                  ),
                  top: constraints.maxHeight - 100.0,
                ),
                Positioned(
                  child: const Text(
                    'Uruha',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'CoralPen',
                      fontSize: 72.0,
                    ),
                  ),
                  top: constraints.maxHeight - 140.0,
                ),
                Positioned(
                  child: const Text(
                    'Hololive',
                    style: TextStyle(
                      shadows: [
                        Shadow(color: Colors.white,offset: Offset(1,0), blurRadius: 1),
                      ],
                      color: Color(0xFF7D9AFF),
                      fontSize: 14.0,
                      fontFamily: 'Campton_Light',
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  top: constraints.maxHeight - 160.0,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildWidgetFloatingActionButton(MediaQueryData mediaQuery) {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: EdgeInsets.only(
          top: mediaQuery.size.height / 1.8 - 32.0,
          right: 32.0,
        ),
        child: FloatingActionButton(
          child: const Icon(
            Icons.play_arrow,
            color: Colors.white,
          ),
          backgroundColor: const Color(0xFF7D9AFF),
          onPressed: () {
            Navigator.of(scaffoldState.currentState!.context)
                .pushNamed(MusicPlayer.name);
          },
        ),
      ),
    );
  }

  Widget _buildWidgetListSong(MediaQueryData mediaQuery) {
    return Padding(
        padding: EdgeInsets.only(
          left: 20.0,
          top: mediaQuery.size.height / 1.8 + 48.0,
          right: 20.0,
          bottom: mediaQuery.padding.bottom + 16.0,
        ),
        child: PlaylistBuilder(pageManager: _pageManager));
  }

  @override
  Widget build(BuildContext context) {
    checkPermission();

    var mediaQuery = MediaQuery.of(context);
    return SafeArea(
        maintainBottomViewPadding: true,
        child: Scaffold(
          key: scaffoldState,
          body: Stack(
            children: [
              _buildWidgetAlbumCover(mediaQuery),
              _buildWidgetActionAppBar(mediaQuery),
              _buildWidgetArtistName(mediaQuery),
              _buildWidgetFloatingActionButton(mediaQuery),
              _buildWidgetListSong(mediaQuery),
            ],
          ),
        ));
  }

  // File uploader stuff
  Future<void> filePicker() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(dialogTitle: 'Upload song', type: FileType.audio);
    if (result == null) return;
    final file = File(result.files.single.path!);
    final fileName = basename(file.path);
    task = FirebaseStorage.instance.ref('music/$fileName').putFile(file);
    if (task == null) return;
  }

  Widget buildUploadStatus(UploadTask task) => StreamBuilder<TaskSnapshot>(
      stream: task.snapshotEvents,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final snap = snapshot.data;
          final progress = snap!.bytesTransferred / snap.totalBytes;

          return LinearProgressIndicator(value: progress);
        } else {
          return Container();
        }
      });

  Future<void> checkPermission() async {
    if (kIsWeb) return;
    var status = await Permission.storage.status;
    if (status.isDenied) {
      setState(() {
        storageAllowed = false;
      });
    }
  }
}
