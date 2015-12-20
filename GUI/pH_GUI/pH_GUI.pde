import java.math.*;
import controlP5.*;
import processing.serial.*;
import java.io.FileWriter;
import java.io.*;

ControlP5 cp5;
Chart pH;
Chart rpmChart;
Slider rpmSlider;
Serial MSP; // The serial port
FileWriter fw;
BufferedWriter bw;

final String NAME = "Plotterduino";
final String VERSION = "0.1b";
final String TITLE = String.format("%s %s", NAME, VERSION);

// constants
final int NEWLINE = 10;
final int N_POINTS = 250;
final float Faraday = 9.6485309*pow(10,4);
final float R = 8.314510;
final float ln10 = 2.302585093;
final float Es = 2.963;
final int pHS = 7;
final float T = 22 + 273; // in Kelvin

// RPM values
final int MIN_RPM = 900;
final int MAX_RPM = 1800;
final int MIN_PH = 3;
final int MAX_PH = 8;

float max = 0;
float min = 10;
int ChartX = 120;
int ChartY1 = 400;
int ChartY2 = 620;
float desire = 0;
float reading;
float multiplier;

float value; 
int mode = 0;   //0 = auto, 1 = heat, 2 = off
int output = 0;
float wantedTemperature = 32.5;
int backgroundColor = 255;
int fillColor = 0;
int xTemperature = 1010;
int yTemperature = 138;
int xThermometer = 1080;
int yThermometer = 120;
int xButtons = 980;
int yButtons = 520;
boolean buttonPlus = false;
boolean buttonMinus = false;
boolean buttonAuto = false;
boolean buttonOn = false;
boolean buttonOff = false;

void setup() {
  size(1300, 700);
  smooth();
  cp5 = new ControlP5(this);
  try {
    String portName = Serial.list()[1];
    MSP = new Serial(this, portName, 9600);
  //no ports available
  } catch (ArrayIndexOutOfBoundsException e) {
    ;
  }
  
  //PH
  pH = cp5.addChart("Scale")
               .setPosition(ChartX, ChartY1)
               .setSize(40, 220)
               .setRange(MIN_PH, MAX_PH)
               .setView(Chart.BAR)
               ;
  pH.addDataSet("incoming");
  pH.setData("incoming", new float[1]);
  pH.getColor().setBackground(color(255,255,255));
  pH.updateData("incoming", 100, 100);
  
  multiplier = 220 / (MAX_PH - MIN_PH);
  
  PFont font = createFont("Times",18);
  
  cp5.addTextfield("DESIRED PH")
     .setPosition(30,120)
     .setSize(50,20)
     .setFont(font)
     .setFocus(true)
     .setColor(color(0, 0, 0))
     .setColorBackground(color(255, 255, 255))
     .setColorLabel(0)
     .getCaptionLabel().setSize(14)
     ;
     
  cp5.addBang("Set")
     .setPosition(120,120)
     .setSize(60,30)
     .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
     ;
     
  
  ///rpmChart
  rpmChart = cp5.addChart("rpmChart")
               .setPosition(240, 200)
               .setSize(600, 400)
               .setRange(MIN_RPM, MAX_RPM)
               .setView(Chart.LINE)
               .setColorLabel(0)
               .setColorValue(0);
  
  rpmChart.getColor().setBackground(color(255, 255, 255));
             
  rpmChart.addDataSet("RPM");
  rpmChart.setColors("RPM", color(0, 0, 0));
  rpmChart.setData("RPM", new float[N_POINTS]);
  rpmChart.updateData("RPM", 100, 100);
  
  ///rpmSlider
  rpmSlider = cp5.addSlider("rpmSlider")
                .setPosition(840, 200)
                .setSize(50, 400)
                .setRange(MIN_RPM, MAX_RPM)
                .setSliderMode(Slider.FIX)
                .setColorLabel(0)
                .setColorValue(0);
}

float pHreading;

