#include "msp430G2553.h";

void main(void) {
  WDTCTL = WDTPW | WDTHOLD;   // Disable Watch Dog Timer
  
  P1DIR = BIT0;
  P1OUT = BIT0;
}
