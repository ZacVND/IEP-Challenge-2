#include <stdio.h>
#include <math.h>
#define Faraday 9.6485309*pow(10,4)
#define R 8.314510
#define ln10 2.302585093

//Consult step 13 of pseudocode for meaning of variable names

const int pumpA =  P2_1; //Acid Pump
const int pumpB = P2_2; //Base Pump
const int Ex = P1_5; //Probe
const int pHS = 7;
float T = 22 + 273;
float Es = 1.5;
float pHX = 0;

float calcX(float Ex);//this function calculate pH(X)

void setup() {
  Serial.begin(9600);
  pinMode(pumpA, OUTPUT);  
  pinMode(pumpB, OUTPUT);
  pinMode(Ex, INPUT); 
}
void loop()
{
  // read the probe value, the electric potential at pH measuring electrode
  pHX = calcX(analogRead(Ex));
  
  //display on serial
  Serial.print("Standard pH is:  ");
  Serial.println(pHS);
  Serial.print("pH value of solution is:  ");
  Serial.println(pHX);
  
  if (pHX > pHS)
  {
    digitalWrite(pumpA, HIGH);//turn on acid pump
  }
  else if (pHX < pHS)
  {
    digitalWrite(pumpB, HIGH);//turn on base pump
  }
  else
  {
    digitalWrite(pumpA, LOW);//turn both off
    digitalWrite(pumpB, LOW);
  }
  delay(1000);

}

float calcX(float eX)
{
  float X;
  
  X = pHS + (((Es - Ex)*Faraday)/(R*T*ln10));
  
  return X;
}
