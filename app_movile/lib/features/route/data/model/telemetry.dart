
class Telemetry {
  final double speedKmh;
  final double distanceKm;

  const Telemetry({required this.speedKmh, required this.distanceKm});

  // Estado por defecto | 0 | 0 |
  factory Telemetry.empty() => const Telemetry(speedKmh: 0, distanceKm: 0);

  /* 
    De momento parcea un Json ya que es lo que se encuentra de momento 
    en el archivo ArduinoNanoConESP32Funcional/accelerConIoT/accelerConIoT.ino
  */
  factory Telemetry.fromJson(Map<String, dynamic> json) => Telemetry(
        speedKmh: (json['speedKmh'] as num).toDouble(),
        distanceKm: (json['distanceKm'] as num).toDouble(),
  );
}