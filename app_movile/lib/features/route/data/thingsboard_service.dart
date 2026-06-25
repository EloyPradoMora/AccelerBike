import 'package:app_movile/core/network/thingsboard_client.dart';
import 'model/trip_summary.dart';

class ThingsBoardService {
  final ThingsBoardClient _client;

  ThingsBoardService({ThingsBoardClient? client})
      : _client = client ??
            const ThingsBoardClient(
              baseUrl: String.fromEnvironment('THINGSBOARD_URL', defaultValue: 'https://thingsboard.cloud'),
              accessToken: String.fromEnvironment('THINGSBOARD_TOKEN', defaultValue: ''),
            );

  Future<bool> sendTripSummary(TripSummary summary) async {
    final payload = summary.toThingsBoardPayload();
    return _client.postTelemetry(payload); 
  }
}