void draw() {
  String input;
  if (MSP.available() > 0) {
    //HOW DOES THE INPUT LOOK LIKE:
    //"6.4,1341,34";
    //PH, RPM, TEMPERATURE SEPARATED BY COMMAS

    //load input from MSP
    input = MSP.readStringUntil(NEWLINE);
    if (input != null) {  
      String[] p = input.split(",");
      
      float ph = Float.parseFloat(p[0]);
      float rpm = Float.parseFloat(p[1]);
      pHreading = calcX(ph/1000);
      try {
          File file =new File("/users/vluong/Desktop/IEP-Challenge-2/GUI/pH_GUI/values.txt");
       
          if (!file.exists()) {
            file.createNewFile();
          }
       
          FileWriter fw = new FileWriter(file, true);///true = append
          BufferedWriter bw = new BufferedWriter(fw);
          PrintWriter pw = new PrintWriter(bw);
       
          pw.write(input);
       
          pw.close();
        }
        catch(IOException ioe) {
          System.out.println("Exception ");
          ioe.printStackTrace();
        }
      //T = temp;
      
      update(rpmChart, "RPM", rpm); //updates RPM chart
      updatePH(pH, "incoming", pHreading); //updates pH chart
    }
  }
  
  if(pHreading > max){
    max = float(String.format("%.2f", pHreading));
  }
  if(pHreading < min){
    min = float(String.format("%.2f", pHreading));
  }
  if(min < MIN_PH){
    min = MIN_PH;
  }
  if(max > MAX_PH){
    max = MAX_PH;
  }
  
  println("The pH value is: " + pHreading);
  //println(transFunc(reading));
  background(0);
  fill(255, 255, 255);  
  rect(10, 10, 195, 670, 7);
  rect(210, 10, 720, 670, 7);
  rect(940, 10, 350, 670, 7);
  //rect(120, 399, 19, 221); //half chart trick
  rect(119, 399, 41, 221); //full chart
  //display values:
  display();
  pH.push("incoming", pHreading);
}

//when set button(bang) is clicked, the following happens
void controlEvent(ControlEvent theEvent) {
   desire = float(cp5.get(Textfield.class,"DESIRED PH").getText());
  if(theEvent.getController().getName().equals("Set")) {
    println("desired value: "
            +desire
            );
    MSP.write(nf(desire));
  }
}

void display(){
  fill(40, 150, 140);
  textSize(30);
  text("pH", 84, 50);
  text("Stirring", 500, 50);
  text("Heating", 1060, 50);
  textSize(20);
  text("pH Scale", 70, 360);
  fill(10, 10, 10);
  textSize(14);
  text("ACTUAL PH:        " + String.format("%.2f", pHreading), 30, 185);
  text("MAXIMUM PH:     " + max, 30, 225);
  text("MINIMUM PH:      " + min, 30, 265);
  text("8", 105, 400);
  text("3", 105, 630);
  //text(String.format("%.2f", pHreading), 50, ChartY2 - 100);
  
  if(ChartY2 - (desire - 3) * multiplier > ChartY2){
    strokeWeight(1);
    text("" + desire, (ChartX - 40), ChartY2+5);
    line((ChartX - 10), ChartY2, (ChartX + 10), ChartY2);
   }
   else if(ChartY2 - (desire - 3) * multiplier < ChartY1){
    strokeWeight(1);
    text("" + desire, (ChartX - 40), ChartY1+5);
    line((ChartX - 10), ChartY1, (ChartX + 10), ChartY1);
   }
   else{
    strokeWeight(1);
    text("" + desire, (ChartX - 40), (ChartY2 - (desire - 3) * multiplier)+5);
    line((ChartX - 10), (ChartY2 - (desire - 3) * multiplier), (ChartX + 10), (ChartY2 - (desire - 3) * multiplier));
   }
   
   drawThermomether();
   drawTemperature();
   drawModeButtons();
   drawSetTemperature();
}

void update(Chart c, String n, float v) {
   c.addData(n, v);
   if (c.getDataSet(n).size() > N_POINTS) c.removeData(n, 0);
}

void updatePH(Chart c, String n, float v) {
   c.addData(n, v);
   if (c.getDataSet(n).size() > 1) c.removeData(n, 0);
}

//Calculate the pH value from raw value from Serial
float calcX(float Ex)
{
  float X;
  
  X = pHS + (((Es - Ex)*Faraday)/(R*T*ln10)); //apply transfer function
  
  return X;
}

void drawThermomether(){
      //content of thermometer
  fill(209,24,24);
  noStroke();
  rect(xThermometer, yThermometer+100, 670, -int(5*value), 5);
  
  //border of thermometer
  stroke(fillColor);
  noFill();
  strokeWeight(2);
  rect(xThermometer, yThermometer+100, 100, 250, 5);
  
  //draw line of thermometer
  for (int i = 10; i < 250; i = i+10) {
    fill(fillColor);
    line(xThermometer,yThermometer+350-i,xThermometer+20,yThermometer+350-i);  
    if (i%50==0){
      text( (i/5),xThermometer-64,yThermometer+350-i+16);
    }
  }
  
  //light reflect
  //fill(255,70);
  //noStroke();
  //rect(xThermometer+60, yThermometer+20, 20, 210, 5);
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