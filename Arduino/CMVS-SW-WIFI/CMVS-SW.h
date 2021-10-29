#ifndef CMVS_SW
#define CMVS_SW

#include <Adafruit_Sensor.h>
#include <Adafruit_TSL2591.h>
#include <SoftWire.h>
#include "constants.h"
#include "led_codes.h"


AsyncDelay readInterval;

uint8_t mode = FULL_MODE;

uint8_t swTxBuffer[BUFLEN];
uint8_t swRxBuffer[BUFLEN];

uint8_t sdaPin = 2;
uint8_t sclPin = 3;
SoftWire sw(sdaPin, sclPin);

uint8_t pins[(N_SENSORS << 1)];

void populatePinArray(void) {
  for (uint8_t i = 0; i < (N_SENSORS << 1); ++i) {
    pins[i] = i + 2;
  }
}
void sensorWrite(uint8_t *buffer, size_t len, uint8_t stop = true) {
  sw.beginTransmission(TSL2591_ADDR);
  sw.write(buffer, len);
  sw.endTransmission(stop);
}
//
void sensorRead(uint8_t *buffer, size_t len, uint8_t stop = true) {
  for (uint8_t i = 0; i < len; i++) {
    sw.requestFrom((uint8_t)TSL2591_ADDR, (uint8_t)len, (uint8_t)stop);
    buffer[i] = sw.read();
  }
}

uint8_t read8(uint8_t reg) {
  uint8_t buffer[1];
  buffer[0] = reg;
  sensorWrite(buffer, 1, true);
  sensorRead(buffer, 1);
  return buffer[0];
}
void write8(uint8_t reg, uint8_t value) {
  uint8_t buffer[2];
  buffer[0] = reg;
  buffer[1] = value;
  sensorWrite(buffer, 2);
}

void write8(uint8_t reg) {
  uint8_t buffer[1];
  buffer[0] = reg;
  sensorWrite(buffer, 1);
}

void enable(void) {
  // Enable the device by setting the control bit to 0x01
  write8(TSL2591_COMMAND_BIT | TSL2591_REGISTER_ENABLE,
         TSL2591_ENABLE_POWERON | TSL2591_ENABLE_AEN | TSL2591_ENABLE_AIEN |
             TSL2591_ENABLE_NPIEN);
}
void disable(void) {
  // Disable the device by setting the control bit to 0x00
  write8(TSL2591_COMMAND_BIT | TSL2591_REGISTER_ENABLE,
         TSL2591_ENABLE_POWEROFF);
}

void configureSensor(void) {
  // set timing and gain
  enable();
  write8(TSL2591_COMMAND_BIT | TSL2591_REGISTER_CONTROL,
         CMVS_INTEGRATION | CMVS_GAIN);
  disable();
  enable();
  write8(TSL2591_COMMAND_BIT | TSL2591_REGISTER_CONTROL,
         CMVS_INTEGRATION | CMVS_GAIN);
  disable();
}

void setSwPins(void) {
  static uint8_t pin = 0;
  sw.setScl(pins[pin]);
  pin++;
  sw.setSda(pins[pin]);
  pin++;
  configureSensor();
  if (pin >= (N_SENSORS << 1) - 1) {
    pin = 0;
  }
}

float calculateLux(uint32_t lum) {
  float aTime, aGain;
  float cpl, lux1, lux2, lux;
  // uint32_t sw_reading = ;
  uint16_t ir = (lum & 0xFFFF);
  uint16_t full = (lum >> 16);

  // Check for overflow conditions first
  if ((ir == 0xFFFF) | (full == 0xFFFF)) {
    // Signal an overflow
    return -1;
  }

  // Note: This algorithm is based on preliminary coefficients
  // provided by AMS and may need to be updated in the future

  switch (CMVS_INTEGRATION) {
  case TSL2591_INTEGRATIONTIME_100MS:
    aTime = 100.0F;
    break;
  case TSL2591_INTEGRATIONTIME_200MS:
    aTime = 200.0F;
    break;
  case TSL2591_INTEGRATIONTIME_300MS:
    aTime = 300.0F;
    break;
  case TSL2591_INTEGRATIONTIME_400MS:
    aTime = 400.0F;
    break;
  case TSL2591_INTEGRATIONTIME_500MS:
    aTime = 500.0F;
    break;
  case TSL2591_INTEGRATIONTIME_600MS:
    aTime = 600.0F;
    break;
  default: // 100ms
    aTime = 100.0F;
    break;
  }

  switch (CMVS_GAIN) {
  case TSL2591_GAIN_LOW:
    aGain = 1.0F;
    break;
  case TSL2591_GAIN_MED:
    aGain = 25.0F;
    break;
  case TSL2591_GAIN_HIGH:
    aGain = 428.0F;
    break;
  case TSL2591_GAIN_MAX:
    aGain = 9876.0F;
    break;
  default:
    aGain = 1.0F;
    break;
  }

  // cpl = (ATIME * AGAIN) / DF
  cpl = (aTime * aGain) / TSL2591_LUX_DF;

  // Original lux calculation (for reference sake)
  // lux1 = ( (float)ir - (TSL2591_LUX_COEFB * (float)full) ) / cpl;
  // lux2 = ( ( TSL2591_LUX_COEFC * (float)ir ) - ( TSL2591_LUX_COEFD *
  // (float)full ) ) / cpl; lux = lux1 > lux2 ? lux1 : lux2;

  // Alternate lux calculation 1
  // See: https://github.com/adafruit/Adafruit_TSL2591_Library/issues/14
  lux = (((float)ir - (float)full)) * (1.0F - ((float)full / (float)ir)) / cpl;

  // Alternate lux calculation 2
  // lux = ( (float)ir - ( 1.7F * (float)full ) ) / cpl;

  // Signal I2C had no errors
  return lux;
}

uint32_t getSwData(void) {
  uint32_t data;
  enable();
  for (uint8_t d = 0; d <= TSL2591_INTEGRATIONTIME_300MS; d++) {
    delay(120);
  }

  uint16_t y = read8(TSL2591_COMMAND_BIT | TSL2591_REGISTER_CHAN0_HIGH); // 0x11
  y <<= 8;                                                      // 0x11zz
  y |= read8(TSL2591_COMMAND_BIT | TSL2591_REGISTER_CHAN0_LOW); // 0x1122
  uint32_t x = read8(TSL2591_COMMAND_BIT | TSL2591_REGISTER_CHAN1_HIGH); // 0x33
  x <<= 8;                                                      // 0x33zz
  x |= read8(TSL2591_COMMAND_BIT | TSL2591_REGISTER_CHAN1_LOW); // 0x3344
  if (mode == FULL_MODE) {
    data = y;
  } else if (mode == IR_MODE) {
    data = x;
  } else if (mode == VIS_MODE) {
    data = (y - x);
  } else if (mode == LUM_MODE) {
    x <<= 16; // 0x3344zzzz
    x |= y;   // 0x33441122
    data = x;
  } else if (mode == LUX_MODE) {
    x <<= 16; // 0x3344zzzz
    x |= y;   // 0x33441122
    data = calculateLux(x);
  } else {
    data = 0xDEADBEEF;
  }
  disable();
  return data;
}
#endif