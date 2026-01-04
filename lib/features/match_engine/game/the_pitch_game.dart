import 'dart:async';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_assets.dart';

class ThePitchGame extends FlameGame {
  final List<String> playerNames;

  ThePitchGame({this.playerNames = const []});

  @override
  Color backgroundColor() => const Color(0xFF050510);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 1. GAMBAR LAPANGAN (Static Background)
    try {
      final pitchSprite = await loadSprite(AppAssets.bgPitch.replaceAll('assets/images/', ''));
      add(SpriteComponent()
        ..sprite = pitchSprite
        ..size = size
      );
    } catch (e) {
      // Fallback color jika gambar gagal
    }

    // 2. SPAWN PEMAIN (Hanya Titik & Nama)
    _spawnStaticTeam(isHome: true, color: Colors.cyan, names: playerNames); 
    _spawnStaticTeam(isHome: false, color: Colors.red, names: ["CORPO-1", "CORPO-2", "CORPO-3", "CORPO-4", "CORPO-5", "CORPO-6", "CORPO-7", "CORPO-8", "CORPO-9", "CORPO-10", "CORPO-11"]);
  }

  void _spawnStaticTeam({required bool isHome, required Color color, required List<String> names}) {
    // Formasi 4-3-3 Standard
    final List<Vector2> formation = [
      Vector2(0.5, 0.9), // GK
      Vector2(0.2, 0.75), Vector2(0.4, 0.75), Vector2(0.6, 0.75), Vector2(0.8, 0.75), // DEF
      Vector2(0.3, 0.6), Vector2(0.5, 0.55), Vector2(0.7, 0.6), // MID
      Vector2(0.2, 0.45), Vector2(0.5, 0.4), Vector2(0.8, 0.45), // FWD
    ];

    for (int i = 0; i < formation.length; i++) {
      var pos = formation[i];
      // Mapping posisi agar pas di layar (Area 15% - 85%)
      double safeY = isHome 
          ? 0.5 + (pos.y - 0.5) * 0.7 
          : 0.5 - (pos.y - 0.5) * 0.7;

      Vector2 finalPos = Vector2(size.x * pos.x, size.y * safeY);
      String pName = (i < names.length) ? names[i] : "P-$i";

      // Tambahkan Komponen Statis
      add(StaticPlayerComponent(
        position: finalPos,
        color: color,
        name: pName,
      ));
    }
  }
}

// Komponen Pemain yang Sederhana (Tanpa Update Loop)
class StaticPlayerComponent extends PositionComponent {
  final Color color;
  final String name;

  StaticPlayerComponent({
    required Vector2 position,
    required this.color,
    required this.name,
  }) {
    this.position = position;
    anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() async {
    // Lingkaran Pemain
    add(CircleComponent(
      radius: 8,
      paint: Paint()..color = color..style = PaintingStyle.fill,
      anchor: Anchor.center,
    ));
    
    // Ring Luar (Biar manis)
    add(CircleComponent(
      radius: 10,
      paint: Paint()..color = color.withOpacity(0.3)..style = PaintingStyle.stroke..strokeWidth = 2,
      anchor: Anchor.center,
    ));

    // Nama Pemain (Background Hitam)
    final textBg = RectangleComponent(
      size: Vector2(60, 14),
      paint: Paint()..color = Colors.black.withOpacity(0.7),
      position: Vector2(0, 16),
      anchor: Anchor.topCenter,
    );
    
    final textComp = TextComponent(
      text: name,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white, 
          fontSize: 10, 
          fontWeight: FontWeight.bold,
          fontFamily: 'Rajdhani' // Font Cyberpunk
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(30, 7),
    );
    
    textBg.add(textComp);
    add(textBg);
  }
}