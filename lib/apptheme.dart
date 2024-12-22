

import 'package:ahealth/appcolors.dart';
import 'package:flutter/material.dart';

ThemeData appTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
  useMaterial3: true,
  textTheme: const TextTheme(
    titleLarge: TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w700,
      fontSize: 30,
      color: black,
    ),
    titleMedium: TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w700,
      fontSize: 24,
      color: black,
    ),
    titleSmall: TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w700,
      fontSize: 18,
      color: black,
    ),
    bodySmall: TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w400,
      fontSize: 12,
      color: textDarkGrey,
    ),
    bodyMedium: TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w400,
      fontSize: 14,
      color: black,
    ),
  ),


  //appbar
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    titleSpacing: 0,
    centerTitle: false,
    titleTextStyle: TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w700,
      fontSize: 20,
      color: black,
    ),
  ),
  scaffoldBackgroundColor: background,

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.all(16),
      iconColor: Colors.white,
      textStyle: const TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w700,
        fontSize: 16,
        color: Colors.white,
      ),
      backgroundColor: primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    )
  )
);