import 'dart:async';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_assets.dart';

class ThePitchGame extends FlameGame {
  // Kita load aset di sini
  @override
  Color backgroundColor() => const Color(0xFF050510); // Background hitam jika gambar gagal load

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 1. TAMBAHKAN LAPANGAN (Background)
    // Kita coba load gambar, kalau error pakai warna polos
    try {
      final sprite = await loadSprite(AppAssets.bgPitch.replaceAll('assets/images/', ''));
      add(SpriteComponent()
        ..sprite = sprite
        ..size = size // Penuhi layar
      );
    } catch (e) {
      print("Aset lapangan belum ada, pakai layar hitam.");
    }

    // 2. TAMBAHKAN BOLA (Di Tengah)
    try {
      final ballSprite = await loadSprite(AppAssets.ball.replaceAll('assets/images/', ''));
      add(SpriteComponent()
        ..sprite = ballSprite
        ..size = Vector2(32, 32) // Ukuran bola
        ..position = size / 2 // Tepat di tengah layar
        ..anchor = Anchor.center
      );
    } catch (e) {
      // Bola placeholder (Kotak Putih) jika gambar tidak ada
      add(RectangleComponent(
        position: size / 2,
        size: Vector2(20, 20),
        paint: Paint()..color = Colors.white,
        anchor: Anchor.center,
      ));
    }

    // 3. SPAWN PEMAIN (Dummy Visual)
    _spawnTeam(isHome: true, color: Colors.cyan); // Tim Kita (Bawah)
    _spawnTeam(isHome: false, color: Colors.red); // Musuh (Atas)
  }

  void _spawnTeam({required bool isHome, required Color color}) {
    // Formasi Sederhana 4-3-3 (Koordinat Relatif 0.0 - 1.0)
    final List<Vector2> formation = [
      Vector2(0.5, 0.9), // GK
      Vector2(0.2, 0.75), Vector2(0.4, 0.75), Vector2(0.6, 0.75), Vector2(0.8, 0.75), // DEF
      Vector2(0.3, 0.6), Vector2(0.5, 0.55), Vector2(0.7, 0.6), // MID
      Vector2(0.2, 0.45), Vector2(0.5, 0.4), Vector2(0.8, 0.45), // FWD
    ];

    for (var pos in formation) {
      // Jika Tim Musuh (Away), posisi dibalik (Mirror)
      double x = pos.x;
      double y = isHome ? pos.y : (1.0 - pos.y);

      // Gambar Pemain sebagai Lingkaran Berwarna
      add(CircleComponent(
        radius: 12,
        paint: Paint()..color = color,
        position: Vector2(size.x * x, size.y * y),
        anchor: Anchor.center,
      ));
    }
  }
}