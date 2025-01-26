#include <Wire.h>
#include <Adafruit_Sensor.h>
#include <Adafruit_ADXL345_U.h>
#include "MMA7660.h"
MMA7660 accelemeter;

// Pin definitions for buttons and joystick
const int button1Pin = 2;
const int button2Pin = 3;
const int button3Pin = 4;
const int button4Pin = 5;
const int button5Pin = 7;
const int joystickXPin = A0; // X-axis of joystick
const int joystickYPin = A1; // Y-axis of joystick
const int joystickButtonPin = 6; // Joystick button

// Joystick deadzone to prevent drift
const int DEADZONE = 10;

// I2C address of the Micro
const int MICRO_ADDRESS = 4;

void setup() {
  accelemeter.init();
  Serial.begin(115200);

  Wire.begin();  // Initialize I2C as Master
  // Set up buttons as inputs with pull-up resistors
  pinMode(button1Pin, INPUT_PULLUP);
  pinMode(button2Pin, INPUT_PULLUP);
  pinMode(button3Pin, INPUT_PULLUP);
  pinMode(button4Pin, INPUT_PULLUP);
  pinMode(button5Pin, INPUT_PULLUP);
  pinMode(joystickButtonPin, INPUT_PULLUP);
}

void loop() {
  // Read button states
  bool button1State = !digitalRead(button1Pin); // Active LOW
  bool button2State = !digitalRead(button2Pin);
  bool button3State = !digitalRead(button3Pin);
  bool button4State = !digitalRead(button4Pin);
  bool button5State = digitalRead(button5Pin);
  bool joystickButtonState = !digitalRead(joystickButtonPin);

  // Read and apply deadzone to joystick
  int joystickX = analogRead(joystickXPin);
  int joystickY = analogRead(joystickYPin);
  int joystickXMapped = abs(joystickX - 512) > DEADZONE ? map(joystickX, 0, 1023, -512, 511) : 0;
  int joystickYMapped = abs(joystickY - 512) > DEADZONE ? map(joystickY, 0, 1023, -512, 511) : 0;

  // Read accelerometer data
  int8_t x, y, z;
  accelemeter.getXYZ(&x, &y, &z);
 // Prepare a compact serial message
  Serial.print("CTRL:");
  Serial.print(button1State);
  Serial.print(",");
  Serial.print(button2State);
  Serial.print(",");
  Serial.print(button3State);
  Serial.print(",");
  Serial.print(button4State);
  Serial.print(",");
  Serial.print(button5State);
  Serial.print(",");
  Serial.print(joystickButtonState);
  Serial.print(",");
  Serial.print(joystickXMapped);
  Serial.print(",");
  Serial.print(joystickYMapped);
  Serial.print(",");
  Serial.print(x);
  Serial.print(",");
  Serial.print(y);
  Serial.print(",");
  Serial.println(z);
  // Create a data packet as a string
  String dataPacket = String(button1State) + "," + 
                      String(button2State) + "," +
                      String(button3State) + "," +
                      String(button4State) + "," +
                      String(button5State) + "," +
                      String(joystickButtonState) + "," +
                      String(joystickXMapped) + "," +
                      String(joystickYMapped) + "," +
                      String(x) + "," + String(y) + "," + String(z);

  // Send data to Micro over I2C
  Wire.beginTransmission(MICRO_ADDRESS);
  Wire.write(dataPacket.c_str()); // Send the data as a string
  Wire.endTransmission();

  delay(50);  // Small delay for stable readings
}
