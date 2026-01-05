import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_assets.dart';

// Logic Squad
import '../../logic/squad_bloc.dart';
import '../../logic/squad_event.dart';
import '../../logic/squad_state.dart';
import '../../data/player_model.dart';

// Logic Manager
import '../../../manager_cockpit/logic/manager_bloc.dart';
import '../../../manager_cockpit/logic/manager_event.dart';
import '../../../manager_cockpit/logic/manager_state.dart';

class SquadScreen extends StatefulWidget {
  const SquadScreen({super.key});

  @override
  State<SquadScreen> createState() => _SquadScreenState();
}

class _SquadScreenState extends State<SquadScreen> {
  // Variable untuk fitur Tap Selection
  int? _selectedPlayerIndex;

  @override
  void initState() {
    super.initState();
    // Load data squad saat screen dibuka
    context.read<SquadBloc>().add(LoadSquad());
  }

  // --- LOGIKA TAP TO MOVE (DIPERBAIKI) ---
  void _handlePlayerTap(int index) {
    setState(() {
      if (_selectedPlayerIndex == null) {
        // Klik pertama: Pilih pemain
        _selectedPlayerIndex = index;
      } else if (_selectedPlayerIndex == index) {
        // Klik pemain yang sama: Batalkan pilihan
        _selectedPlayerIndex = null;
      } else {
        // Klik kedua: PINDAHKAN (Move) pemain
        int oldIndex = _selectedPlayerIndex!;
        int newIndex = index;

        // [FIX PENTING] Koreksi Indeks untuk ReorderableListView
        // Jika memindahkan item ke BAWAH (index lebih besar), kita harus tambah +1
        // karena saat item diambil, index di bawahnya akan bergeser naik.
        if (oldIndex < newIndex) {
          newIndex += 1;
        }

        // Eksekusi Pindah
        context.read<SquadBloc>().add(ReorderSquad(oldIndex, newIndex));
        _selectedPlayerIndex = null; // Reset seleksi
        
        // Feedback UI (Hapus const agar tidak error)
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Player Moved!"), 
            duration: Duration(milliseconds: 300),
            backgroundColor: AppColors.electricCyan,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("TACTICAL SQUAD", style: TextStyle(fontFamily: 'Rajdhani', fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // TOMBOL HEAL ALL
          IconButton(
            icon: const Icon(Icons.local_hospital, color: Colors.greenAccent),
            tooltip: "Heal All Players",
            onPressed: () => _showHealAllDialog(context),
          ),
          const SizedBox(width: 10),
          
          // DISPLAY UANG
          BlocBuilder<ManagerBloc, ManagerState>(
            builder: (context, state) {
              int money = 0;
              if (state is ManagerLoaded) money = state.money;
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.neonYellow),
                      borderRadius: BorderRadius.circular(8)
                    ),
                    child: Text("\$ $money", style: const TextStyle(color: AppColors.neonYellow, fontWeight: FontWeight.bold)),
                  ),
                ),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          // INSTRUKSI (Berubah warna jika sedang memilih)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: _selectedPlayerIndex != null ? AppColors.electricCyan.withValues(alpha: 0.1) : Colors.white10,
            child: Text(
              _selectedPlayerIndex == null 
                  ? "DRAG & DROP or TAP to Select Player.\nPositions 1-11 are Starters."
                  : "TAP target position to MOVE selected player.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _selectedPlayerIndex == null ? Colors.grey : AppColors.neonYellow, 
                fontSize: 12,
                fontWeight: _selectedPlayerIndex == null ? FontWeight.normal : FontWeight.bold
              ),
            ),
          ),
          
          // LIST PEMAIN
          Expanded(
            child: BlocBuilder<SquadBloc, SquadState>(
              builder: (context, state) {
                if (state is SquadLoaded) {
                  return ReorderableListView.builder(
                    padding: const EdgeInsets.only(bottom: 50),
                    itemCount: state.players.length,
                    
                    // Handler Drag & Drop (Fitur Lama)
                    onReorder: (oldIndex, newIndex) {
                      context.read<SquadBloc>().add(ReorderSquad(oldIndex, newIndex));
                    },
                    
                    itemBuilder: (context, index) {
                      final player = state.players[index];
                      final isStarter = index < 11;
                      final isSelected = _selectedPlayerIndex == index;
                      
                      // PANGGIL WIDGET ITEM (INLINE AGAR KODE LENGKAP)
                      return _buildPlayerListItem(context, player, isStarter, index, isSelected);
                    },
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET ITEM PEMAIN (DIGABUNG DISINI) ---
  Widget _buildPlayerListItem(BuildContext context, Player player, bool isStarter, int index, bool isSelected) {
    Color statusColor = isStarter ? AppColors.electricCyan : Colors.grey;
    double stamina = player.stamina;
    double targetXp = (player.xpToNextLevel > 0) ? player.xpToNextLevel.toDouble() : 1000.0;
    double xpProgress = (player.currentXp / targetXp).clamp(0.0, 1.0);

    return GestureDetector(
      key: ValueKey(player.name), // Key Penting
      onTap: () => _handlePlayerTap(index), // Aksi Tap
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.electricCyan.withValues(alpha: 0.3) 
              : (isStarter ? Colors.blueGrey.withValues(alpha: 0.1) : Colors.black),
          border: Border(
            left: BorderSide(color: statusColor, width: 4),
            top: isSelected ? const BorderSide(color: AppColors.electricCyan, width: 2) : BorderSide.none,
            bottom: isSelected ? const BorderSide(color: AppColors.electricCyan, width: 2) : const BorderSide(color: Colors.white12),
            right: isSelected ? const BorderSide(color: AppColors.electricCyan, width: 2) : BorderSide.none,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          
          // HANDLE DRAG / INDIKATOR
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(isSelected ? Icons.check_circle : Icons.drag_handle, 
                   color: isSelected ? AppColors.electricCyan : Colors.white24),
              const SizedBox(width: 10),
              Container(
                width: 25,
                alignment: Alignment.center,
                child: Text("${index + 1}", style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          ),
          
          // INFO UTAMA
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      player.name, 
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Rajdhani', fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (player.seasonGoals > 0) 
                    Container(
                      margin: const EdgeInsets.only(left: 5),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(border: Border.all(color: AppColors.neonYellow), borderRadius: BorderRadius.circular(3)),
                      child: Row(
                        children: [
                          const Icon(Icons.sports_soccer, size: 8, color: AppColors.neonYellow),
                          const SizedBox(width: 2),
                          Text("${player.seasonGoals}", style: const TextStyle(color: AppColors.neonYellow, fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    )
                ],
              ),
            ],
          ),
          
          // STATISTIK & PROGRESS
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(3)),
                    child: Text(player.position, style: const TextStyle(color: AppColors.neonYellow, fontWeight: FontWeight.bold, fontSize: 10)),
                  ),
                  const SizedBox(width: 8),
                  Text("RTG: ${player.rating}", style: const TextStyle(color: Colors.white, fontSize: 11)),
                  const SizedBox(width: 8),
                  Text("APPS: ${player.seasonAppearances}", style: const TextStyle(color: Colors.grey, fontSize: 11)),
                ],
              ),
              const SizedBox(height: 8),
              
              // Stamina Bar
              Row(
                children: [
                  const Text("STM", style: TextStyle(color: Colors.grey, fontSize: 9)),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(2)),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft, 
                        widthFactor: stamina, 
                        child: Container(color: stamina > 0.5 ? Colors.green : Colors.red)
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              
              // XP Bar
              Row(
                children: [
                  const Text("EXP", style: TextStyle(color: AppColors.neonYellow, fontSize: 9, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          height: 6,
                          decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(2)),
                        ),
                        FractionallySizedBox(
                          widthFactor: xpProgress,
                          child: Container(
                            height: 6,
                            decoration: BoxDecoration(color: AppColors.neonYellow, borderRadius: BorderRadius.circular(2)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text("${player.currentXp}/${player.xpToNextLevel}", style: const TextStyle(color: Colors.grey, fontSize: 9)),
                ],
              ),
            ],
          ),
          
          // Tombol Gear (Detail)
          trailing: IconButton(
            icon: const Icon(Icons.settings, color: Colors.white24, size: 20),
            onPressed: () => _showActionMenu(context, player),
          ),
        ),
      ),
    );
  }

  // --- MENU POPUP ---
  void _showActionMenu(BuildContext context, Player player) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.electricCyan, width: 2))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Manage ${player.name}", style: const TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'Rajdhani', fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.local_hospital, color: Colors.green),
                title: const Text("Heal Player (\$50)", style: TextStyle(color: Colors.white)), // Hapus Const
                onTap: () {
                  if (player.stamina < 1.0) {
                    final managerBloc = context.read<ManagerBloc>();
                    int money = (managerBloc.state is ManagerLoaded) ? (managerBloc.state as ManagerLoaded).money : 0;
                    if (money >= 50) {
                      managerBloc.add(const ModifyMoney(-50));
                      context.read<SquadBloc>().add(RecoverStamina(player));
                      Navigator.pop(context);
                      // Hapus Const
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Player Recovered!"), backgroundColor: Colors.green));
                    } else {
                      Navigator.pop(context);
                      // Hapus Const
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Not enough money!"), backgroundColor: Colors.red));
                    }
                  } else {
                    Navigator.pop(context);
                    // Hapus Const
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Player is already fit!")));
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.monetization_on, color: Colors.amber),
                title: const Text("Sell Player (+\$200)", style: TextStyle(color: Colors.white)), // Hapus Const
                onTap: () {
                  context.read<ManagerBloc>().add(const ModifyMoney(200));
                  context.read<SquadBloc>().add(SellPlayer(player));
                  Navigator.pop(context);
                  // Hapus Const
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Player Sold!"), backgroundColor: AppColors.neonYellow));
                },
              ),
            ],
          ),
        );
      }
    );
  }

  // --- POPUP HEAL ALL ---
  void _showHealAllDialog(BuildContext context) {
    final state = context.read<SquadBloc>().state;
    if (state is SquadLoaded) {
      int injuredCount = state.players.where((p) => p.stamina < 1.0).length;
      int cost = injuredCount * 20;

      if (injuredCount == 0) {
        // Hapus Const
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Team is fully fit!")));
        return;
      }

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(side: const BorderSide(color: Colors.green), borderRadius: BorderRadius.circular(12)),
          title: const Text("TEAM RECOVERY", style: TextStyle(color: Colors.white, fontFamily: 'Rajdhani', fontWeight: FontWeight.bold)),
          content: Text("Heal $injuredCount players for \$$cost?", style: const TextStyle(color: Colors.white70)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL", style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () {
                final managerBloc = context.read<ManagerBloc>();
                int money = 0;
                if (managerBloc.state is ManagerLoaded) money = (managerBloc.state as ManagerLoaded).money;

                if (money >= cost) {
                  managerBloc.add(ModifyMoney(-cost));
                  context.read<SquadBloc>().add(RecoverAllStamina());
                  Navigator.pop(context);
                  // Hapus Const
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Team Fully Recovered!"), backgroundColor: Colors.green));
                } else {
                  Navigator.pop(context);
                  // Hapus Const
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Insufficient Funds!"), backgroundColor: Colors.red));
                }
              }, 
              child: const Text("PAY & HEAL", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))
            )
          ],
        )
      );
    }
  }
}