import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

class Account extends Equatable {
  final String id;
  final String name;
  final String email;
  final String displayName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int level;
  final double gold;
  final int gems;
  final int energy;

  Account({
    String? id,
    required this.name,
    required this.email,
    required this.displayName,
    required this.createdAt,
    required this.updatedAt,
    required this.level,
    required this.gold,
    required this.gems,
    required this.energy,
  }) : id = id ?? const Uuid().v4();

  Account copyWith({
    String? id,
    String? name,
    String? email,
    String? displayName,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? level,
    double? gold,
    int? gems,
    int? energy,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      level: level ?? this.level,
      gold: gold ?? this.gold,
      gems: gems ?? this.gems,
      energy: energy ?? this.energy,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        displayName,
        createdAt,
        updatedAt,
        level,
        gold,
        gems,
        energy,
      ];

  @override
  String toString() {
    return 'Account('
        'id: $id, '
        'name: $name, '
        'email: $email, '
        'displayName: $displayName, '
        'level: $level, '
        'gold: $gold, '
        'gems: $gems, '
        'energy: $energy'
        ')';
  }
}
