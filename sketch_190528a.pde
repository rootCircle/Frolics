
import processing.serial.*;

Serial port;
PFont f1;
int slide=0;
boolean mousePress;
int timer;
char trig;
String data="";
boolean send=true;
String com="";

int ul_Distance=0;
int ir_state=1;
int pir_state=0;
float light_sensor_value = 0.0;
int buzzer_state=0;
int red_led_state=0;
int green_led_state=0;
float temperature = 0.0;
float humidity = 0.0;
float heat_index = 0.0;


void setup() {
  size(800, 600);
  f1=createFont("Segoe Print", 30);
}


void draw() {
  switch(slide) {
  case 0:
    choosePort();
    break;
    case 1:
     background(28);
    textAlign(CENTER, CENTER);
    textFont(f1);
    fill(#9EFA3D);
    text("Frolics : The analog Assistant", width/2, 35);
    fill(212);
    text("Home", width/2, 105);  
    state_button(width/2-125,300,250,"Send command to Arduino",2);
    state_button(width/2-100,350,200,"See data from Arduino",3);
    break;
  case 2:
    background(28);
    textAlign(CENTER, CENTER);
    textFont(f1);
    fill(#9EFA3D);
    text("Frolics : The analog Assistant", width/2, 35);
    fill(212);
    text("Choose the following button to print on LCD", width/2, 105);  
    button(25, 200, 200, "Ultrasonic sensor", 'a');
    button(25, 250, 200, "Inrared obstacle sensor", 'b');
    button(25, 300, 200, "PIR sensor", 'c');
    button(25, 350, 200, "Photoresistor", 'd');
    button(25, 400, 200, "Buzzer", 'e');
    button(25, 450, 200, "Motion detection module", 'f');
    button(25, 500, 200, "Temperature sensor", 'j');
    button(300, 200, 200, "Red LED", 'g');
    button(300, 250, 200, "Green LED", 'h');
    button(300, 300, 200, "LCD Overwrite", 'i');
    button(300, 350, 200, "Sleep mode", 's');
    button(300, 400, 200, "Hibernating mode", 'z');
    button(300, 450, 200, "Humidity sensor", 'k');
    button(300, 500, 200, "Heat Index (DHT 11)", 'l');
    state_button(550,550,200,"Home",1);
    break;
    case 3:
    background(28);
    textAlign(CENTER, CENTER);
    textFont(f1);
    fill(#9EFA3D);
    text("Frolics : The analog Assistant", width/2, 35);
    fill(212);
    text("Click to view data from Arduino's sensor", width/2, 105);
    data_button(25, 200, 200, "Ultrasonic sensor","Distance= "+ul_Distance+"cm");
    data_button(25, 250, 200, "Inrared obstacle sensor",(ir_state==0)?"Obstacle":"Clear");
    data_button(25, 300, 200, "PIR sensor",(pir_state==0)?"No movement":"Motion detected");
    data_button(25, 350, 200, "Photoresistor","Intensity of light= "+light_sensor_value+"%");
    data_button(300, 200, 200, "Buzzer","Buzzer is "+((buzzer_state==0)?"Off":"On"));
    data_button(300, 250, 200, "Red LED","Red LED is "+((red_led_state==0)?"Off":"On"));
    data_button(300, 300, 200, "Green LED","Green LED is "+((green_led_state==0)?"Off":"On"));
    data_button(250, 350, 300, "Temperature and Humidity sensor","Temperature = "+temperature+" C\nHumidity = "+humidity+"%\nHeat Index="+heat_index+" C");
    state_button(550,300,200,"Home",1);
    break;
  }
}
void choosePort() {
  background(28);
  textAlign(CENTER, CENTER);
  textFont(f1);
  fill(#9EFA3D);
  text("Frolics : The analog Assistant", width/2, 35);
  fill(212);
  text("Choose the port for communication", width/2, 105);  
  for (int i=0; i<Serial.list().length; i++) {
    COM_button(width/2-100, 250+50*i, 200, Serial.list()[i]);
  }
  if(Serial.list().length==0){
    text("No available ports found.", width/2, height/2);
  }
}

String val;
boolean firstContact = false;
void serialEvent( Serial port) {
  val = port.readStringUntil('\n');
  if (val != null) {
    val = trim(val);
    if (firstContact == false) {
      if (val.equals("A")) {
        port.clear();
        firstContact = true;
        port.write("A");
        println("contact");
      } else if (val.equals("-------------")) {
        c=1;
      } else {
        read_data(val);
      }
    }
  }
}


int c=0;
void read_data(String val) {
  if (c>=1) {
    switch(c) {
    case 1:
      ul_Distance=Integer.parseInt(val);
      c++;
      break;
    case 2:
      ir_state=Integer.parseInt(val);
      c++;
      break;
    case 3:
      pir_state=Integer.parseInt(val);
      c++;
      break;
    case 4:
      light_sensor_value=Float.parseFloat(val);
      c++;
      break;
    case 5:
      buzzer_state=Integer.parseInt(val);
      c++;
      break;
    case 6:
      red_led_state=Integer.parseInt(val);
      c++;
      break;
    case 7:
      green_led_state=Integer.parseInt(val);
      c++;
      break;
    case 8:
      temperature=Float.parseFloat(val);
      c++;
      break;
    case 9:
      humidity=Float.parseFloat(val);
      c++;
      break;
    case 10:
      heat_index=Float.parseFloat(val);
      c=0;
      break;
    default:
      c=0;
    }
  }
}

void button(int x, int y, int w, String msg, char ch) {
  noStroke();
  fill(#24ADFF);

  if (mouseX>x&&mouseX<x+w&&mouseY>y&&mouseY<y+30) {

    fill(#FA6060);
    if (mousePress) {
      timer=millis();
      trig=ch;
      port.write(ch);
      println("Sending '"+ch+"' to Arduino");

      mousePress=false;
    }
  } else if (trig==ch) {
    fill(#FA6060);
  }

  rect(x, y, w, 30, 30);
  fill(242);
  textAlign(CENTER, CENTER);
  textFont(f1, 15);
  text(msg, x, y-5, w, 30);
  textAlign(CENTER, CENTER);
  textFont(f1, 30);
  fill(#FA6060);
  if (millis()-timer<3000&&trig==ch) {
    text("Turning on "+msg, width/2+150, height/2-150, 250, 300);
    text("Sending signal...", width/2, height-40);
  }
}


void data_button(int x, int y, int w, String msg,String disp_mes) {
  noStroke();
  fill(#24ADFF);

  if (mouseX>x&&mouseX<x+w&&mouseY>y&&mouseY<y+30) {

    fill(#FA6060);
    if (mousePress) {
      timer=millis();
      data=msg;
      mousePress=false;
    }
  } else if (data.equals(msg)) {
    fill(#FA6060);
  }

  rect(x, y, w, 30, 30);
  fill(242);
  textAlign(CENTER, CENTER);
  textFont(f1, 15);
  text(msg, x, y-5, w, 30);
  textAlign(CENTER, CENTER);
  textFont(f1, 30);
  fill(#FA6060);
  if (data.equals(msg)) {
    text(disp_mes, width/2, height-100);
  }
}




void COM_button(int x, int y, int w, String msg) {
  noStroke();
  fill(#24ADFF);

  if (mouseX>x&&mouseX<x+w&&mouseY>y&&mouseY<y+30) {

    fill(#FA6060);
    if (mousePress) {
      timer=millis();
      com=msg;
      mousePress=false;
    }
  } 

  rect(x, y, w, 30, 30);
  fill(242);
  textAlign(CENTER, CENTER);
  textFont(f1, 15);
  text(msg, x, y-5, w, 30);
  textAlign(CENTER, CENTER);
  textFont(f1, 30);
  fill(#FA6060);
  if (millis()-timer<1000&&com.equals(msg)) {
    text("Choosing "+msg+" as Port for communication", width/2, height-50);
  } else if (com.equals(msg)) {
    if (!com.equals("")) {
      port = new Serial(this, com, 9600);
      port.bufferUntil('\n');
      slide=1;
    }
  }
}

int next_state;
void state_button(int x, int y, int w, String msg,int state) {
  noStroke();
  fill(#F7AB5A);

  if (mouseX>x&&mouseX<x+w&&mouseY>y&&mouseY<y+30) {
    fill(#3159F2);
    if (mousePress) {
      timer=millis();
      next_state=state;
      mousePress=false;
    }
  }
  else if(data.equals(msg)){
    fill(#3159F2);
  }

  rect(x, y, w, 30, 30);
  fill(242);
  textAlign(CENTER, CENTER);
  textFont(f1, 15);
  text(msg, x, y-5, w, 30);
  textAlign(CENTER, CENTER);
  textFont(f1, 30);
  fill(#3159F2);
  if (millis()-timer<100&&state==next_state) {
    slide=state;
  }
}

void mousePressed() {
  mousePress=true;
}
