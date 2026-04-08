#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>
#include <Servo.h>

#define SCREEN_WIDTH 128
#define SCREEN_HEIGHT 32
Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, -1);

const int pinS1 = 2; 
const int pinS2 = 3; 
const int pinServo = 9;  
Servo miServo;

const int enfriamiento = 75; 
int antS1 = HIGH; 
int antS2 = HIGH;
unsigned long tS1 = 0;
unsigned long tS2 = 0;
int secuencia = 0; 

void setup() {
  Serial.begin(9600); 
  Serial.setTimeout(10);
  pinMode(pinS1, INPUT_PULLUP);
  pinMode(pinS2, INPUT_PULLUP);
  miServo.attach(pinServo);
  
  if(!display.begin(SSD1306_SWITCHCAPVCC, 0x3C)) {
    for(;;);
  }
  actualizarOLED("0.0", "0.0", "LISTO");
}

void loop() {
  int s1 = digitalRead(pinS1);
  int s2 = digitalRead(pinS2);
  unsigned long ahora = millis();

  if (s1 == LOW && antS1 == HIGH && (ahora - tS1 > enfriamiento)) {
    if (secuencia == 2) { Serial.println("PULSO_B"); secuencia = 0; }
    else { secuencia = 1; }
    tS1 = ahora;
  }
  if (s2 == LOW && antS2 == HIGH && (ahora - tS2 > enfriamiento)) {
    if (secuencia == 1) { Serial.println("PULSO_F"); secuencia = 0; }
    else { secuencia = 2; }
    tS2 = ahora;
  }

  if (ahora - max(tS1, tS2) > 1000) { 
    secuencia = 0; 
  }

  antS1 = s1; antS2 = s2;

  if (Serial.available() > 0) {
    String cmd = Serial.readStringUntil('\n');
    cmd.trim();
    if (cmd.length() > 0) {
      if (cmd.charAt(0) == 'S') {
        miServo.write(cmd.substring(1).toInt());
      } else if (cmd.charAt(0) == 'D') {
        int sep1 = cmd.indexOf('|');
        int sep2 = cmd.lastIndexOf('|');
        if (sep1 != -1 && sep2 != -1) {
          String v = cmd.substring(1, sep1);
          String d = cmd.substring(sep1 + 1, sep2);
          String dir = cmd.substring(sep2 + 1);
          actualizarOLED(v, d, dir);
        }
      }
    }
  }
  delay(5);
}

void actualizarOLED(String v, String d, String dir) {
  display.clearDisplay();
  display.setTextColor(WHITE);
  
  display.setTextSize(1);
  display.setCursor(0, 0);  
  display.print("D: " + d);
  
  display.setCursor(0, 20); 
  display.print(dir); 
  
  display.setTextSize(2);
  display.setCursor(64, 4);
  display.print(v);
  
  display.setTextSize(1);
  display.setCursor(64, 22);
  display.print("km/h");

  display.display();
}