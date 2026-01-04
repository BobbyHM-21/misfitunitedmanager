# ⚽ Misfit United Manager

**Misfit United Manager** adalah game simulasi manajer sepak bola bertema *Cyberpunk/Sci-Fi* yang dibangun menggunakan **Flutter** dan **Flame**. Game ini berfokus pada pengambilan keputusan taktis (Tactical Decision), manajemen skuad, ekonomi klub, dan narasi pertandingan.

---

## 🗺️ Development Roadmap

### ✅ Phase 1: The Foundation (Core Gameplay)
Fase ini berfokus pada mekanik dasar pertandingan dan tampilan visual.
- [x] **UI/UX Framework:** Implementasi tema *Cyberpunk/Neon* (Cockpit, Squad Screen, Match Screen).
- [x] **Squad Management v1:** Menampilkan daftar pemain, posisi, rating, dan stamina.
- [x] **Match Engine v1 (Card System):** Mekanik dasar "Batu-Gunting-Kertas" (Attack > Skill > Defend).
- [x] **Match Engine v2 (Narrative Simulation):**
  - Mengganti simulasi bola fisik dengan *Text Commentary* yang imersif.
  - Implementasi Timer Pertandingan (1 menit game = ~0.6 detik real-time).
- [x] **Tactical Context System:**
  - Logika **Context-Aware**: Kartu yang muncul menyesuaikan situasi (Menyerang vs Bertahan).
  - Event Trigger: *Pause* otomatis saat momen krusial (Peluang Emas / Serangan Balik).

### ✅ Phase 2: The Economy & Management Loop
Fokus: Memberikan tujuan bermain dan siklus ekonomi.
- [x] **Match Rewards System:**
  - Mendapatkan uang (Credits) setelah pertandingan (Win/Draw/Loss).
  - Bonus uang untuk setiap gol yang dicetak.
- [x] **Transfer Market & Scouting:**
  - **Open Market:** Membeli pemain yang terdaftar dengan harga bervariasi.
  - **Gacha Scouting:** Sistem rekrutmen acak dengan 3 Tier (Rookie, Pro, Elite).
- [x] **Advanced Squad Management:**
  - **Drag & Drop:** Mengatur *Starting XI* dengan cara geser pemain.
  - **Stamina System:** Stamina berkurang setelah match.
  - **Recovery & Sell:** Opsi menyembuhkan pemain (bayar) atau menjual pemain (dapat uang).

### 🚧 Phase 3: Competition & Progression (Current Focus)
Fokus saat ini: Struktur kompetisi jangka panjang.
- [x] **League System (Basic):**
  - Tabel klasemen Liga (Rank, Points, W/D/L).
  - Integrasi hasil Match pemain ke klasemen.
- [x] **AI Simulation:**
  - Simulasi skor otomatis untuk 9 tim musuh (Cyber FC, Neon City, dll) setiap matchday.
- [x] **Season Schedule (Fixtures):**
  - Jadwal pertandingan terstruktur (Matchday 1 - 38) vs Lawan spesifik.
  - Reset musim setelah liga berakhir.
- [ ] **Player Progression (RPG):**
  - Sistem **Experience (XP)** untuk pemain setelah bertanding.
  - **Level Up:** Meningkatkan Rating pemain jika XP penuh.

### 🔮 Phase 4: Polish & Advanced Features
Fitur tambahan untuk meningkatkan kualitas *production*.
- [ ] **Save/Load System:** Menyimpan progress (Uang, Skuad, Klasemen) ke penyimpanan lokal (Hive/SharedPrefs).
- [ ] **Sound & SFX:** Menambahkan efek suara tombol, peluit wasit, dan sorakan penonton.
- [ ] **Club Facilities:** Upgrade stadion atau fasilitas latihan untuk bonus pasif.
- [ ] **Special Cards:** Kartu langka dengan efek khusus (misal: "Fire Shot").

---

## 🛠️ Tech Stack
- **Framework:** Flutter
- **Game Engine:** Flame (untuk rendering visual taktik)
- **State Management:** Flutter Bloc (MultiBlocProvider)
- **Architecture:** Feature-based Clean Architecture

---

*Dokumen ini diperbarui secara berkala sesuai progress pengembangan.*