#ifndef CMVS_WIFI
#define CMVS_WIFI
#define DISCONNECTED "Disconnected!"
#define CONNECTED "Connected."

#include "secrets.h"
#include "led_codes.h"
#include <WiFiNINA.h>

char ssid[] = SECRET_SSID;  // your network SSID (name)
char wpi_ssid[] = WPI_SSID; // your network SSID (name)
char pass[] = SECRET_PASS;  // your network password
char wpi_pass[] = WPI_PASS; // your network password

WiFiClient client;



uint8_t getNetworkIndex(void) {
  // scan for nearby networks:
  Serial.print("Scanning Known Networks...");
  int numSsid = WiFi.scanNetworks();
  if (numSsid == -1) {
    Serial.println("Couldn't get a WiFi connection");
    while (true)
      ledStuck();
  }
  for (uint8_t thisNet = 0; thisNet < numSsid; thisNet++) {
    for (const String &ssid : ssid_list) {
      if ((String)WiFi.SSID(thisNet) == ssid) {
        Serial.print("found ");
        Serial.println(ssid_list[thisNet]);
        return thisNet;
      }
    }
  }
}

void wifiSetup(void) {
  if (WiFi.status() == WL_NO_MODULE) {
    Serial.println("Communication with WiFi module failed!");
    while (true)
      ledStuck();
  }

  uint8_t i_network = getNetworkIndex();
  if (WiFi.status() != WL_CONNECTED) {
    Serial.print("attempting to connect...");
    Serial.println(ssid_list[i_network]);
    while (WiFi.status() != WL_CONNECTED) {
      ledScanning();
      WiFi.begin(ssid_list[i_network], pass_list[i_network]);
      Serial.print("·");
    }
  }
  Serial.println("success!");
}

String getConnectionStatus(void) {
  String status = (WiFi.status() != WL_CONNECTED) ? DISCONNECTED : CONNECTED;
  return status;
}

void printArduinoMac(void) {
  byte mac[6];
  WiFi.macAddress(mac);
  Serial.print("Arduino MAC: ");
  Serial.print(mac[5],HEX);
  Serial.print(":");
  Serial.print(mac[4],HEX);
  Serial.print(":");
  Serial.print(mac[3],HEX);
  Serial.print(":");
  Serial.print(mac[2],HEX);
  Serial.print(":");
  Serial.print(mac[1],HEX);
  Serial.print(":");
  Serial.println(mac[0],HEX);
}
#endif