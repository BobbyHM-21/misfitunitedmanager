import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/save_service.dart';
import 'manager_event.dart';
import 'manager_state.dart';

class ManagerBloc extends Bloc<ManagerEvent, ManagerState> {
  // Default Data
  int _currentMoney = 500;
  String _managerName = "Manager";
  String _clubName = "Misfit United";
  String _division = "Division 3";
  String _avatarPath = "assets/images/avatar_manager.png";

  ManagerBloc() : super(ManagerInitial()) {
    
    // 1. LOGIC LOAD DATA
    on<LoadManagerData>((event, emit) async {
      emit(ManagerLoading()); 
      
      // Load Money
      final savedMoney = await SaveService.loadMoney();
      if (savedMoney != null) {
        _currentMoney = savedMoney;
      } else {
        _currentMoney = 500;
      }
      
      // Emit State with ALL required fields
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
      if (state is ManagerLoaded) {
        // Update money based on previous state
        _currentMoney = (state as ManagerLoaded).money + event.amount;
      } else {
        // Fallback if state wasn't loaded
        _currentMoney += event.amount;
      }

      // Save to storage
      SaveService.saveMoney(_currentMoney);
      
      // Emit State with ALL required fields
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