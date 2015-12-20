
void setup() {
  // initialize serial communication at 9600 bits per second:
  Serial.begin(9600); // msp430g2231 must use 4800
}

// the loop routine runs over and over again forever:
void loop() {
  // read the input on analog pin P1.5:
  int sensorValue = analogRead(P1_5);
  // print out the value you read:
  Serial.print("LDR:");
  Serial.print(sensorValue);
  Serial.print("\r\n");
  delay(500); // delay in between reads for stability
}
