import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:regex_craftsman/regex_craftsman.dart';

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
  runApp(MaterialApp(
    theme: theme,
    themeMode: ThemeMode.system,
    darkTheme: themeDark,
    debugShowCheckedModeBanner: false,
    home: const RegexCraftsman(),
  ));
}
