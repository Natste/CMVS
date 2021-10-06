#include <Wire.h>
#include <Adafruit_Sensor.h>
#include "Adafruit_TSL2591.h"

Adafruit_TSL2591 tsl = Adafruit_TSL2591(2591);

void TCA9548A1(uint8_t bus)
{
  Wire.beginTransmission(0x71);  // TCA9548A address is 0x70
  Wire.write(1 << bus);          // send byte to select bus
  Wire.endTransmission();
}

void TCA9548A2(uint8_t bus)
{
  Wire.beginTransmission(0x70);  // TCA9548A address is 0x70
  Wire.write(1 << bus);          // send byte to select bus
  Wire.endTransmission();
}

void configureSensor(void)
{
  tsl.setGain(TSL2591_GAIN_MED);      // 25x gain
  tsl.setTiming(TSL2591_INTEGRATIONTIME_300MS);
}

void setup(void) 
{
  Serial.begin(9600); 
  configureSensor();
//  Serial.println(F("Timestamp, IR1, IR2, IR3, IR4, IR5, IR6, IR7, IR8, IR9"));
}

void advancedRead(void)
{
  uint32_t lum = tsl.getFullLuminosity();
  uint16_t ir, full;
  ir = lum >> 16;
  full = lum & 0xFFFF;
  Serial.print(ir);
}

void loop(void) 
{ 
//  Serial.print(millis());
//  Serial.print(F(","));
  for (int i = 0; i < 8; i++)
  {
    TCA9548A1(i);
    advancedRead();
    Serial.print(F(","));
  }
  for (int i = 0; i < 2; i++)
  {
    TCA9548A2(i);
    if (i==0)
    {
      advancedRead();
    }
  }
  Serial.println();
  delay(100);
}
