import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    background: const Color(0xFFE1F2F3),
    primary: const Color(0xFF2E7C87),
    outline: const Color(0xFF112E3C),
    secondary: const Color(0xFF143646),
    shadow: Colors.grey.withOpacity(0.2),
  ),
);

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    background: const Color(0xFF112E3B),
    primary: const Color(0xFF2E7C87),
    outline: const Color(0xFF112E3C),
    secondary: const Color(0xFFE1F2F3),
    shadow: Colors.white.withOpacity(0.2),
  ),
);

// TODO: Figure out what to do with these
// const Color text1Color = Color(0xFF16373C);
// const Color text2Color = Color(0xFFFFFFFF);
// const Color subtext1Color = Color(0xFF2F2F2F);
// Color shadow1Color = Colors.grey.withOpacity(0.2);
// LinearGradient glossyColor = LinearGradient(
//     begin: Alignment.centerLeft,
//     end: Alignment.centerRight,
//     colors: [Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.1)]);
