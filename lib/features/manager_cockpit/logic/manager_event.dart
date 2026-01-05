import 'package:equatable/equatable.dart';

abstract class ManagerEvent extends Equatable {
  const ManagerEvent();
  @override
  List<Object> get props => [];
}

// Event untuk load data awal
class LoadManagerData extends ManagerEvent {}

// Event untuk ubah uang
class ModifyMoney extends ManagerEvent {
  final int amount;
  const ModifyMoney(this.amount);
  @override
  List<Object> get props => [amount];
}