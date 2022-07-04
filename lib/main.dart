import 'package:firebase_core/firebase_core.dart';
import 'package:firestorage/firebase_options.dart';
import 'package:firestorage/pages/music_player/music_player.dart';
import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'pages/home/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: ThemeData(
          primarySwatch: Colors.green,
          colorScheme: const ColorScheme.light(),
          brightness: Brightness.light),
      dark: ThemeData(
          primarySwatch: Colors.green,
          colorScheme: const ColorScheme.dark(),
          brightness: Brightness.dark),
      initial: AdaptiveThemeMode.system,
      builder: (ThemeData light, ThemeData dark) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'NEEEEEEEEEEEEE',
          initialRoute: '/',
          routes: {
            HomeScreen.name: (context) => const HomeScreen(),
            MusicPlayer.name: (context) => const MusicPlayer()
          },
        );
      },
    );
  }
}
