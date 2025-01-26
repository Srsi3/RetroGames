#include <Wire.h>
#include <Keyboard.h> // For keyboard HID

#define BUFFER_SIZE 64 // Max I2C buffer size

char dataBuffer[BUFFER_SIZE];

void setup() {
  Wire.begin(4); // Start I2C as Slave with address 4
  Wire.onReceive(receiveEvent); // Register receive event
  Keyboard.begin(); // Initialize HID Keyboard
  //Serial.begin(115200);
}

void loop() {
  // Main loop does nothing; actions handled in receiveEvent
}

void receiveEvent(int bytes) {
  if (bytes > BUFFER_SIZE) return; // Ignore oversized packets

  // Read the incoming I2C data
  int i = 0;
  while (Wire.available() > 0) {
    char c = Wire.read();
    if (i < BUFFER_SIZE - 1) {
      dataBuffer[i++] = c;
    }
  }
  dataBuffer[i] = '\0'; // Null-terminate the string

  // Parse the received data
  String data = String(dataBuffer);
  int button1, button2, button3, button4, button5, joystickButton, joystickX, joystickY, accelX, accelY, accelZ;
  sscanf(data.c_str(), "%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d",
         &button1, &button2, &button3, &button4, &button5,
         &joystickButton, &joystickX, &joystickY,
         &accelX, &accelY, &accelZ);

  // Map data to keyboard or joystick inputs
  if (button1) Keyboard.press('k');
  else Keyboard.release('k');

  if (button2) Keyboard.press('i'); 
  else Keyboard.release('i');

  if (button3) Keyboard.press('l'); 
  else Keyboard.release('l');

  if (button4) Keyboard.press('j'); 
  else Keyboard.release('j');

  if (joystickButton) Keyboard.press('q'); 
  else Keyboard.release('q');

  if (joystickX < -100) Keyboard.press('d'); // Example: Left joystick sends 'J'
  else if (joystickX > 100) Keyboard.press('a'); // Example: Right joystick sends 'L'
  else {
    Keyboard.release('d');
    Keyboard.release('a');
  }

  if (joystickY < -100) Keyboard.press('s'); // Example: Left joystick sends 'J'
  else if (joystickY > 100) Keyboard.press('w'); // Example: Right joystick sends 'L'
  else {
    Keyboard.release('s');
    Keyboard.release('w');
  }
}