import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:regex_craftsman/regex_craftsman.dart';
import 'package:window_manager/window_manager.dart';

final theme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.light,
    seedColor: const Color.fromARGB(255, 92, 1, 219),
  ),
  textTheme: GoogleFonts.latoTextTheme().copyWith().apply(),
);

final themeDark = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.dark,
    seedColor: const Color.fromARGB(255, 92, 1, 219),
  ),
  textTheme:
      GoogleFonts.latoTextTheme().copyWith().apply(bodyColor: Colors.white),
);
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  if (Platform.isLinux) {}
  runApp(MaterialApp(
    theme: theme,
    themeMode: ThemeMode.system,
    darkTheme: themeDark,
    debugShowCheckedModeBanner: false,
    home: RegexCraftsman(),
  ));
}
