# ⚽ Misfit United Manager

**Misfit United Manager** adalah game simulasi manajer sepak bola bertema *Cyberpunk/Sci-Fi* yang dibangun menggunakan **Flutter** dan **Flame**. Game ini berfokus pada pengambilan keputusan taktis (Tactical Decision), manajemen skuad, dan narasi pertandingan, bukan simulasi fisika bola yang berat.

---

## 🗺️ Development Roadmap

### ✅ Phase 1: The Foundation (Core Gameplay)
Fase ini berfokus pada mekanik dasar pertandingan dan tampilan visual.
- [x] **UI/UX Framework:** Implementasi tema *Cyberpunk/Neon* (Cockpit, Squad Screen, Match Screen).
- [x] **Squad Management:** Menampilkan daftar pemain, posisi, rating, dan stamina.
- [x] **Match Engine v1 (Card System):** Mekanik dasar "Batu-Gunting-Kertas" (Attack > Skill > Defend).
- [x] **Match Engine v2 (Narrative Simulation):**
  - Mengganti simulasi bola fisik dengan *Text Commentary* yang imersif.
  - Implementasi Timer Pertandingan (1 menit game = ~0.6 detik real-time).
- [x] **Tactical Context System:**
  - Logika **Context-Aware**: Kartu yang muncul menyesuaikan situasi (Menyerang vs Bertahan).
  - Event Trigger: *Pause* otomatis saat momen krusial (Peluang Emas / Serangan Balik).
  - Konsekuensi: Risiko penalti jika *Tackle* gagal, variasi hasil tembakan.

### 🚧 Phase 2: The Economy & Loop (Current Focus)
Fokus saat ini: Memberikan tujuan bermain (*Why we play*).
- [ ] **Match Rewards System:**
  - Mendapatkan uang (Credits) setelah pertandingan (Win/Draw/Loss).
  - Bonus uang untuk setiap gol yang dicetak.
- [ ] **Functional Transfer Market:**
  - Menggunakan uang hasil pertandingan untuk membeli pemain baru.
  - Sistem harga pemain berdasarkan Rating.
- [ ] **Stamina & Recovery:**
  - Stamina pemain berkurang permanen setelah match.
  - Fitur pemulihan stamina (Resting/Medical Kit dengan biaya uang).

### 🔜 Phase 3: Competition & Progression
Memberikan struktur jangka panjang agar game tidak membosankan.
- [ ] **League System (Klasemen):**
  - Tabel klasemen sederhana (Points, Won, Drawn, Lost).
  - Generate hasil pertandingan tim lain (Simulasi *dummy*).
- [ ] **Player RPG Elements:**
  - Sistem **Experience (XP)** untuk pemain setelah bertanding.
  - **Level Up:** Meningkatkan Rating pemain jika XP penuh.
- [ ] **Season Loop:** Jadwal pertandingan (Matchday 1 - 38) dan juara di akhir musim.

### 🔮 Phase 4: Polish & Advanced Features
Fitur tambahan untuk meningkatkan kualitas *production*.
- [ ] **Save/Load System:** Menyimpan progress (Uang, Skuad, Klasemen) ke penyimpanan lokal (Hive/SharedPrefs).
- [ ] **Sound & SFX:** Menambahkan efek suara tombol, peluit wasit, dan sorakan penonton.
- [ ] **Advanced Tactics:** Opsi formasi (4-4-2, 4-3-3, 3-5-2) yang mempengaruhi peluang munculnya kartu.
- [ ] **Special Cards:** Kartu langka dengan efek khusus (misal: "Fire Shot" - 100% Goal jika kiper musuh rating < 80).

---

## 🛠️ Tech Stack
- **Framework:** Flutter
- **Game Engine:** Flame (untuk rendering visual taktik)
- **State Management:** Flutter Bloc
- **Architecture:** Feature-based Clean Architecture

---

*Dokumen ini diperbarui secara berkala sesuai progress pengembangan.*