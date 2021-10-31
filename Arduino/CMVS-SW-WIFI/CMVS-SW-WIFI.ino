#include "CMVS-SW.h"
#include "constants.h"
#include "CMVS-WIFI.h"
#include "ThingSpeak.h"
#include "led_codes.h"
#include <Wire.h>
#include <avr/dtostrf.h>
#include <stdio.h>



unsigned long myChannelNumber = SECRET_CH_ID;
const char *myWriteAPIKey = SECRET_WRITE_APIKEY;

void setup(void) {
  pinMode(LED_PIN, OUTPUT);
  populatePinArray();
  Serial.begin(9600);
  sw.setTxBuffer(swTxBuffer, sizeof(swTxBuffer));
  sw.setRxBuffer(swRxBuffer, sizeof(swRxBuffer));
  sw.setDelay_us(5);
  delay(300);
  sw.begin();
  readInterval.start(2000, AsyncDelay::MILLIS);
  printArduinoMac();
  wifiSetup();
  ThingSpeak.begin(client); // Initialize ThingSpeak
}

String getDataStr(uint32_t data) {
  char ser_str[N_SENSORS * RD_WIDTH];
  char ser_str_buf[N_SENSORS * RD_WIDTH];
  String data_str;
  switch (mode) {
  case (LUX_MODE):
    dtostrf(data, 4, 2, ser_str_buf);
    sprintf(ser_str, "%9s, ", ser_str_buf);
    break;
  case (LUM_MODE):
    sprintf(ser_str_buf, "0x%x", data);
    sprintf(ser_str, "%9s, ", ser_str_buf);
    break;
  case (IR_MODE):
    sprintf(ser_str_buf, "0x%x", data);
    sprintf(ser_str, "%9s, ", ser_str_buf);
    break;
  case (VIS_MODE):
    sprintf(ser_str_buf, "0x%x", data);
    sprintf(ser_str, "%9s, ", ser_str_buf);
    break;
  case (FULL_MODE):
    sprintf(ser_str_buf, "0x%x", data);
    sprintf(ser_str, "%9s, ", ser_str_buf);
    break;
  default:
    sprintf(ser_str_buf, "0x%x", data);
    sprintf(ser_str, "%9s, ", ser_str_buf);
  }
  data_str = ser_str;
  return data_str;
}

void loop(void) {
  ledRunning();
  String data_str, status_str;
  for (uint8_t i = 0; i < N_SENSORS; ++i) {
    setSwPins();
    uint32_t data = getSwData();
    data_str.concat(getDataStr(data));
  }
  ThingSpeak.writeField(myChannelNumber, DATA_CH, data_str, myWriteAPIKey);
  Serial.println(data_str);
  status_str = getConnectionStatus();
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("Attempting to connect to a known network.");
    wifiSetup();
    ThingSpeak.writeField(myChannelNumber, STATUS_CH, status_str,
                          myWriteAPIKey);
  }
}
