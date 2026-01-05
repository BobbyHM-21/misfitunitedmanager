import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/squad_management/data/player_model.dart';

class SaveService {
  static const String KEY_MONEY = 'manager_money';
  static const String KEY_SQUAD = 'my_squad_list';
  // [BARU] Key untuk Data Liga (Jadwal, Klasemen, Top Skor)
  static const String KEY_LEAGUE_DATA = 'league_data_full_v1';

  // ... (Method saveMoney dan saveSquad yang lama TETAP DISINI, jangan dihapus) ...
  
  static Future<void> saveMoney(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(KEY_MONEY, amount);
  }

  static Future<int?> loadMoney() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(KEY_MONEY);
  }

  static Future<void> saveSquad(List<Player> players) async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> jsonList = players.map((p) => p.toJson()).toList();
    await prefs.setString(KEY_SQUAD, json.encode(jsonList));
  }

  static Future<List<Player>?> loadSquad() async {
    final prefs = await SharedPreferences.getInstance();
    String? encodedData = prefs.getString(KEY_SQUAD);
    if (encodedData == null) return null;
    List<dynamic> decodedList = json.decode(encodedData);
    return decodedList.map((json) => Player.fromJson(json)).toList();
  }

  // --- [FITUR BARU] SAVE LEAGUE ---
  // Menyimpan seluruh state liga dalam satu paket JSON agar konsisten
  static Future<void> saveLeague(Map<String, dynamic> leagueData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(KEY_LEAGUE_DATA, json.encode(leagueData));
  }

  static Future<Map<String, dynamic>?> loadLeague() async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString(KEY_LEAGUE_DATA);
    if (data == null) return null;
    return json.decode(data);
  }
}