void setup() {
  // put your setup code here, to run once:
Serial.begin(9600);
}


char s[30];

int a = 4000;

void loop() {
  // put your main code here, to run repeatedly:
  if (a > 7000){
    a = 4000;
  }
  a ++;
  int b = random(1200,1400);
  int c = random(20,50);
  sprintf(s, "%i,%i,%i", a, b, c);
  Serial.println(s);
}
