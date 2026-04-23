import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/report_data.dart';

class OfflineService {
  Database? _db;
  final Database? injectedDb;

  OfflineService({this.injectedDb});

  Future<Database> get database async {
    if (injectedDb != null) return injectedDb!;
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'cidade_alerta_offline.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE pending_reports(id INTEGER PRIMARY KEY AUTOINCREMENT, data TEXT, created_at TEXT)',
        );
      },
    );
  }

  Future<int> saveReportOffline(ReportData report) async {
    final db = await database;
    final String rawData = jsonEncode({
      'category': report.category,
      'title': report.title,
      'description': report.description,
      'photos': report.photos,
      'latitude': report.latitude,
      'longitude': report.longitude,
      'address': report.address,
    });

    return await db.insert('pending_reports', {
      'data': rawData,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getPendingReports() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('pending_reports');

    return maps.map((item) {
      final decoded = jsonDecode(item['data']);
      return {
        'db_id': item['id'],
        'report': ReportData(
          category: decoded['category'],
          title: decoded['title'],
          description: decoded['description'],
          photos: List<String>.from(decoded['photos']),
          latitude: decoded['latitude'],
          longitude: decoded['longitude'],
          address: decoded['address'],
        ),
      };
    }).toList();
  }

  Future<void> deleteReport(int id) async {
    final db = await database;
    await db.delete('pending_reports', where: 'id = ?', whereArgs: [id]);
  }
}