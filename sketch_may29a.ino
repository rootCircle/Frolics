#include <LiquidCrystal.h>
#include "DHT.h"

#define DHTPIN 2
#define DHTTYPE DHT11

char data = 0;


int trigger_pin = 3;
int echo_pin = 4;
int Time;

int green_led = A3;
int red_led = A4;

int light_sensor = A0;

int pir_sensor = 5;
int pir_sensor_value;

int buzzer_pin = 7;

const int rs = 8, en = 9, d4 = 10, d5 = 11, d6 = 12, d7 = 13;
int ir_pin = 6;
int ir_obstacle = HIGH;
int ul_Distance = 0;
LiquidCrystal lcd(rs, en, d4, d5, d6, d7);

DHT dht(DHTPIN, DHTTYPE);

void setup() {
  Serial.begin(9600);
  dht.begin();


  pinMode(green_led, OUTPUT);
  pinMode(red_led, OUTPUT);

  pinMode(light_sensor, INPUT);

  pinMode(pir_sensor, INPUT);

  pinMode(ir_pin, INPUT);

  pinMode (trigger_pin, OUTPUT);
  pinMode (echo_pin, INPUT);

  pinMode (buzzer_pin, OUTPUT);

  lcd.begin(16, 2);
  Print("Frolics", "Analog Assistant", 2);
  delay(2000);
}

void loop() {
if(Serial.available() > 0) 
{
data = Serial.read();
}      
switch(data){
  case'A':ultrasonic_dist_sensor();
  break;
  case'B':ir_sensor();
  break;
  case'C':pir_sensor();
  break;
  case'D':dht11();
  break;
  case'E':light_sensor();
  break;
  case'F':buzzer_overwrite();
          tone(buzzer_pin,1000);
  break;
  case'G':led_overwrite();
          ON(red_led);
  break;
  case'H':led_overwrite();
          ON(green_led);
  break;
  case'I':lcd_overwrite();
          Print("Frolics","Overwrite",1);
  break;
  case'J':pir_based_led();
  break;
  case'S':lcd_overwrite();
          Print("No input","Sleeping mode",1);
          break;
  case'Z':buzzer_overwrite();
          led_overwrite();
          lcd_overwrite();
  break;
  default:lcd_overwrite();
          Print("Failed to read data","from the device",1);        
}

  delay(1000);
}


void led_overwrite(){
  OFF(green_led);
  OFF(red_led);
}

void lcd_overwrite(){
  lcd.clear();
}


void buzzer_overwrite(){
  noTone();
}

void pir_based_led(){
  led_overwrite();
  if (pir_sensor_value == 1) {
    tone(buzzer_pin, 1000);
    ON(red_led);
  }
  else {
    noTone(buzzer_pin);
    ON(green_led);
  }
}

void ultrasonic_dist_sensor() {
  ON(trigger_pin);
  delayMicroseconds (10);
  OFF(trigger_pin);
  Time = pulseIn (echo_pin, HIGH);
  ul_Distance = (Time * 0.034) / 2;
  Print("Ultrasonic sens.", "Distance=" + String(ul_Distance) + "cm", 2);
}


void ir_sensor() {
  ir_obstacle = digitalRead(ir_pin);
  String ir_mes = (ir_obstacle == 0) ? "Obstacle" : "Clear";
  Print("Infrared sensor", ir_mes, 2);
}


void pir_sensor(){
   pir_sensor_value = analogRead(pir_sensor);
   String pir_msg = (pir_sensor_value == 1) ? "Motion detected" : "No movement";
   Print("PIR sensor", pir_msg, 2);
   buzzer();
}


void dht11(){
   float h = dht.readHumidity();
  float t = dht.readTemperature();
  if (isnan(h) || isnan(t)) {
    Print("Error!","",1);
    return;
  }

  float hic = dht.computeHeatIndex(t, h, false);

  Print("Temperature and", "Humidity sensor", 2);
  Print("DHT11", "Module", 2);
  Print("Temperature:", String(t) + "C", 2);
  Print("Humidity:", String(h) + "%", 2);
  Print("Heat Index:", String(hic) + "C", 2);
  }
void ON(int pin) {
  digitalWrite(pin, HIGH);
}


void light_sensor(){
  String light_sensor_msg = String(((1023 - analogRead(light_sensor)) / 1023.0) * 100);
  Print("Light Sensor", "Intensity=" + light_sensor_msg + "%", 2);
}

void OFF(int pin) {
  digitalWrite(pin, LOW);
}


void Print(String info, String value, int delay_sec) {
  lcd.clear();
  delay(500);
  lcd.setCursor(0, 0);
  lcd.print(info);
  lcd.setCursor(0, 1);
  lcd.print(value);
  delay(1000 * delay_sec);
}
