import 'package:equatable/equatable.dart';

abstract class ManagerEvent extends Equatable {
  const ManagerEvent();

  @override
  List<Object> get props => [];
}

// 1. Load Profile
class LoadManagerProfile extends ManagerEvent {}

// 2. Update Nama
class UpdateManagerName extends ManagerEvent {
  final String newName;
  const UpdateManagerName(this.newName);

  @override
  List<Object> get props => [newName];
}

// 3. Transaksi Uang
class ModifyMoney extends ManagerEvent {
  final int amount;
  // Pastikan ada const di sini
  const ModifyMoney(this.amount);

  @override
  List<Object> get props => [amount];
}

abstract class ManagerState extends Equatable {
  const ManagerState();
  @override
  List<Object> get props => [];
}

class ManagerInitial extends ManagerState {}

// [BARU] State saat sedang membaca memori HP
class ManagerLoading extends ManagerState {}

class ManagerLoaded extends ManagerState {
  final int money;
  const ManagerLoaded(this.money);
  @override
  List<Object> get props => [money];
}