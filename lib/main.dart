import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'features/manager_cockpit/presentation/pages/cockpit_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // <-- Tambah ini
import 'core/theme/app_colors.dart';
import 'features/manager_cockpit/logic/manager_bloc.dart'; // <-- Tambah ini
import 'features/manager_cockpit/logic/manager_event.dart'; // <-- Tambah ini
import 'features/squad_management/logic/squad_bloc.dart';
import 'features/squad_management/logic/squad_event.dart';
import 'features/transfer_market/logic/market_cubit.dart';

void main() {
  runApp(const MisfitsApp());
}

class MisfitsApp extends StatelessWidget {
  const MisfitsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ManagerBloc()..add(LoadManagerProfile())),
        BlocProvider(create: (context) => SquadBloc()..add(LoadSquad())),
        
        // TAMBAHKAN INI:
        BlocProvider(create: (context) => MarketCubit()), 
      ], 
      child: MaterialApp(
        title: 'Misfits United',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: AppColors.background,
          textTheme: GoogleFonts.rajdhaniTextTheme(),
          useMaterial3: true,
        ),
        home: const CockpitScreen(),
      ),
    );
  }
}