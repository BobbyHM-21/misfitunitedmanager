import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_colors.dart';

// Screens
import 'features/manager_cockpit/presentation/pages/cockpit_screen.dart';

// Logic Imports
import 'features/manager_cockpit/logic/manager_bloc.dart';
import 'features/manager_cockpit/logic/manager_event.dart';
import 'features/squad_management/logic/squad_bloc.dart';
import 'features/squad_management/logic/squad_event.dart';
import 'features/transfer_market/logic/market_cubit.dart';
// [BARU] Import League Cubit
import 'features/league/logic/league_cubit.dart'; 

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
        BlocProvider(create: (context) => MarketCubit()), 
        // [BARU] Tambahkan Provider Liga & Init
        BlocProvider(create: (context) => LeagueCubit()..initLeague()),
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