/* Alternate Blink for MSP430G2553
 * Benn Thomsen November 2013*/
#include "msp430g2553.h"
 
void main(void) {
 WDTCTL = WDTPW | WDTHOLD; // Stop watchdog timer
 
/* Use Factory stored presets to calibrate the internal oscillator */
 BCSCTL1 = CALBC1_1MHZ; // Set DCO Clock to 1MHz
 DCOCTL = CALDCO_1MHZ;
 
P1DIR |= BIT0 + BIT6; // Set P1.0 and P1.6 to output direction
 P1OUT |= BIT6; // Set P1.6 to on
 P1OUT &= ~BIT0; // Set P1.0 to off
 
 /* Configure timer A as a clock divider to generate delay */
 TACCTL0 = CCIE; // Enable counter interrupt on counter compare register 0
 TACTL = TASSEL_2 +ID_3 + MC_1; // Use the SMCLK to clock the counter, SMCLK/8, count up mode
 TACCR0 = 10000-1; // Set maximum count (Interrupt frequency 1MHz/8/10000 = 12.5Hz)
 
__enable_interrupt(); // Enable interrupts.
_BIS_SR(CPUOFF + GIE); // Enter LPM0 with interrupts enabled
}
 
// TimerA interrupt service routine
#pragma vector=TIMER0_A0_VECTOR
__interrupt void Timer_A (void)
{
 P1OUT ^= BIT0 + BIT6; // Toggle P1.0 and P1.6 using exclusive-OR
}
