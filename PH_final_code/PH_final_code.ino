
#define outputPIN P1_5
#define inPIN P1_4
#define basePIN P2_1
#define acidPIN P2_2


unsigned long int timeSend = 0;
unsigned long int timeSinceMotorRun = 1000000;
boolean shutDown = false;
boolean motorRunning = false;
int PHtarget = 1200;      // will be updated by interface
int PHmargin = 50;        // 
int output = 0;
int input = 0;
  

void setup()
{
  Serial.begin(9600);
  Serial.setTimeout(50);
  pinMode(outputPIN, INPUT);
  pinMode(inPIN, INPUT);
  pinMode(basePIN, OUTPUT);
  pinMode(acidPIN, OUTPUT);
  digitalWrite(basePIN, LOW);
  digitalWrite(acidPIN, LOW);
}

void loop()
{

  if(millis() - timeSend > 1000)  // function to run every 0.25s
  {
  // read the input on analog pin P1.5:
  output = analogRead(outputPIN)*2.9;  // this include a gain of 11
  input = analogRead(inPIN)*2.9;
  
  // print out the value we have read to the interface:
  Serial.print("PHoutputex:");
  Serial.print(output);
  Serial.print("\r\n"); 
  Serial.print("PHinputes:");
  Serial.print(input);
  Serial.print("\r\n"); 
  Serial.print("PHtarget:");
  Serial.print(PHtarget);
  Serial.print("\r\n"); 
  
  PHmaintain();  // activate motors if required;
 
  timeSend = millis(); 
  }
  
  PHcommandListen();  // listen for commands NOTE; THIS SECTION MUST BE COMBINED WITH OTHER SUBSYSTEMS
  
  
  
}

  void PHmaintain(){
    
   int difference = PHtarget - output;
   Serial.print("difference:");
   Serial.println(difference);
   
   if(motorRunning && (millis() - timeSinceMotorRun > 2000))  // if we've been running the motor for more than 2s
   {
     digitalWrite(basePIN, LOW);
     digitalWrite(acidPIN, LOW);
     // turn both motors off
     motorRunning = false;
     Serial.println("Shutting motor down");
   }
   
   if(abs(difference) > PHmargin)  // if the PH is outside the margin
   {
     Serial.println("PH outside margin");
     
     if(difference > 0 && (millis() - timeSinceMotorRun) > 5000)  // if solution is too acidic and we havn't run a motor for 10s
     {
      if(!shutDown){  // if we havn't shut the motors down.
         timeSinceMotorRun = millis();
         motorRunning = true;
         digitalWrite(basePIN, HIGH);  // run base motor
         Serial.println("Runnng base motor"); 
       }
     }
     
     if(difference < 0 && (millis() - timeSinceMotorRun) > 5000)  // if solution is too alkalie and we havn't run a motor for 10s
     {
       if(!shutDown){  // if we havn't shut the motors down.
         timeSinceMotorRun = millis();
         motorRunning = true;
          digitalWrite(acidPIN, HIGH); // run acid motor;
          Serial.println("Runnng acid motor"); 
       }
     } 
   }
   
  }

  void PHcommandListen()  // listen and reactor to commands from the interface
  {
      
       while (Serial.available() > 0) {
          
         String inString = Serial.readString();
         inString.trim();
         Serial.println(inString);  //DEBUG ONLY
         
         if(inString.equals("S")){
         Serial.println("PH is in shutdown");
         shutDown = true;
             digitalWrite(basePIN, LOW);
             digitalWrite(acidPIN, LOW);
             // turn both motors off
             motorRunning = false;
         }
         if(inString.equals("XS")){
         Serial.println("PH has resumed");
         shutDown = false;
         }
         if((inString.substring(0,11)).equals("PHcommanded"))  // if we see a command
         {
           PHtarget = inString.substring(12).toInt();  // change the target PH
         }
         }
         
      
  }
  
 
  
  
  
