#include "msp430G2553.h";

void main(void) {
  WDTCTL = WDTPW + WDTHOLD; // Stop WDT
  /* Load calibrated DCO vlues to set CPU clock to 1MHz */
  BCSCTL1 = CALBC1_1MHZ; // Set DCO to 1MHz
  DCOCTL = CALDCO_1MHZ; // Set DCO to 1MHz
  
  P1DIR |= BIT0;  // Set bit0 in the I/O direction register to define as an output
  P1OUT |= BIT0;  // Set the bit0 output to high
  
  /* Configure timer A as a millisecond interval counter */
  TA0CTL = TASSEL_2 + MC_1 + ID_1;  // SMCLK as input clock, count up to TA0CCR0, clock/2
  TA0CCR0 = 40000;                  // Set maximum count value to determine count frequency = SMCLK/ClockDivide/TACCR0 (1MHz/2/40000 = 12.5Hz)
  TA0CCTL0 = OUTMOD_0 + CCIE;       // Set out mode 0, enable CCR0 interrupt
  
__bis_SR_register(CPUOFF + GIE);    // Put CPU to sleep in LPM0 with interrupts enabled
}

#pragma vector=TIMER0_A0_VECTOR
__interrupt void Timer_A0_ISR (void)
{
    P1OUT ^= BIT0;         // Toggle bit0
    __bic_SR_register(CPUOFF + GIE);  // Put CPU to sleep in LPM0 with interrupts enabled
}
