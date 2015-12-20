#include<driverlib.h> 

#define HEATER P1_0
#define READER P1_5

//int counter, value;
float value;
int inByte = 0; 

void setup()
{
 Serial.begin(9600);
 counter = 0;
 establishContact();
}

void loop()
{
  //replace this part by the get heating value
  //counter = counter + 1;
  //value = counter%30;
  
  value = analogRead(READER);
  value =  -0.0951 * value + 73.102;
  
  Serial.println(value);
  
  if(inByte==1) {
    analogWrite(HEATER, 255);
  } else {
    analogWrite(HEATER, 0);
  }
  
  delay(200);
  
  if (Serial.available() > 0) {
    // get incoming byte:
    inByte = Serial.read();
    //Serial.print(",");
    //Serial.println(inByte);
  }
}

void establishContact() {
  while (Serial.available() <= 0) {
    Serial.println("0,0"); // send an initial string
    delay(300);
  }
}
