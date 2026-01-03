import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../manager_cockpit/logic/manager_bloc.dart';
import '../../../manager_cockpit/logic/manager_event.dart';
import '../../../manager_cockpit/logic/manager_state.dart';
import '../../../squad_management/logic/squad_bloc.dart';
import '../../../squad_management/logic/squad_event.dart';
import '../../../squad_management/data/player_model.dart';
import '../../../squad_management/presentation/widgets/player_list_item.dart'; // Reuse Widget lama!
import '../../logic/market_cubit.dart';

class TransferScreen extends StatelessWidget {
  const TransferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("BLACK MARKET", style: TextStyle(color: AppColors.hotPink, fontFamily: 'Rajdhani', fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: AppColors.hotPink),
        actions: [
          // Tampilkan Sisa Uang di Pojok Kanan
          BlocBuilder<ManagerBloc, ManagerState>(
            builder: (context, state) {
              int money = 0;
              if (state is ManagerLoaded) money = state.money;
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Text(
                    "\$ $money",
                    style: const TextStyle(color: AppColors.neonYellow, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          )
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppAssets.bgCity),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.9), BlendMode.darken),
          ),
        ),
        child: BlocBuilder<MarketCubit, MarketState>(
          builder: (context, state) {
            return ListView.builder(
              padding: const EdgeInsets.only(top: 100, left: 16, right: 16),
              itemCount: state.forSale.length,
              itemBuilder: (context, index) {
                final player = state.forSale[index];
                // Hitung Harga (Misal: Rating * 100)
                final price = player.rating * 100;

                return Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    // Kita pakai widget PlayerListItem yang sudah ada
                    // Tapi kita bungkus supaya bisa diklik
                    PlayerListItem(player: player, index: index),

                    // Tombol BELI di sebelah kanan
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0, bottom: 12),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.hotPink,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          _buyPlayer(context, player, price);
                        },
                        child: Text("BUY \$$price"),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _buyPlayer(BuildContext context, Player player, int price) {
    final managerBloc = context.read<ManagerBloc>();
    
    // 1. Cek Uang Dulu
    if (managerBloc.state is ManagerLoaded) {
      final currentMoney = (managerBloc.state as ManagerLoaded).money;
      
      if (currentMoney >= price) {
        // UANG CUKUP: Lakukan Transaksi
        
        // A. Kurangi Uang
        managerBloc.add(ModifyMoney(-price)); // Minus harga
        
        // B. Tambah ke Squad
        context.read<SquadBloc>().add(AddPlayerToSquad(player));
        
        // C. Hapus dari Market
        context.read<MarketCubit>().removePlayer(player);

        // D. Feedback Visual (Snackbar)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("SUCCESS! ${player.name} joined the team."),
            backgroundColor: AppColors.electricCyan,
          ),
        );
      } else {
        // UANG TIDAK CUKUP
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("INSUFFICIENT FUNDS! Go win some matches."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}