import 'package:equatable/equatable.dart';

abstract class ManagerEvent extends Equatable {
  const ManagerEvent();

  @override
  List<Object> get props => [];
}

// 1. Event saat aplikasi pertama dibuka
class LoadManagerProfile extends ManagerEvent {}

// 2. Event saat user mengganti nama
class UpdateManagerName extends ManagerEvent {
  final String newName;
  const UpdateManagerName(this.newName);

  @override
  List<Object> get props => [newName];
}

// 3. Event untuk transaksi uang (Beli/Jual/Gaji)
class ModifyMoney extends ManagerEvent {
  final int amount; // Bisa positif (dapat uang) atau negatif (bayar)
  const ModifyMoney(this.amount);

  @override
  List<Object> get props => [amount];
}