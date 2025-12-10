import 'package:flutter/material.dart';
import 'dart:convert'; // WAJIB: Untuk mengubah List jadi JSON String

class Wisata {
  final String id;
  final String name;
  final String location;
  final String description;

  // HAPUS String imageAsset YANG LAMA
  // GANTI DENGAN LIST INI:
  final List<String> imagePaths;

  final double rating;
  final String price;
  final double latitude;
  final double longitude;
  final TimeOfDay openTime;
  final TimeOfDay closeTime;
  final String category;

  Wisata({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.imagePaths, // Constructor wajib minta List
    required this.rating,
    required this.price,
    required this.latitude,
    required this.longitude,
    required this.openTime,
    required this.closeTime,
    required this.category,
  });

  String _timeToString(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  static TimeOfDay _stringToTime(String timeStr) {
    final parts = timeStr.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'description': description,
      // DI DATABASE TETAP DISIMPAN SEBAGAI 'imageAsset' AGAR TIDAK PERLU HAPUS TABEL LAMA
      // TAPI ISINYA ADALAH JSON STRING DARI LIST
      'imageAsset': jsonEncode(imagePaths),
      'rating': rating,
      'price': price,
      'latitude': latitude,
      'longitude': longitude,
      'openTime': _timeToString(openTime),
      'closeTime': _timeToString(closeTime),
      'category': category,
    };
  }

  factory Wisata.fromMap(Map<String, dynamic> map) {
    // LOGIKA DECODE: Mengubah String JSON kembali menjadi List<String>
    List<String> images = [];
    try {
      if (map['imageAsset'] != null) {
        var decoded = jsonDecode(map['imageAsset']);
        if (decoded is List) {
          images = List<String>.from(decoded);
        } else {
          // Jika format lama (cuma string biasa), masukkan ke list sebagai item pertama
          images = [map['imageAsset'].toString()];
        }
      }
    } catch (e) {
      // Jika jsonDecode gagal (misal data korup/format lama), jadikan string biasa
      if (map['imageAsset'] != null) {
        images = [map['imageAsset'].toString()];
      }
    }

    return Wisata(
      id: map['id'],
      name: map['name'],
      location: map['location'],
      description: map['description'],
      imagePaths: images, // Masukkan List yang sudah diproses
      rating: map['rating'] is int
          ? (map['rating'] as int).toDouble()
          : (map['rating'] as double),
      price: map['price'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      openTime: _stringToTime(map['openTime']),
      closeTime: _stringToTime(map['closeTime']),
      category: map['category'] ?? 'Lainnya',
    );
  }
}
