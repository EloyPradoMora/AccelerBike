import processing.serial.*;

Serial miPuerto;
float circ = 2.0735; 
int tUltimo = 0;
float vel = 0.0;
float dist = 0.0;
int pulsos = 0;
String dirOled = "-";
float angAct = 0.0;
int angAnt = -1;

void setup() {
  size(500, 300);
  miPuerto = new Serial(this, Serial.list()[0], 9600);
  delay(2000);
  tUltimo = millis();
}

void draw() {
  background(30);
  
  while (miPuerto.available() > 0) {
    String raw = trim(miPuerto.readStringUntil('\n'));
    if (raw == null) continue;

    if (raw.equals("PULSO_F") || raw.equals("PULSO_B")) {
      int ahora = millis();
      float dt = (ahora - tUltimo) / 1000.0;
      
      if (dt > 0.15) {
        if (raw.equals("PULSO_F")) {
          vel = (1.0 / dt) * circ * 3.6;
          dirOled = "ADELANTE";
        } else {
          vel = 0; 
          dirOled = "-";
        }
        
        tUltimo = ahora;
        pulsos++;
        dist = pulsos * circ;
        
        String dStr = (dist < 1000) ? nf(dist, 0, 1) + "m" : nf(dist/1000, 0, 2) + "km";
        String vStrOled = nf(vel, 0, 1); // Solo el numero para la OLED
        
        miPuerto.write("D" + vStrOled + "|" + dStr + "|" + dirOled + "\n");
      }
    }
  }

  if (millis() - tUltimo > 2500) {
    vel = 0;
    dirOled = "-";
    if (frameCount % 60 == 0) {
       String dStr = (dist < 1000) ? nf(dist, 0, 1) + "m" : nf(dist/1000, 0, 2) + "km";
       miPuerto.write("D0.0|" + dStr + "|-\n");
    }
  }
  
  float angObj = constrain(map(vel, 0, 40, 179, 0), 0, 179);
  angAct = lerp(angAct, angObj, 0.05);
  int enviar = int(angAct);
  
  if (enviar != angAnt) {
    miPuerto.write("S" + enviar + "\n");
    angAnt = enviar;
  }

  // Vista en el pc
  fill(255); textSize(20);
  text("AccelerBike", 20, 40);
  fill(100, 255, 100); textSize(50);
  text(nf(vel, 0, 1) + " km/h", 20, 100);
  fill(255, 200, 0); textSize(25);
  text("Distancia: " + ((dist < 1000) ? nf(dist, 0, 1) + " m" : nf(dist/1000, 0, 2) + " km"), 20, 150);
  text("Direccion: " + dirOled, 20, 190);
}
