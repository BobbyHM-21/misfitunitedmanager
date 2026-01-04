import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';

// Logic Market
import '../../logic/market_cubit.dart';
import '../../logic/market_state.dart';

// Logic Manager & Squad
import '../../../manager_cockpit/logic/manager_bloc.dart';
import '../../../manager_cockpit/logic/manager_event.dart';
import '../../../manager_cockpit/logic/manager_state.dart';
import '../../../squad_management/logic/squad_bloc.dart';
import '../../../squad_management/logic/squad_event.dart';
// Butuh model Player

class TransferScreen extends StatelessWidget {
  const TransferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MarketCubit()..loadMarket(),
      child: DefaultTabController(
        length: 2, // 2 Tab: Market & Gacha
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            title: const Text("TRANSFER HUB", style: TextStyle(fontFamily: 'Rajdhani', fontWeight: FontWeight.bold, color: Colors.white)),
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              // UANG MANAGER
              BlocBuilder<ManagerBloc, ManagerState>(
                builder: (context, state) {
                  int money = (state is ManagerLoaded) ? state.money : 0;
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(border: Border.all(color: AppColors.neonYellow), borderRadius: BorderRadius.circular(8)),
                        child: Text("\$ $money", style: const TextStyle(color: AppColors.neonYellow, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  );
                },
              )
            ],
            bottom: const TabBar(
              indicatorColor: AppColors.electricCyan,
              labelColor: AppColors.electricCyan,
              unselectedLabelColor: Colors.grey,
              labelStyle: TextStyle(fontFamily: 'Rajdhani', fontWeight: FontWeight.bold, fontSize: 16),
              tabs: [
                Tab(text: "OPEN MARKET"),
                Tab(text: "SCOUTING (GACHA)"),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              // TAB 1: MARKET LIST
              _buildMarketTab(),
              
              // TAB 2: GACHA SECTION
              _buildGachaTab(),
            ],
          ),
        ),
      ),
    );
  }

  // --- TAB 1: MARKET BIASA ---
  Widget _buildMarketTab() {
    return BlocBuilder<MarketCubit, MarketState>(
      builder: (context, state) {
        if (state is MarketLoading) {
          return const Center(child: CircularProgressIndicator(color: AppColors.electricCyan));
        }
        
        if (state is MarketLoaded) {
          if (state.forSalePlayers.isEmpty) {
            return const Center(child: Text("Market is empty.", style: TextStyle(color: Colors.white54)));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.forSalePlayers.length,
            itemBuilder: (context, index) {
              return _buildTransferCard(context, state.forSalePlayers[index]);
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildTransferCard(BuildContext context, MarketPlayer item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              color: item.player.rating > 85 ? AppColors.neonYellow : AppColors.electricCyan,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(child: Text("${item.player.rating}", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20))),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.player.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                Text("Pos: ${item.player.position}", style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("\$ ${item.price}", style: const TextStyle(color: AppColors.hotPink, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 5),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.electricCyan, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                onPressed: () => _handleBuyMarket(context, item),
                child: const Text("BUY", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ],
          )
        ],
      ),
    );
  }

  // --- TAB 2: GACHA SCOUTING ---
  Widget _buildGachaTab() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const Text("SCOUTING NETWORK", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Rajdhani', letterSpacing: 2)),
          const Text("Hire scouts to find talent for your squad.", style: TextStyle(color: Colors.white54, fontSize: 14)),
          const SizedBox(height: 30),
          
          // 3 KARTU GACHA
          _buildGachaCard("ROOKIE SCOUT", "Finds Rating 60-74", 500, AppColors.electricCyan, GachaTier.basic),
          const SizedBox(height: 20),
          _buildGachaCard("PRO AGENT", "Finds Rating 75-84", 2500, AppColors.neonYellow, GachaTier.pro),
          const SizedBox(height: 20),
          _buildGachaCard("ELITE NETWORK", "Finds Rating 85-99", 8000, AppColors.hotPink, GachaTier.elite),
        ],
      ),
    );
  }

  Widget _buildGachaCard(String title, String subtitle, int price, Color color, GachaTier tier) {
    return Builder(
      builder: (context) {
        return InkWell(
          onTap: () => _handleGacha(context, price, tier),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color, width: 2),
              boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 15)]
            ),
            child: Row(
              children: [
                Icon(Icons.person_search, size: 40, color: color),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Rajdhani')),
                      Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text("\$ $price", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
                      child: const Text("HIRE", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                    )
                  ],
                )
              ],
            ),
          ),
        );
      }
    );
  }

  // --- LOGIKA TRANSAKSI ---

  // 1. BELI DI MARKET
  void _handleBuyMarket(BuildContext context, MarketPlayer item) {
    final managerBloc = context.read<ManagerBloc>();
    final currentMoney = (managerBloc.state is ManagerLoaded) ? (managerBloc.state as ManagerLoaded).money : 0;

    if (currentMoney >= item.price) {
      managerBloc.add(ModifyMoney(-item.price));
      context.read<SquadBloc>().add(AddPlayerToSquad(item.player));
      context.read<MarketCubit>().buyPlayer(item);
      
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("SIGNED: ${item.player.name}"), backgroundColor: AppColors.electricCyan));
    } else {
      _showError(context, "Insufficient Funds!");
    }
  }

  // 2. GACHA PULL
  void _handleGacha(BuildContext context, int price, GachaTier tier) {
    final managerBloc = context.read<ManagerBloc>();
    final currentMoney = (managerBloc.state is ManagerLoaded) ? (managerBloc.state as ManagerLoaded).money : 0;

    if (currentMoney >= price) {
      // A. Bayar
      managerBloc.add(ModifyMoney(-price));
      
      // B. Generate Pemain
      final newPlayer = context.read<MarketCubit>().pullGacha(tier);
      
      // C. Masukkan ke Squad
      context.read<SquadBloc>().add(AddPlayerToSquad(newPlayer));

      // D. Tampilkan Animasi/Popup Hasil
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.black.withOpacity(0.95),
          shape: RoundedRectangleBorder(side: BorderSide(color: _getTierColor(tier), width: 2), borderRadius: BorderRadius.circular(16)),
          title: const Center(child: Text("SCOUT REPORT", style: TextStyle(color: Colors.white, fontFamily: 'Rajdhani', fontWeight: FontWeight.bold))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Player Found!", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(color: _getTierColor(tier), shape: BoxShape.circle),
                child: Center(child: Text("${newPlayer.rating}", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold))),
              ),
              const SizedBox(height: 10),
              Text(newPlayer.name, style: TextStyle(color: _getTierColor(tier), fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Rajdhani'), textAlign: TextAlign.center),
              Text(newPlayer.position, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: _getTierColor(tier)),
                onPressed: () => Navigator.pop(context),
                child: const Text("SIGN CONTRACT", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        )
      );

    } else {
      _showError(context, "Not enough credits to hire this scout!");
    }
  }

  void _showError(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  Color _getTierColor(GachaTier tier) {
    if (tier == GachaTier.elite) return AppColors.hotPink;
    if (tier == GachaTier.pro) return AppColors.neonYellow;
    return AppColors.electricCyan;
  }
}