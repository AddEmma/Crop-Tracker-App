import 'dart:convert';
import 'package:flutter/material.dart';

enum CropStatus { growing, ready, harvested }

class Crop {
  final String id;
  final String name;
  final DateTime plantingDate;
  final DateTime expectedHarvestDate;
  final String notes;
  final CropStatus status;

  Crop({
    required this.id,
    required this.name,
    required this.plantingDate,
    required this.expectedHarvestDate,
    this.notes = '',
    this.status = CropStatus.growing,
  });

  // Copy constructor for updates
  Crop copyWith({
    String? id,
    String? name,
    DateTime? plantingDate,
    DateTime? expectedHarvestDate,
    String? notes,
    CropStatus? status,
  }) {
    return Crop(
      id: id ?? this.id,
      name: name ?? this.name,
      plantingDate: plantingDate ?? this.plantingDate,
      expectedHarvestDate: expectedHarvestDate ?? this.expectedHarvestDate,
      notes: notes ?? this.notes,
      status: status ?? this.status,
    );
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'plantingDate': plantingDate.toIso8601String(),
      'expectedHarvestDate': expectedHarvestDate.toIso8601String(),
      'notes': notes,
      'status': status.index,
    };
  }

  factory Crop.fromJson(Map<String, dynamic> json) {
    return Crop(
      id: json['id'],
      name: json['name'],
      plantingDate: DateTime.parse(json['plantingDate']),
      expectedHarvestDate: DateTime.parse(json['expectedHarvestDate']),
      notes: json['notes'] ?? '',
      status: CropStatus.values[json['status'] ?? 0],
    );
  }

  String get statusText {
    switch (status) {
      case CropStatus.growing:
        return 'Growing';
      case CropStatus.ready:
        return 'Ready';
      case CropStatus.harvested:
        return 'Harvested';
    }
  }

  Color get statusColor {
    switch (status) {
      case CropStatus.growing:
        return const Color(0xFF4CAF50); // Green
      case CropStatus.ready:
        return const Color(0xFFFF9800); // Orange
      case CropStatus.harvested:
        return const Color(0xFF8D6E63); // Brown
    }
  }
}
