import java.math.*;

import controlP5.*;
import processing.serial.*;

// application info
final String NAME = "Plotterduino";
final String VERSION = "0.1b";
final String TITLE = String.format("%s %s", NAME, VERSION);

// constants
final int NEWLINE = 10;
final int N_POINTS = 250;

// RPM values
final int MIN_RPM = 900;
final int MAX_RPM = 1800;

//rpmUI
Chart rpmChart;
Slider rpmSlider;

ControlP5 cp5;
Serial MSP;

void update(Chart c, String n, float v) {
   c.addData(n, v);
   if (c.getDataSet(n).size() > N_POINTS) c.removeData(n, 0);
}

void setup() {
  size(700, 400);
  noStroke();
  
  try {
    String portName = Serial.list()[1];
    MSP = new Serial(this, portName, 9600);
  //no ports available
  } catch (ArrayIndexOutOfBoundsException e) {
    ;
  }
  
  //initialise the GUI
  cp5 = new ControlP5(this);
  cp5.getTab("default").setVisible(false);
  
  //RPM tab
  cp5.addTab("RPM")
    .activateEvent(true)
    .setId(0);
  
  ///rpmChart
  rpmChart = cp5.addChart("rpmChart")
               .setSize(650, 400)
               .setRange(MIN_RPM, MAX_RPM)
               .setView(Chart.LINE);
  
  rpmChart.getColor().setBackground(color(255, 255, 255));
             
  rpmChart.addDataSet("RPM");
  rpmChart.setColors("RPM", color(0, 0, 0));
  rpmChart.setData("RPM", new float[N_POINTS]);
  rpmChart.updateData("RPM", 100, 100);
  
  ///rpmSlider
  rpmSlider = cp5.addSlider("rpmSlider")
                .setPosition(650, 0)
                .setSize(50, 400)
                .setRange(MIN_RPM, MAX_RPM)
                .setSliderMode(Slider.FIX);
  
  cp5.getController("rpmChart").moveTo("RPM");
  cp5.getController("rpmSlider").moveTo("RPM");
}

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
      float temp = Float.parseFloat(p[2]);


      update(rpmChart, "RPM", rpm); //updates RPM chart
    }
  }
}