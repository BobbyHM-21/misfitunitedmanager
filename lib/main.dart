import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'features/manager_cockpit/presentation/pages/cockpit_screen.dart';

void main() {
  runApp(const MisfitsApp());
}

class MisfitsApp extends StatelessWidget {
  const MisfitsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Misfits United',
      debugShowCheckedModeBanner: false, // Hilangkan label Debug
      theme: ThemeData(
        brightness: Brightness.dark,
        // Set Font Global jadi Rajdhani (Gaya Sci-Fi)
        textTheme: GoogleFonts.rajdhaniTextTheme(),
        useMaterial3: true,
      ),
      home: const CockpitScreen(),
    );
  }
}