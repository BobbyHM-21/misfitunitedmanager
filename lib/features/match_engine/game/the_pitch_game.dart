import 'dart:async';
import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_assets.dart';

typedef DuelCallback = void Function();

class ThePitchGame extends FlameGame {
  final List<String> playerNames;
  final DuelCallback? onDuelTriggered;
  
  final List<PlayerComponent> _homeTeam = [];
  final List<PlayerComponent> _awayTeam = [];
  BallComponent? _ball;
  
  bool isPausedForDuel = false;
  PlayerComponent? _ballCarrier;

  ThePitchGame({this.playerNames = const [], this.onDuelTriggered});

  @override
  Color backgroundColor() => const Color(0xFF050510);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 1. LAPANGAN
    try {
      final pitchSprite = await loadSprite(AppAssets.bgPitch.replaceAll('assets/images/', ''));
      add(SpriteComponent()..sprite = pitchSprite..size = size);
    } catch (e) {}

    // 2. TIM & FORMASI
    _spawnTeam(isHome: true, color: Colors.cyan, names: playerNames); 
    _spawnTeam(isHome: false, color: Colors.red, names: ["CORPO-1", "CORPO-2", "CORPO-3", "CORPO-4", "CORPO-5", "CORPO-6", "CORPO-7", "CORPO-8", "CORPO-9", "CORPO-10", "CORPO-11"]);
  
    // 3. BOLA
    _ball = BallComponent(startPos: size / 2);
    add(_ball!);
  }

  void _spawnTeam({required bool isHome, required Color color, required List<String> names}) {
    // Definisi Formasi Relatif (0.0 - 1.0)
    final List<Vector2> formation = [
      Vector2(0.5, 0.9), // GK
      Vector2(0.2, 0.75), Vector2(0.4, 0.75), Vector2(0.6, 0.75), Vector2(0.8, 0.75), // DEF
      Vector2(0.3, 0.6), Vector2(0.5, 0.55), Vector2(0.7, 0.6), // MID
      Vector2(0.2, 0.45), Vector2(0.5, 0.4), Vector2(0.8, 0.45), // FWD
    ];

    for (int i = 0; i < formation.length; i++) {
      var basePos = formation[i];
      // Hitung posisi aman (15% - 85% layar)
      double safeY = isHome 
          ? 0.5 + (basePos.y - 0.5) * 0.7 
          : 0.5 - (basePos.y - 0.5) * 0.7;

      // Base Position adalah "Rumah" pemain di lapangan
      Vector2 homeBase = Vector2(size.x * basePos.x, size.y * safeY);
      String pName = (i < names.length) ? names[i] : "P-$i";

      final player = PlayerComponent(
        startPosition: homeBase,
        basePosition: homeBase, // Posisi formasi
        color: color,
        name: pName,
        isHomeTeam: isHome,
      );

      add(player);
      if (isHome) _homeTeam.add(player); else _awayTeam.add(player);
    }
  }

  @override
  void update(double dt) {
    if (isPausedForDuel) return;
    super.update(dt);
    if (_ball == null) return;

    // --- LOGIKA AI MANAGER (Strategic AI) ---
    
    // 1. Tentukan Siapa yang Mengejar Bola (Hanya 1 per tim)
    PlayerComponent? homeChaser = _findBestChaser(_homeTeam, _ball!.position);
    PlayerComponent? awayChaser = _findBestChaser(_awayTeam, _ball!.position);

    // 2. Update Logika Tiap Pemain
    for (var p in [..._homeTeam, ..._awayTeam]) {
      
      if (_ballCarrier != null) {
        // --- KASUS A: BOLA DIKUASAI ---
        if (p == _ballCarrier) {
          // Pembawa bola lari ke gawang lawan
          Vector2 goal = p.isHomeTeam ? Vector2(size.x / 2, 0) : Vector2(size.x / 2, size.y);
          p.runTo(goal, speedFactor: 0.9); // Sedikit lambat karena bawa bola
          _ball!.position = p.position; // Bola nempel
        } else {
          // Teman/Musuh lain jaga posisi formasi
          p.maintainFormation(_ball!.position, size); 
        }

      } else {
        // --- KASUS B: BOLA LIAR (FREE BALL) ---
        if (p == homeChaser || p == awayChaser) {
          // Hanya "Chaser" yang lari ke bola
          p.runTo(_ball!.position, speedFactor: 1.1); // Sprint!
          
          // Cek dapat bola
          if (p.position.distanceTo(_ball!.position) < 10) {
            _ballCarrier = p; // Dapat bola!
          }
        } else {
          // Sisanya "Support" (Jaga jarak formasi)
          p.maintainFormation(_ball!.position, size);
        }
      }
    }

    // 3. Cek Tabrakan (Duel)
    if (_ballCarrier != null) {
      // Cari musuh terdekat dari pembawa bola
      PlayerComponent? nearestEnemy = _findNearestPlayer(_ballCarrier!.position, excludeTeamHome: _ballCarrier!.isHomeTeam);
      
      if (nearestEnemy != null && nearestEnemy.position.distanceTo(_ballCarrier!.position) < 15) {
        // TRIGGER DUEL!
        isPausedForDuel = true;
        if (onDuelTriggered != null) onDuelTriggered!();
      }
    }
  }

  // Cari pemain terdekat ke target (Sederhana)
  PlayerComponent? _findBestChaser(List<PlayerComponent> team, Vector2 target) {
    PlayerComponent? best;
    double minDist = double.infinity;
    for (var p in team) {
      double d = p.position.distanceTo(target);
      if (d < minDist) {
        minDist = d;
        best = p;
      }
    }
    return best;
  }

  PlayerComponent? _findNearestPlayer(Vector2 target, {required bool excludeTeamHome}) {
    List<PlayerComponent> enemies = excludeTeamHome ? _awayTeam : _homeTeam;
    return _findBestChaser(enemies, target);
  }

  void resumeMatchAfterDuel({required bool homeWon}) {
    isPausedForDuel = false;
    if (_ballCarrier == null) return;

    if ((_ballCarrier!.isHomeTeam && homeWon) || (!_ballCarrier!.isHomeTeam && !homeWon)) {
       // Menang: Dribble lolos (Tendang bola sedikit ke depan)
       Vector2 forward = _ballCarrier!.isHomeTeam ? Vector2(0, -60) : Vector2(0, 60);
       _ball!.position += forward;
       _ballCarrier = null; // Bola lepas, kejar lagi!
    } else {
       // Kalah: Bola direbut musuh
       PlayerComponent? enemy = _findNearestPlayer(_ball!.position, excludeTeamHome: _ballCarrier!.isHomeTeam);
       if (enemy != null) {
         _ballCarrier = enemy; // Counter Attack!
       } else {
         _ballCarrier = null;
       }
    }
  }
}

