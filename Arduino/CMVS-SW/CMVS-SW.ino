
#include "CMVS-SW.h"
#include <Wire.h>
#include <avr/dtostrf.h>
#include <stdio.h>

#define RD_WIDTH 16
#define DLY 500

void setup(void) {
  Serial.begin(9600);
  sw.setTxBuffer(swTxBuffer, sizeof(swTxBuffer));
  sw.setRxBuffer(swRxBuffer, sizeof(swRxBuffer));
  sw.setDelay_us(5);
  delay(300);
  sw.begin();
  readInterval.start(2000, AsyncDelay::MILLIS);
  for (uint8_t i = 0; i < (NUM_SENSORS << 1); ++i) {
    pins[i] = i + 2;
  }
}

void printSwData(void) {
  char ser_str[NUM_SENSORS * RD_WIDTH];
  char ser_str_buf[NUM_SENSORS * RD_WIDTH];
  switch (mode) {
  case (LUX_MODE):
    dtostrf(data.lux, 4, 2, ser_str_buf);
    sprintf(ser_str, "%9s, ", ser_str_buf);
    break;
  case (LUM_MODE):
    sprintf(ser_str, "%9u, ", data.lum);
    break;
  case (IR_MODE):
    sprintf(ser_str, "%9u, ", data.ir);
    break;
  case (VIS_MODE):
    sprintf(ser_str, "%9u, ", data.vis);
    break;
  case (FULL_MODE):
    sprintf(ser_str, "%9u, ", data.full);
    break;
  default:
    sprintf(ser_str, "%9u, ", data.error);
  }
  Serial.print(F(ser_str));
}

void loop(void) {
  for (uint8_t i = 0; i < NUM_SENSORS; ++i) {
    setSwPins();
    getSwData();
    printSwData();
  }
  Serial.println();
}
