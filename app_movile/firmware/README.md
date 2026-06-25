# AccelerBike - Firmware ESP32

Este directorio contiene el código fuente para el microcontrolador ESP32 encargado de recolectar los datos de velocidad y distancia a través de sensores magnéticos, para luego transmitirlos vía Bluetooth Low Energy (BLE) a la aplicación móvil.

## 📌 Configuración de Hardware (Pinout)
[cite_start]Conexiones físicas requeridas en la placa ESP32[cite: 4]:
* **Sensor Magnético (Pin A):** `D2` (Configurado como INPUT_PULLUP)
* **Sensor Magnético (Pin B):** `D3` (Configurado como INPUT_PULLUP)
* **LED Indicador de Estado:** `D13` (Parpadeo indica funcionamiento/publicidad BLE)

## 📡 Contrato BLE (Bluetooth Low Energy)
[cite_start]Para que la aplicación móvil (Flutter) pueda descubrir y leer los datos de este dispositivo, **debe** suscribirse a los siguientes UUIDs exactos[cite: 2]. Si estos cambian aquí, deben actualizarse en `BleConnectionService.dart`.

* [cite_start]**Service UUID:** `4fafc201-1fb5-459e-8fcc-c5c9c331914b` [cite: 2]
* [cite_start]**Characteristic UUID:** `beb5483e-36e1-4688-b7f5-ea07361b26a8` [cite: 2]

## 📦 Payload de Datos
[cite_start]La ESP32 emite un string en formato JSON con la siguiente estructura[cite: 19, 20]:
```json
{
  "speedKmh": 25.50,
  "distanceKm": 1.25
}