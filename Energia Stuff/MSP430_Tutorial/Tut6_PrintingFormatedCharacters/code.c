/* Configure UART to transmit and receive charcters over the serial port at 9600 baud
This uses pins P1.1 and P1.2. On the Launchpad these are connected to a USB bridge chip to allow
for communcation between the board and a Computer using a USB connection.
The code transmitts ascii formatted number strings using the print.c module.
*/

#include "msp430G2553.h";
#include "print.h"

void UARTConfigure(void);

int value = 672;

void main(void) {
  WDTCTL = WDTPW + WDTHOLD; // Stop WDT
  /* Load calibrated DCO vlues to set CPU clock to 1MHz */
  BCSCTL1 = CALBC1_1MHZ; // Set DCO to 1MHz
  DCOCTL = CALDCO_1MHZ;  // Set DCO to 1MHz
  
  UARTConfigure();
  printformat("Standard Width: %i\r\n",value);
  printformat("Fixed Width: %5i\r\n",value);
  
    __bis_SR_register(CPUOFF+GIE);      // Put CPU to sleep in LPM0 with interrupts enabled
}

void UARTConfigure(void){
  /* Configure hardware UART */
  P1SEL = BIT1 + BIT2 ; // P1.1 = RXD, P1.2=TXD
  P1SEL2 = BIT1 + BIT2 ; // P1.1 = RXD, P1.2=TXD
  UCA0CTL1 |= UCSSEL_2; // Use SMCLK
  UCA0BR0 = 104; // Set baud rate to 9600 with 1MHz clock (Data Sheet 15.3.13)
  UCA0BR1 = 0; // Set baud rate to 9600 with 1MHz clock
  UCA0MCTL = UCBRS0; // Modulation UCBRSx = 1
  UCA0CTL1 &= ~UCSWRST; // Initialize USCI state machine
  IE2 |= UCA0RXIE; // Enable USCI_A0 RX interrupt
}

