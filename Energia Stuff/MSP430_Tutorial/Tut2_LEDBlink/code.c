#include "msp430G2553.h";

unsigned int i = 0;

void main(void) {
  WDTCTL = WDTPW + WDTHOLD; // Stop WDT
  P1DIR |= BIT0;  // Set bit0 in the I/O direction register to define as an output
  P1OUT |= BIT0;  // Set the bit0 output to high
  
  while(1){
    /* Delay Block */
    i = 40000;           // Initialise count
    while (i-- > 0){     //post decrement count and loop until count == 0
    P1OUT = P1OUT;       //Do something that doesn't change anything
    }
  P1OUT ^= BIT0;         // Toggle bit0
  }
}
