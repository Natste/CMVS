#include <Wire.h>
#include <avr/dtostrf.h>
#include <stdio.h>

#include "CMVS-SW.h"
#include "CMVS-WIFI.h"
#include "ThingSpeak.h"
#include "constants.h"
#include "led_codes.h"

#define DEBUG

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
  ThingSpeak.begin(client);  // Initialize ThingSpeak
  delay(300);
}

String getDataStr(uint32_t data) {
  char ser_str[N_SENSORS * RD_WIDTH];
  String data_str;
  if (mode == LUX_MODE) sprintf(ser_str, "%9s, ", dtostrf(data, 4, 2, ser_str));
  else if (mode == LUM_MODE) sprintf(ser_str, "0x%08x, ", data);
  else sprintf(ser_str, "0x%4x, ", (uint16_t) data);
  data_str = ser_str;
  return data_str;
}

void loop(void) {
  ledRunning();
  String data_str, status_str;
  #ifdef DEBUG
    char serial_str1[N_SENSORS * RD_WIDTH];
    String serial_str2;
  #endif
  for (uint8_t i = 0; i < N_SENSORS; ++i) {
    setSwPins();
    Serial.print("[");
    Serial.print(sw.getSda());
    Serial.print(sw.getScl());
    Serial.print("]");
    uint32_t data = getSwData();
    data_str.concat(getDataStr(data));
    #ifdef DEBUG
      sprintf(serial_str1, "0x_%04x_%04x, ", (uint16_t)(data >> 16), (uint16_t)(data & 0xffff));
      serial_str2.concat(serial_str1);
    #endif
  }
  #ifdef DEBUG
    Serial.println(serial_str2);
  #endif
  ThingSpeak.writeField(myChannelNumber, DATA_CH, data_str, myWriteAPIKey);
  status_str = getConnectionStatus();
  if (WiFi.status() != WL_CONNECTED) {
    #ifdef DEBUG
      Serial.println("Attempting to connect to a known network.");
    #endif
    wifiSetup();
    ThingSpeak.writeField(myChannelNumber, STATUS_CH, status_str,
                          myWriteAPIKey);
  }
}
