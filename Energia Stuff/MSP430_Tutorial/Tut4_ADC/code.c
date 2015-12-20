/* Configure ADC to sample the input on pin P1.5 and use the sampled value to control the 
brightness of an LED attached the P1.6 using PWM. */

#include "msp430G2553.h";

void main(void) {
  WDTCTL = WDTPW + WDTHOLD; // Stop WDT
  /* Load calibrated DCO vlues to set CPU clock to 1MHz */
  BCSCTL1 = CALBC1_1MHZ; // Set DCO to 1MHz
  DCOCTL = CALDCO_1MHZ; // Set DCO to 1MHz
  
  /* Configure ADC*/
  ADC10CTL0=SREF_1 + REFON + REFOUT + ADC10ON + ADC10SHT_3 + ADC10IE ; //1.5V ref, Ref on, Enable Ref Output, 64 clocks for sample
  ADC10CTL1=ADC10DIV_3; //temp sensor is at 10 and clock/4
  ADC10AE0 |= BIT5 + BIT4; // Set P1.4 and P1.5 as ADC inputs
  
  /* Configure Output pin for LED*/
  P1DIR |= BIT6;               // Set P1.6 as output
  P1SEL |= BIT6;               // Select output P1.6 to be timer output TA0.1
  P1SEL2 &= ~BIT6;             // Select output P1.6 to be timer output TA0.1
  
  /* Configure timer A as a PWM */
  TA0CTL = TASSEL_2 + MC_1 + ID_0;  // SMCLK as input clock, count up to TA0CCR0, clock/1
  TA0CCR0 = 1024;                   // Set maximum count value to determine count frequency = SMCLK/ClockDivide/TACCR0 (1MHz/1/1024 = 0.97kHz)
  TA0CCTL0 = OUTMOD_0 + CCIE;       // Set out mode 0, enable CCR0 interrupt
  TA0CCR1 = 10;                     // Initialise counter compare value 1 to control Duty Cycle = TACCR1/TACCR0 (100/1000 = 10%)
  TA0CCTL1 = OUTMOD_7;              // Set output to on when counter resets and off when counter equals TACCR1. Normal PWM.
__bis_SR_register(CPUOFF+GIE);      // Put CPU to sleep in LPM0 with interrupts enabled
}

// ADC10 interrupt service routine
#pragma vector=ADC10_VECTOR
__interrupt void ADC10_ISR (void)
{
  TA0CCR1 = ADC10MEM;           // read ADC value (note this is a 10bit value stored in a 16 bit register)
  ADC10CTL0 &= ~ENC;
}

#pragma vector=TIMER0_A0_VECTOR
__interrupt void Timer_A0_ISR (void)
{
  ADC10CTL1 = INCH_5;          // Select ADC Channel
  ADC10CTL0 |= ENC + ADC10SC;  // Start ADC Acquisition
}

