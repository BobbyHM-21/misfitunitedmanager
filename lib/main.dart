import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_colors.dart';

// Import Blocs & Events
import 'features/manager_cockpit/logic/manager_bloc.dart';
import 'features/manager_cockpit/logic/manager_event.dart'; 
import 'features/squad_management/logic/squad_bloc.dart';
import 'features/squad_management/logic/squad_event.dart';
import 'features/transfer_market/logic/market_cubit.dart';
import 'features/league/logic/league_cubit.dart';

// Import Screen
import 'features/manager_cockpit/presentation/pages/cockpit_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // 1. Manager Bloc: Trigger Load Data
        BlocProvider<ManagerBloc>(
          create: (context) => ManagerBloc()..add(LoadManagerData()),
        ),
        
        // 2. Squad Bloc: Trigger Load Squad
        BlocProvider<SquadBloc>(
          create: (context) => SquadBloc()..add(LoadSquad()),
        ),
        
        // 3. Market Cubit
        BlocProvider<MarketCubit>(
          create: (context) => MarketCubit(),
        ),

        // 4. League Cubit -> [FIX] Gunakan initLeague()
        BlocProvider<LeagueCubit>(
          create: (context) => LeagueCubit()..initLeague(), 
        ),
      ],
      child: MaterialApp(
        title: 'Misfit United Manager',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: AppColors.electricCyan,
          scaffoldBackgroundColor: Colors.black,
          fontFamily: 'Roboto', 
          colorScheme: ColorScheme.fromSwatch().copyWith(
            secondary: AppColors.neonYellow,
            brightness: Brightness.dark, 
          ),
        ),
        home: const CockpitScreen(),
      ),
    );
  }
}