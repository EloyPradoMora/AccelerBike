class TripSummary {
  final double maxSpeedKmh;
  final double avgSpeedKmh;
  final double distanceKm;
  final int durationSeconds;

  const TripSummary({
    required this.maxSpeedKmh,
    required this.avgSpeedKmh,
    required this.distanceKm,
    required this.durationSeconds,
  });

  Map<String, dynamic> toThingsBoardPayload() => {
        'maxSpeedKmh': double.parse(maxSpeedKmh.toStringAsFixed(2)),
        'avgSpeedKmh': double.parse(avgSpeedKmh.toStringAsFixed(2)),
        'distanceKm': double.parse(distanceKm.toStringAsFixed(2)),
        'durationSeconds': durationSeconds,
      };
}