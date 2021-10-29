#ifndef LED_CODES_H
#define LED_CODES_H

#include "constants.h"
#include <Arduino.h>

uint32_t prev_millis = 0;

void ledToggle(uint16_t T_ON, uint16_t T_OFF) {
  static uint8_t led_state = LOW;
  uint32_t curr_millis = millis();
  if (led_state == LOW)
    if (curr_millis - prev_millis >= (T_OFF)) {
      prev_millis = curr_millis;
      led_state = HIGH;
      digitalWrite(LED_BUILTIN, led_state);
    }
    if (led_state == HIGH) {
      delay(T_ON);
      led_state = LOW;
      digitalWrite(LED_BUILTIN, led_state);
    }
  // if (led_state == HIGH)
  //   if (curr_millis - prev_millis >= (T_ON)) {
  //     prev_millis = curr_millis;
  //     led_state = LOW;
  //     digitalWrite(LED_BUILTIN, led_state);
  //   }
}
void ledDelay(uint16_t T_ON, uint16_t T_OFF) {
  static uint8_t led_state = LOW;
  uint32_t curr_millis = millis();
  if (led_state == LOW) {
    delay(T_OFF);
    led_state = HIGH;
    digitalWrite(LED_BUILTIN, led_state);
  }
  if (led_state == HIGH) {
    delay(T_ON);
    led_state = LOW;
    digitalWrite(LED_BUILTIN, led_state);
  }
}

void ledScanning(void) {
  ledDelay(T_SCANNING_ON, T_SCANNING_OFF);
  ledDelay(T_SCANNING_ON, T_SCANNING_OFF);
}

void ledStuck(void) { ledToggle(T_STUCK_ON, T_STUCK_OFF); }

void ledRunning(void) { ledToggle(T_PROCESSING_ON, T_PROCESSING_OFF); }

#endif // LED_CODES_H
