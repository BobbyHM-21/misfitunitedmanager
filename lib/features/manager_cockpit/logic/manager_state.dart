import 'package:equatable/equatable.dart';

abstract class ManagerState extends Equatable {
  const ManagerState();
  @override
  List<Object> get props => [];
}

class ManagerInitial extends ManagerState {}

class ManagerLoading extends ManagerState {}

class ManagerLoaded extends ManagerState {
  final int money;
  final String name;
  final String clubName;
  final String division;
  final String avatarPath;

  // Constructor menggunakan Named Arguments ({...})
  const ManagerLoaded({
    required this.money,
    required this.name,
    required this.clubName,
    required this.division,
    required this.avatarPath,
  });

  @override
  List<Object> get props => [money, name, clubName, division, avatarPath];
}