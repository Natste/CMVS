#include <Adafruit_Sensor.h>
#include <Wire.h>
#include <stdio.h>

#include "Adafruit_TSL2591.h"

#define MUX1_ADDR 0x70
#define MUX2_ADDR 0X71
#define NUM_SENSORS 2
#define NUM_CH_PER_MUX 8
#define NUM_MUXES 2
#define RD_WIDTH 16
#define RD_DLY 100

Adafruit_TSL2591 tsl = Adafruit_TSL2591(2591);

void i2cMultiplexSignal(uint8_t addr, uint8_t bus) {
  Wire.beginTransmission(addr);  // TCA9548A address is 0x70
  Wire.write(1 << bus);          // send byte to select bus
  Wire.endTransmission();
}

void configureSensor(void) {
  tsl.setGain(TSL2591_GAIN_MED);  // 25x gain
  tsl.setTiming(TSL2591_INTEGRATIONTIME_300MS);
}

void setup(void) {
  configureSensor();
  Serial.begin(9600);
  delay(RD_DLY);
}

void readSensors(void) {
  char     irstr[NUM_SENSORS * RD_WIDTH];
  uint16_t ir;

  for (uint8_t i = 0; i < NUM_CH_PER_MUX * NUM_MUXES; ++i) {
    if (i == NUM_SENSORS) break;
    delay(RD_DLY);
    if (i < NUM_CH_PER_MUX) {
      Wire.beginTransmission(MUX1_ADDR);
      Wire.write(1 << i);
    } else {
      Wire.beginTransmission(MUX2_ADDR);
      Wire.write(1 << (i - NUM_CH_PER_MUX));
    }
    Wire.endTransmission();
    ir = tsl.getLuminosity(TSL2591_INFRARED);
    sprintf(irstr, "%6u, ", ir);
    Serial.print(irstr);
  }

}

void loop(void) {
  readSensors();
  Serial.println();

}
