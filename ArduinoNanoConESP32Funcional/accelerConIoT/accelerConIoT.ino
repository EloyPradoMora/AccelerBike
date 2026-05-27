#include "arduino_secrets.h"
#include <WiFi.h>
#include <BlynkSimpleEsp32.h>

char auth[] = BLYNK_AUTH_TOKEN;
char ssid[] = "moto g35 5G_5931";
char pass[] = "12345678";

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
  
  Blynk.begin(auth, ssid, pass);
  Serial.println("Blynk connected and system ready!");
}

void loop() {
  Blynk.run();
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

    Blynk.virtualWrite(V1, speedKmh);
    Blynk.virtualWrite(V2, distanceKm);
    
    lastUpdate = millis();
  }
}