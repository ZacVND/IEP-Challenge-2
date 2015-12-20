
import processing.serial.*; // import the Processing serial library
Serial myPort; // The serial port

float value; 
int mode = 0;   //0 = auto, 1 = heat, 2 = off
int output = 0;
float wantedTemperature = 32.5;
int backgroundColor = 255;
int fillColor = 0;
int xTemperature = 80;
int yTemperature = 84;
int xThermometer = 150;
int yThermometer = 150;
int xButtons = 50;
int yButtons = 470;
boolean buttonPlus = false;
boolean buttonMinus = false;
boolean buttonAuto = false;
boolean buttonOn = false;
boolean buttonOff = false;



void setup() {
  size(400,600);

  // List all the available serial ports
  println(Serial.list());

  // Change the 0 to the appropriate number of the serial port
  // that your LaunchPad is connected to.
  myPort = new Serial(this, Serial.list()[3], 9600);

  // read bytes into a buffer until you get a linefeed (ASCII 10):
  myPort.bufferUntil('\n');

  // draw with smooth edges:
  smooth();
  frameRate(2);
}

void draw() {
  update(mouseX, mouseY);
  calculateOutput();
  background(backgroundColor);
  fill(fillColor);
  
  drawTemperature();
  drawThermomether();
  
  fill(0,50);
  line(0,yButtons-20,400,yButtons-20);
  
  drawModeButtons();
  if (mode==0){
    drawSetTemperature();
  }
  
}

// serialEvent method is run automatically by the Processing applet
// whenever the buffer reaches the byte value set in the bufferUntil() 
// method in the setup():

void serialEvent(Serial myPort) { 
  // read the serial buffer:
  String myString = myPort.readStringUntil('\n');
  // if you got any bytes other than the linefeed:
  myString = trim(myString);

  // split the string at the commas
  // and convert the sections into integers:
  int sensors[] = int(split(myString, ','));

  // print out the values you got:
  for (int sensorNum = 0; sensorNum < sensors.length; sensorNum++) {
    println("Value "+sensorNum+" : " + sensors[sensorNum]); 
  }
  // add a linefeed after all the sensor values are printed:
  println("Mode:" + mode);
  println("Output:" + output);
  println("---------------");
  if (sensors.length > 0) {
    value = sensors[0];
  }
  // send a byte to ask for more data:
  myPort.write(output);
}

void drawThermomether(){
      //content of thermometer
  fill(209,24,24);
  noStroke();
  rect(xThermometer, yThermometer+250, 100, -int(5*value), 5);
  
  //border of thermometer
  stroke(fillColor);
  noFill();
  strokeWeight(2);
  rect(xThermometer, yThermometer, 100, 250, 5);
  
  //draw line of thermometer
  for (int i = 10; i < 250; i = i+10) {
    fill(fillColor);
    line(xThermometer,yThermometer+250-i,xThermometer+20,yThermometer+250-i);  
    if (i%50==0){
      text( (i/5),xThermometer-64,yThermometer+250-i+16);
    }
  }
  
  //light reflect
  fill(255,70);
  noStroke();
  rect(xThermometer+60, yThermometer+20, 20, 210, 5);
}

void drawTemperature() {
  textSize(32);
  text( "Temperature :", xTemperature+10, yTemperature-20);
  text( nf(value, 2,1), xTemperature+50, yTemperature+30); 
  text("°C", xTemperature+96+50, yTemperature+30); 
}

void drawModeButtons() {
    textSize(32);
    fill(fillColor);
    text("Heating Mode",xButtons+45,yButtons-10);
  
    stroke(fillColor);
    if (mode==0) {
      fill(200);
    } else {
    noFill();
    }
    strokeWeight(2);
    rect(xButtons, yButtons, 80, 50, 5);
    fill(fillColor);
    text("Auto",xButtons+4,yButtons+35);
    
    stroke(fillColor);
    if (mode==1) {
      fill(200);
    } else {
    noFill();
    }
    strokeWeight(2);
    rect(xButtons+100, yButtons, 80, 50, 5);
    fill(fillColor);
    text(" On",xButtons+104,yButtons+35);
    
    stroke(fillColor);
    if (mode==2) {
      fill(200);
    } else {
    noFill();
    }
    strokeWeight(2);
    rect(xButtons+200, yButtons, 80, 50, 5);
    fill(fillColor);
    text(" Off",xButtons+204,yButtons+35);
    
    //-------
    
    
}

void drawSetTemperature() {
    stroke(fillColor);
    fill(230);
    strokeWeight(2);
    rect(xButtons+80, yButtons+70, 120, 50, 5);
    fill(fillColor);
    text(nf(wantedTemperature, 2,1),xButtons+100,yButtons+110);
    
    stroke(fillColor);
    noFill();
    strokeWeight(2);
    rect(xButtons, yButtons+70, 60, 50, 5);
    fill(fillColor);
    text(" +",xButtons+10,yButtons+110);
    
     stroke(fillColor);
    noFill();
    strokeWeight(2);
    rect(xButtons+ 210, yButtons+70, 60, 50, 5);
    fill(fillColor);
    text(" -",xButtons+ 220,yButtons+110);
}

void update(int x, int y) {
  if ( overRect(xButtons, yButtons+70, 60, 50) ) {
    buttonPlus = true;
  } else { buttonPlus= false; }
  if ( overRect(xButtons+ 210, yButtons+70, 60, 50) ) {
    buttonMinus = true;
  } else { buttonMinus= false; }
  
  if ( overRect(xButtons, yButtons, 80, 50) ) {
    buttonAuto = true;
  } else { buttonAuto= false; }
  if ( overRect(xButtons+100, yButtons, 80, 50) ) {
    buttonOn = true;
  } else { buttonOn= false; }
  if ( overRect(xButtons+200, yButtons, 80, 50) ) {
    buttonOff = true;
  } else { buttonOff= false; }
}

void mousePressed() {
  if (buttonPlus) {
    wantedTemperature = wantedTemperature +0.5;
  }
  if (buttonMinus) {
    wantedTemperature = wantedTemperature -0.5;
  }
  if (buttonAuto) {
    mode = 0;
  }
  if (buttonOn) {
    mode = 1;
  }
  if (buttonOff) {
    mode = 2;
  }
}

boolean overRect(int x, int y, int width, int height)  {
  if (mouseX >= x && mouseX <= x+width && 
      mouseY >= y && mouseY <= y+height) {
    return true;
  } else {
    return false;
  }
}

void calculateOutput(){
  
  if (mode == 0) {
      if (value<wantedTemperature) {
        output = 1;
      } else {
        output = 0;
      }
  } else if (mode == 1) {
      output = 1;
  } else {
       output = 0;
  }
}