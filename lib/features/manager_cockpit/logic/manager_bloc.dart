import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_assets.dart';
import 'manager_event.dart';
import 'manager_state.dart';

class ManagerBloc extends Bloc<ManagerEvent, ManagerState> {
  ManagerBloc() : super(ManagerInitial()) {
    
    // 1. Saat Aplikasi Mulai -> Load Data Dummy Awal
    on<LoadManagerProfile>((event, emit) async {
      // Simulasi delay loading (biar berasa canggih)
      await Future.delayed(const Duration(seconds: 1));
      
      emit(const ManagerLoaded(
        name: "NOOB MANAGER",
        clubName: "STREET RATS FC",
        money: 50000, // Modal Awal
        division: 10,
        avatarPath: AppAssets.avatarManager,
      ));
    });

    // 2. Saat Ganti Nama
    on<UpdateManagerName>((event, emit) {
      if (state is ManagerLoaded) {
        final currentState = state as ManagerLoaded;
        emit(currentState.copyWith(name: event.newName));
      }
    });

    // 3. Saat Uang Berubah
    on<ModifyMoney>((event, emit) {
      if (state is ManagerLoaded) {
        final currentState = state as ManagerLoaded;
        final newMoney = currentState.money + event.amount;
        
        // Cegah uang minus
        if (newMoney >= 0) {
          emit(currentState.copyWith(money: newMoney));
        }
      }
    });
  }
}