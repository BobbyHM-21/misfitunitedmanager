import 'package:equatable/equatable.dart';

// Status Dasar
abstract class ManagerState extends Equatable {
  const ManagerState();
  
  @override
  List<Object> get props => [];
}

// Kondisi Awal (Loading)
class ManagerInitial extends ManagerState {}

// Kondisi Utama (Data Siap Tampil)
class ManagerLoaded extends ManagerState {
  final String name;
  final String clubName;
  final int money; // Mata uang Misfits ($)
  final int division;
  final String avatarPath;

  const ManagerLoaded({
    required this.name,
    required this.clubName,
    required this.money,
    required this.division,
    required this.avatarPath,
  });

  // Fitur "CopyWith" untuk update data parsial dengan aman
  ManagerLoaded copyWith({
    String? name,
    String? clubName,
    int? money,
    int? division,
    String? avatarPath,
  }) {
    return ManagerLoaded(
      name: name ?? this.name,
      clubName: clubName ?? this.clubName,
      money: money ?? this.money,
      division: division ?? this.division,
      avatarPath: avatarPath ?? this.avatarPath,
    );
  }

  @override
  List<Object> get props => [name, clubName, money, division, avatarPath];
}