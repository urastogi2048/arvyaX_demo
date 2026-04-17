import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/ambience.dart';

class AmbienanceRepository {

  Future<List<Ambience>> loadAmbiences() async {
    try {
      final jsonString =
          await rootBundle.loadString('assets/data/ambiences.json');
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((item) => Ambience.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Failed to load ambiences: $e');
    }
  }
}
