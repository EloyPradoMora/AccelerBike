#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

BLEServer* pServer = NULL;
BLECharacteristic* pCharacteristicTX = NULL; // Para enviar datos a la app
BLECharacteristic* pCharacteristicRX = NULL; // Para recibir datos de la app
bool deviceConnected = false;
bool oldDeviceConnected = false;

#define SERVICE_UUID           "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define CHARACTERISTIC_UUID_TX "beb5483e-36e1-4688-b7f5-ea07361b26a8"
#define CHARACTERISTIC_UUID_RX "beb5483e-36e1-4688-b7f5-ea07361b26a9" // UUID para recibir el aro

float currentAro = 0.0; 
float wheelCircumference = 0.0;
bool waitingForAro = true;

class MyServerCallbacks: public BLEServerCallbacks {
    void onConnect(BLEServer* pServer) {
      deviceConnected = true;
      waitingForAro = true;
    };

    void onDisconnect(BLEServer* pServer) {
      deviceConnected = false;
    }
};

class MyCharacteristicCallbacks: public BLECharacteristicCallbacks {
    void onWrite(BLECharacteristic *pChar) {
      std::string rxValue = pChar->getValue();
      float newAro = 0.0;
      
      if (rxValue.length() > 0) {
        String valueStr = String(rxValue.c_str());
        newAro = valueStr.toFloat();
      }
      
      if (newAro <= 0.0) {
        newAro = 35.0;
        Serial.println("Advertencia: Valor nulo o cero recibido. Aplicando aro de fallback (35.0\").");
      }
      
      currentAro = newAro;
      wheelCircumference = currentAro * 0.0254 * PI;
      waitingForAro = false;
      
      Serial.print("Aro configurado: ");
      Serial.print(currentAro);
      Serial.print("\" -> Circunferencia: ");
      Serial.print(wheelCircumference);
      Serial.println(" m");
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

  BLEDevice::init("ESP32_AccelerBike");
  
  BLESecurity *pSecurity = new BLESecurity();
  pSecurity->setAuthenticationMode(ESP_LE_AUTH_REQ_SC_BOND);
  pSecurity->setCapability(ESP_IO_CAP_NONE);
  pSecurity->setInitEncryptionKey(ESP_BLE_ENC_KEY_MASK | ESP_BLE_ID_KEY_MASK);

  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());

  BLEService *pService = pServer->createService(SERVICE_UUID);

  pCharacteristicTX = pService->createCharacteristic(
                        CHARACTERISTIC_UUID_TX,
                        BLECharacteristic::PROPERTY_READ   |
                        BLECharacteristic::PROPERTY_NOTIFY
                      );
  pCharacteristicTX->addDescriptor(new BLE2902());

  pCharacteristicRX = pService->createCharacteristic(
                        CHARACTERISTIC_UUID_RX,
                        BLECharacteristic::PROPERTY_WRITE
                      );
  pCharacteristicRX->setCallbacks(new MyCharacteristicCallbacks());

  pService->start();

  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  
  pAdvertising->setScanResponse(true); 
  pAdvertising->setMinPreferred(0x06);
  
  BLEDevice::startAdvertising();
  
  Serial.println("BLE iniciado. Dispositivo listo para emparejar.");
}

void loop() {
  unsigned long currentMillis = millis();

  if (deviceConnected) {
    if (currentMillis - lastBlinkTime >= blinkInterval) {
      lastBlinkTime = currentMillis;
      ledState = !ledState;
      digitalWrite(ledPin, ledState);
    }
  } else {
    ledState = LOW;
    digitalWrite(ledPin, LOW);
  }

  static unsigned long lastUpdate = 0;
  if (millis() - lastUpdate > 500) {
    
    if (deviceConnected) {
      if (waitingForAro) {
        // Pedir el aro a la app mediante JSON
        String requestPayload = "{\"request\":\"send_aro\"}";
        pCharacteristicTX->setValue(requestPayload.c_str());
        pCharacteristicTX->notify();
        Serial.println("Esperando aro de la app...");
      } 
      else {
        // Modo normal: Calcular y enviar velocidad/distancia
        float speedKmh = 0;
        
        if (pulseInterval > 0 && (millis() - lastPulseTime < 3000)) {
           speedKmh = (wheelCircumference / (pulseInterval / 1000.0)) * 3.6;
        }

        float distanceKm = (pulseCount * wheelCircumference) / 1000.0;

        String payload = "{";
        payload += "\"speedKmh\":";
        payload += String(speedKmh, 2);
        payload += ",";
        payload += "\"distanceKm\":";
        payload += String(distanceKm, 2);
        payload += "}";

        pCharacteristicTX->setValue(payload.c_str());
        pCharacteristicTX->notify();
        
        Serial.print("Enviando datos: ");
        Serial.println(payload);
      }
    }
    
    lastUpdate = millis();
  }

  if (!deviceConnected && oldDeviceConnected) {
      delay(500);
      pServer->startAdvertising(); 
      Serial.println("Dispositivo desconectado. Re-iniciando advertising...");
      oldDeviceConnected = deviceConnected;
  }
  
  if (deviceConnected && !oldDeviceConnected) {
      oldDeviceConnected = deviceConnected;
      Serial.println("Dispositivo conectado.");
  }
}