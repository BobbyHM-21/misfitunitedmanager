import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/squad_management/data/player_model.dart';

class SaveService {
  static const String KEY_MONEY = 'manager_money';
  static const String KEY_SQUAD = 'my_squad_list';

  // --- LOGIC UANG ---
  
  // Simpan Uang
  static Future<void> saveMoney(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(KEY_MONEY, amount);
  }

  // Load Uang
  static Future<int?> loadMoney() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(KEY_MONEY);
  }

  // --- LOGIC SKUAD (Pemain, XP, Stats) ---

  // Simpan Skuad
  static Future<void> saveSquad(List<Player> players) async {
    final prefs = await SharedPreferences.getInstance();
    // 1. Convert List<Player> jadi List<Map> (JSON)
    List<Map<String, dynamic>> jsonList = players.map((p) => p.toJson()).toList();
    // 2. Encode jadi String panjang
    String encodedData = json.encode(jsonList);
    // 3. Simpan ke HP
    await prefs.setString(KEY_SQUAD, encodedData);
  }

  // Load Skuad
  static Future<List<Player>?> loadSquad() async {
    final prefs = await SharedPreferences.getInstance();
    String? encodedData = prefs.getString(KEY_SQUAD);

    if (encodedData == null) return null; // Belum ada save data

    // 1. Decode String jadi List
    List<dynamic> decodedList = json.decode(encodedData);
    // 2. Convert balik jadi List<Player>
    List<Player> loadedPlayers = decodedList.map((json) => Player.fromJson(json)).toList();
    
    return loadedPlayers;
  }
  
  // Reset Data (Untuk Debugging/New Game)
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}