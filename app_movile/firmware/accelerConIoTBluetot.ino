#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

BLEServer* pServer = NULL;
BLECharacteristic* pCharacteristic = NULL;
bool deviceConnected = false;
bool oldDeviceConnected = false;

// UUIDs para el Servicio y la Caracteristica (necesitaras estos en Flutter)
#define SERVICE_UUID        "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define CHARACTERISTIC_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"

class MyServerCallbacks: public BLEServerCallbacks {
    void onConnect(BLEServer* pServer) {
      deviceConnected = true;
    };

    void onDisconnect(BLEServer* pServer) {
      deviceConnected = false;
    }
};

const int pinA = D2; 
const int pinB = D3;
const int ledPin = D13;

volatile int pulseCount = 0;
volatile unsigned long lastPulseTime = 0;
volatile unsigned long pulseInterval = 0;
volatile bool lastDirectionForward = true;
volatile bool newPulseDetected = false;

const float circumference = 2.26;

unsigned long lastBlinkTime = 0;
const long blinkInterval = 500;
bool ledState = LOW;

void IRAM_ATTR handleSensorA() {
  unsigned long now = millis();
  if (now - lastPulseTime > 150) { 
    if (digitalRead(pinB) == HIGH) { 
      lastDirectionForward = true;
      pulseInterval = now - lastPulseTime;
      lastPulseTime = now;
      pulseCount++;
      newPulseDetected = true;
    } else {
      lastDirectionForward = false;
    }
  }
}

void setup() {
  Serial.begin(115200);
  
  pinMode(pinA, INPUT_PULLUP);
  pinMode(pinB, INPUT_PULLUP);
  pinMode(ledPin, OUTPUT);
  
  attachInterrupt(digitalPinToInterrupt(pinA), handleSensorA, FALLING);

  // Inicializacion del dispositivo BLE
  BLEDevice::init("ESP32_AccelerBike");
  
  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());

  BLEService *pService = pServer->createService(SERVICE_UUID);

  pCharacteristic = pService->createCharacteristic(
                      CHARACTERISTIC_UUID,
                      BLECharacteristic::PROPERTY_READ   |
                      BLECharacteristic::PROPERTY_NOTIFY
                    );

  // Descriptor necesario para que el cliente (Flutter) pueda suscribirse a las notificaciones
  pCharacteristic->addDescriptor(new BLE2902());

  pService->start();

  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(false);
  pAdvertising->setMinPreferred(0x0); 
  BLEDevice::startAdvertising();
  
  Serial.println("BLE iniciado. Dispositivo listo para emparejar.");
}

void loop() {
  unsigned long currentMillis = millis();
  if (currentMillis - lastBlinkTime >= blinkInterval) {
    lastBlinkTime = currentMillis;
    ledState = !ledState;
    digitalWrite(ledPin, ledState);
  }

  static unsigned long lastUpdate = 0;
  if (millis() - lastUpdate > 500) {
    float speedKmh = 0;
    
    if (pulseInterval > 0 && (millis() - lastPulseTime < 3000)) {
       speedKmh = (circumference / (pulseInterval / 1000.0)) * 3.6;
    }

    float distanceKm = (pulseCount * circumference) / 1000.0;

    String payload = "{";
    payload += "\"speedKmh\":";
    payload += String(speedKmh, 2);
    payload += ",";
    payload += "\"distanceKm\":";
    payload += String(distanceKm, 2);
    payload += "}";

    // Solo enviamos datos si hay un dispositivo conectado escuchando
    if (deviceConnected) {
        pCharacteristic->setValue(payload.c_str());
        pCharacteristic->notify();
        Serial.print("Enviando datos por BLE: ");
        Serial.println(payload);
    }
    
    lastUpdate = millis();
  }

  // Manejo de desconexion
  if (!deviceConnected && oldDeviceConnected) {
      delay(500); 
      pServer->startAdvertising(); 
      Serial.println("Dispositivo desconectado. Re-iniciando advertising...");
      oldDeviceConnected = deviceConnected;
  }
  
  // Manejo de conexion
  if (deviceConnected && !oldDeviceConnected) {
      oldDeviceConnected = deviceConnected;
      Serial.println("Dispositivo conectado.");
  }
}