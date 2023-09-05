import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:regex_craftsman/regex_craftsman.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  if (Platform.isLinux) {}
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: RegexCraftsman(),
  ));
}
