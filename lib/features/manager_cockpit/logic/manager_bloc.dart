import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/save_service.dart';
import 'manager_event.dart';
import 'manager_state.dart';

class ManagerBloc extends Bloc<ManagerEvent, ManagerState> {
  // Data Profil Manager (Bisa dijadikan final)
  final String _managerName = "Manager";
  final String _clubName = "Misfit United";
  final String _division = "Division 3";
  final String _avatarPath = "assets/images/avatar_manager.png";
  
  // Data Dinamis
  int _currentMoney = 500; 

  ManagerBloc() : super(ManagerInitial()) {
    
    // 1. LOGIC LOAD DATA
    on<LoadManagerData>((event, emit) async {
      emit(ManagerLoading());
      
      // Ambil data uang dari HP
      final savedMoney = await SaveService.loadMoney();
      if (savedMoney != null) {
        _currentMoney = savedMoney;
      } else {
        _currentMoney = 50000;
      }
      
      // Kirim State Lengkap (Named Arguments)
      emit(ManagerLoaded(
        money: _currentMoney,
        name: _managerName,
        clubName: _clubName,
        division: _division,
        avatarPath: _avatarPath,
      ));
    });

    // 2. LOGIC UBAH UANG
    on<ModifyMoney>((event, emit) {
      // Hitung uang baru
      _currentMoney += event.amount;

      // Simpan
      SaveService.saveMoney(_currentMoney);
      
      // Emit State Lengkap
      emit(ManagerLoaded(
        money: _currentMoney,
        name: _managerName,
        clubName: _clubName,
        division: _division,
        avatarPath: _avatarPath,
      ));
    });
  }
}