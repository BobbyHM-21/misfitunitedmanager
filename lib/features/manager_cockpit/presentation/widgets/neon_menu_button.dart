import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';

class NeonMenuButton extends StatelessWidget {
  final String label;
  final String imagePath; // <-- GANTI INI (Dulu IconData)
  final Color glowColor;
  final VoidCallback onTap;
  final int delay;

  const NeonMenuButton({
    super.key,
    required this.label,
    required this.imagePath, // <-- GANTI INI
    required this.onTap,
    this.glowColor = AppColors.electricCyan,
    this.delay = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          // Background tombol dibuat semi-transparan hitam agar icon menonjol
          color: Colors.black.withOpacity(0.6), 
          border: Border.all(color: glowColor, width: 2),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: glowColor.withOpacity(0.3),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --- BAGIAN GAMBAR ---
            Image.asset(
              imagePath,
              width: 64,  // Ukuran gambar disesuaikan
              height: 64,
              fit: BoxFit.contain,
            ),
            
            const SizedBox(height: 12),
            
            // --- BAGIAN TEKS ---
            Text(
              label,
              style: TextStyle(
                color: glowColor, // Warna teks mengikuti tema tombol
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                fontFamily: 'Rajdhani', // Pastikan font sci-fi aktif
              ),
            ),
          ],
        ),
      ),
    )
    .animate()
    .fade(duration: 600.ms, delay: delay.ms)
    .scale(begin: const Offset(0.8, 0.8));
  }
}