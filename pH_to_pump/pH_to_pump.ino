#include <stdio.h>
#include <math.h>
#define Faraday 9.6485309*pow(10,4)
#define R 8.314510
#define ln10 2.302585093

//Consult step 13 of pseudocode for meaning of variable names

const int pumpA =  P2_1; //Acid Pump
const int pumpB = P2_2; //Base Pump
const int probe = P1_5; //Probe Pin
const int pHS = 7;
float T = 22 + 273; // in Kelvin
float Es = 1.5; // Not sure if this is in V or mV
float pHX = 0;
int pumpLim = 10;//number of pump activation possible to prevent overflow
float calcX(float Ex);//this function calculate pH(X)

int limit =
void setup() {
  Serial.begin(9600);
  pinMode(pumpA, OUTPUT);  
  pinMode(pumpB, OUTPUT);
  pinMode(probe, INPUT); 
}
void loop()
{
  // read the probe value, the electric potential at pH measuring electrode
  // multiply by 0.0029 because it is  2.9 mV per unit of analogRead
  pHX = calcX(analogRead(probe) * (2.9/1000));
  
  int pumpAct = 0; //number of pump activation
  
  //display on serial
  Serial.print("Standard pH is:  ");
  Serial.println(pHS);
  Serial.print("pH value of solution is:  ");
  Serial.println(pHX);
  if(pumpAct <= pumpLim)
  {
    if (pHX > pHS)
    {
      digitalWrite(pumpA, HIGH); //turn on acid pump
      pumpAct++;
    }
    else if (pHX < pHS)
    {
      digitalWrite(pumpB, HIGH); //turn on base pump
      pumpAct++;
    }
  }
  delay(1000);
  digitalWrite(pumpA, LOW); //turn both off
  digitalWrite(pumpB, LOW);

}

float calcX(float Ex)
{
  float X;
  
  X = pHS + (((Es - Ex)*Faraday)/(R*T*ln10)); //apply transfer function
  
  return X;
}
