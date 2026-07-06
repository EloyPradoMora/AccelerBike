import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  SupabaseClient get client => _client;

  Future<void> signInAnonymously() async {
    await _client.auth.signInAnonymously();
  }

  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<bool> signUp({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
    );
    return response.session == null;
  }

  Future<void> saveInitialUserName({required String name}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_display_name', name);
    } catch (e) {
      debugPrint('Error al guardar nombre: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getUserTrips() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return []; 
      final response = await _client.from('trips').select().eq('user_id', userId);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error al obtener trips: $e');
      return [];
    }
  }

  Future<String> getUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('user_display_name') ?? 'Ciclista';
    } catch (_) {
      return 'Ciclista';
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<void> saveTrip({
    required String userId,
    required double totalDistance,
    required double maxSpeed,
    required double avgSpeed,   
    required int duration,
  }) async {
    try {
      await _client.from('trips').insert({
        'user_id': userId,
        'total_distance_km': totalDistance,
        'max_speed_kmh': maxSpeed,
        'avg_speed_kmh': avgSpeed,
        'duration_seconds': duration,
      });
    } catch (e) {
      throw Exception('Error al guardar el viaje en SUPABASE: $e');
    }
  }
}
final supabaseService = SupabaseService();