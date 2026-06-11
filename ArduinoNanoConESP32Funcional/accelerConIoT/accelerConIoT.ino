#include <WiFi.h>
#include <PubSubClient.h>
#include "arduino_secrets.h"

// credenciales wifi
const char* ssid = "moto g35 5G_5931";
const char* pass = "12345678";

// Configuracion thingsboard
const char* tb_server = IP_SERVIDOR; 
const int tb_port = 1883;              
const char* tb_token = TOKEN_THINGSBOARD; 

WiFiClient espClient;
PubSubClient client(espClient);

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

void setup_wifi() {
  Serial.print("Conectando a la red WiFi: ");
  Serial.println(ssid);
  WiFi.begin(ssid, pass);
  
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nWiFi conectado exitosamente");
}

void reconnect() {
  while (!client.connected()) {
    Serial.print("Conectando a ThingsBoard");
    if (client.connect("ESP32_AccelerBike", tb_token, NULL)) {
      Serial.println(" Conectado a ThingsBoard");
    } else {
      Serial.print(" Fallo en conexion, rc=");
      Serial.print(client.state());
      Serial.println(" intentando de nuevo en 5 segundos");
      delay(5000);
    }
  }
}

void setup() {
  Serial.begin(115200);
  
  pinMode(pinA, INPUT_PULLUP);
  pinMode(pinB, INPUT_PULLUP);
  pinMode(ledPin, OUTPUT);
  
  attachInterrupt(digitalPinToInterrupt(pinA), handleSensorA, FALLING);
  
  setup_wifi();
  
  client.setServer(tb_server, tb_port);
}

void loop() {
  if (!client.connected()) {
    reconnect();
  }
  client.loop();

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

    // creacion de payload JSON 
    String payload = "{";
    payload += "\"speedKmh\":";
    payload += speedKmh;
    payload += ",";
    payload += "\"distanceKm\":";
    payload += distanceKm;
    payload += "}";

    // publicacion de telemetria en thingsboard
    client.publish("v1/devices/me/telemetry", payload.c_str());
    
    // imprimir por el puerto serie
    Serial.print("Enviando datos: ");
    Serial.println(payload);
    
    lastUpdate = millis();
  }
}