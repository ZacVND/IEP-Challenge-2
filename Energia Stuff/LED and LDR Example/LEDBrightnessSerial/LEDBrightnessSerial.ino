
#define LED P1_6

int brightness = 0;

void setup()  { 
  // declare pin 14 to be an output:
  pinMode(LED, OUTPUT);
  Serial.begin(9600);
 
} 

void loop()  { 
  while (Serial.available()) {
    brightness = Serial.parseInt();
    if (Serial.read() == '\n'){
      analogWrite(LED, brightness);
    }  
  }                    
}