// --- PEMAIN DENGAN FISIKA (STEERING BEHAVIOR) ---
class PlayerComponent extends PositionComponent {
  final Vector2 basePosition; // Posisi Formasi Asli
  final Color color;
  final String name;
  final bool isHomeTeam;

  // Fisika Gerak
  Vector2 velocity = Vector2.zero();
  final double maxSpeed = 80.0;
  final double acceleration = 200.0; // Kelincahan

  PlayerComponent({
    required Vector2 startPosition,
    required this.basePosition,
    required this.color,
    required this.name,
    required this.isHomeTeam,
  }) {
    position = startPosition;
    anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() async {
    add(CircleComponent(radius: 6, paint: Paint()..color = color, anchor: Anchor.center));
    add(RectangleComponent(size: Vector2(2, 8), paint: Paint()..color = Colors.white70, position: Vector2(0, -6), anchor: Anchor.center));
    
    final textBg = RectangleComponent(size: Vector2(50, 10), paint: Paint()..color = Colors.black54, position: Vector2(0, 12), anchor: Anchor.topCenter);
    final textComp = TextComponent(
      text: name,
      textRenderer: TextPaint(style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
      anchor: Anchor.center,
      position: Vector2(25, 5),
    );
    textBg.add(textComp);
    add(textBg);
  }

  // --- LOGIKA UTAMA: BERGERAK HALUS ---
  @override
  void update(double dt) {
    super.update(dt);
    // Aplikasikan kecepatan ke posisi
    position += velocity * dt;
    
    // Rotasi badan sesuai arah gerak (jika bergerak)
    if (velocity.length > 5) {
      angle = atan2(velocity.y, velocity.x) + pi / 2;
    }
  }

  // Perintah: Lari ke titik tertentu
  void runTo(Vector2 target, {double speedFactor = 1.0}) {
    Vector2 desiredDir = (target - position).normalized();
    Vector2 desiredVelocity = desiredDir * (maxSpeed * speedFactor);
    
    // Steering Force (Belok melengkung, bukan patah)
    Vector2 steering = (desiredVelocity - velocity) * 5.0; // 5.0 = Force strength
    
    velocity += steering * 0.016; // dt simulasi
    // Clamp speed
    if (velocity.length > maxSpeed * speedFactor) {
      velocity = velocity.normalized() * (maxSpeed * speedFactor);
    }
  }

  // Perintah: Jaga Formasi (Pindah relatif terhadap bola)
  void maintainFormation(Vector2 ballPos, Vector2 fieldSize) {
    // Logika: Bergerak sedikit mengikuti bola (Shifting), tapi jangan jauh dari basePosition
    
    // Hitung offset bola dari tengah lapangan
    Vector2 ballOffset = ballPos - (fieldSize / 2);
    
    // Target kita adalah Base Position + sebagian kecil gerakan bola
    // (Misal: bola ke kiri, formasi geser dikit ke kiri)
    Vector2 formationTarget = basePosition + (ballOffset * 0.3);
    
    // Lari santai ke posisi formasi
    runTo(formationTarget, speedFactor: 0.6); 
  }
}

class BallComponent extends SpriteComponent {
  BallComponent({required Vector2 startPos}) {
    size = Vector2(10, 10);
    position = startPos;
    anchor = Anchor.center;
  }
  @override
  Future<void> onLoad() async {
    try { sprite = await Sprite.load('ball.png'); } catch(e) {}
  }
}