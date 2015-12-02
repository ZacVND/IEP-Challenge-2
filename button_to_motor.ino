

const int buttonPin = PUSH2;     // the number of the pushbutton pin
const int motor1 =  P2_1;
const int motor2 = P2_2;
const int probe = P1_5;
// the number of the LED pin
int buttonState = 0;
int probeValue = 0;
int total = 0;
int divisor = 1;
// variable for reading the pushbutton status
void setup() {
  // initialize the LED pin as an output:
  Serial.begin(9600);
  pinMode(motor1, OUTPUT);  
  pinMode(motor2, OUTPUT);
  pinMode(probe, INPUT); 
  // initialize the pushbutton pin as an input:
  pinMode(buttonPin, INPUT_PULLUP);     
}
void loop()
{
  // read the state of the pushbutton value:
  buttonState = digitalRead(buttonPin);
  probeValue = analogRead(probe);

  Serial.println(total/divisor);
  
  total += probeValue;
  divisor++;
  

  
  //Serial.println(buttonState);
  // check if the pushbutton is pressed.
  // if it is, the button State is HIGH:
  if (buttonState == LOW) 
  {     
    // turn high on:    
    digitalWrite(motor1, HIGH); 
    digitalWrite(motor2, HIGH);  
  } 
  else {
    // turn LED off:
    digitalWrite(motor1, LOW);
    digitalWrite(motor2, LOW); 
  }
}
