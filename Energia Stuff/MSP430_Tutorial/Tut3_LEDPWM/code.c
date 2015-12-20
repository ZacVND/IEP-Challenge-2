#include "msp430G2553.h";

void main(void) {
  WDTCTL = WDTPW + WDTHOLD; // Stop WDT
  /* Load calibrated DCO vlues to set CPU clock to 1MHz */
  BCSCTL1 = CALBC1_1MHZ; // Set DCO to 1MHz
  DCOCTL = CALDCO_1MHZ; // Set DCO to 1MHz
  
  P1DIR |= BIT0;  // Set bit0 in the I/O direction register to define as an output
  P1OUT |= BIT0;  // Set the bit0 output to high
  
  P1DIR |= BIT6;               // Set P1.6 as output
  P1SEL |= BIT6;               // Select output P1.6 to be TA0.1
  P1SEL2 &= ~BIT6;             // Select output P1.6 to be TA0.1
  
  /* Configure timer A as a millisecond interval counter */
  TA0CTL = TASSEL_2 + MC_1 + ID_0;  // SMCLK as input clock, count up to TA0CCR0, clock/1
  TA0CCR0 = 1000;                   // Set maximum count value to determine count frequency = SMCLK/ClockDivide/TACCR0 (1MHz/1/1000 = 1kHz)
  TA0CCR1 = 100;                    // Initialise counter compare value 1 to control Duty Cycle = TACCR1/TACCR0 (100/1000 = 10%)
  TA0CCTL1 = OUTMOD_7;              // Set output to on when counter resets and off when counter equals TACCR1. Normal PWM.
__bis_SR_register(CPUOFF);    // Put CPU to sleep in LPM0 with interrupts enabled
}

