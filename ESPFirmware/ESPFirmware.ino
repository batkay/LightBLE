/*
Written by Thomas Lang
Uses an ESP32-WROOM-DA Module

EEPROM SETUP

Bytes:
0
Canary, test whether somethingw as written before

1 - 20
Name

21
\0, or something else. extra byte

*/

#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>
#include <BLE2902.h>
#include <Adafruit_NeoPixel.h>
#include <EEPROM.h>



#define LED 5
#define SHAKE 36
#define BUTTON 33

// ms for button debounce
#define debounceDelay 50

#define numLed 17

#define EEPROMSIZE 20

#define CANARY 23 // yuqi's favorite number

// UUID for the service to be findable
#define SERVICE_UUID "b41a63b1-23e5-490a-9366-5867c165fc2a" // randomly generated https://www.uuidgenerator.net/

// diff uuid for characteristic
#define RED_UUID "f0c34848-394f-44fd-8a5a-0e6f39d711fe"
#define BLUE_UUID "52f09b90-df0f-4783-bc36-dca7e3a792f7"
#define GREEN_UUID "85a61293-1b8e-4127-b8bf-94e8f8c73d20"
#define CHARACTERISTIC_TX "0b369f53-3b8d-4c24-a4e6-0037dd7f27da"

#define NAME_UUID "e25e0e65-52c1-4d10-9dc4-c0b52521e769"


// define the rgb colors
unsigned char red = 0;
unsigned char green = 0;
unsigned char blue = 255;

// Checks when a device connects
bool connected = false;

// debounce vars
int buttonState = LOW;
int lastButtonState = LOW;
unsigned long lastDebounceTime = millis();


// light properties
Adafruit_NeoPixel lights = Adafruit_NeoPixel(numLed, LED, NEO_GRB);

// global to be edited in callback
char name[EEPROMSIZE + 1]; // 20 long names, extra for \0
int count = 0;

// create callbacks for the server: prints when is connected or not
class MyServerCallbacks: public BLEServerCallbacks {
  void onConnect(BLEServer* pServer) {
    connected = true;
    Serial.println("Connected");
  }
  void onDisconnect(BLEServer* pServer) {
    connected = false;
    Serial.println("Disconnected");
  }
};


// create callbacks for the BLE characteristic
class MyCharCallbacks: public BLECharacteristicCallbacks {
  unsigned char* color = NULL;
  public:
  MyCharCallbacks() {

  }
  MyCharCallbacks(unsigned char* color) {
    this -> color = color;
  }
  void onWrite(BLECharacteristic *pCharacteristic) {
    std::string val = pCharacteristic -> getValue();

    if (val.length() > 0) {
      Serial.print("Recieved: ");
      for (int i = 0; i < val.length(); ++i) {
        Serial.println(val[i]);

      }

      // ability to do more here
      if (val[0] == '1') {
        digitalWrite(2, HIGH);
      }
      else if (val[0] == '0') {
        digitalWrite(2, LOW);
      }

      if (color != NULL) {
        *color = val[0];
      }

      Serial.println();
    }
  }
};

class NameCallback: public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic *pCharacteristic) {
    std::string val = pCharacteristic -> getValue();

    if (val.length() > 0) {
      Serial.print("Recieved: ");
      EEPROM.write(0, CANARY);
      EEPROM.commit();
      Serial.println(EEPROM.read(0));
      EEPROM.write(22, '\0');
      for (int i = 0; i < val.length(); ++i) {
        Serial.println(val[i]);

        EEPROM.write(count+ 1, val[i]);
        EEPROM.commit();
        // Serial.println(EEPROM.read(count + 1));
        name[count ++] = val[i];
        if (val[i] == '\0' || count == 20) {
          count = 0;
          break;
        }
      }
    }
  }
};

enum State {
  BLUETOOTH,
  PURPLE,
  GRADIENT,
  OFF
};

State currentState = BLUETOOTH;

State nextState(State currentState) {
  switch(currentState) {
    case BLUETOOTH:
    return PURPLE;
    case PURPLE:
    return GRADIENT;
    case GRADIENT:
    return OFF;
    case OFF:
    return BLUETOOTH;
  }

}



void setup() {
  // put your setup code here, to run once:
  Serial.begin(115200);
  Serial.println("Starting BLE");

  // POTENTIAL: read a name from EPROM

  EEPROM.begin(EEPROMSIZE + 2); // eeprom size char, 1 byte for \0, 1 for canary

  Serial.println(EEPROM.read(0));

  unsigned char canary = EEPROM.read(0);
  if (canary == CANARY) {
    for (int i = 1; i < EEPROMSIZE + 1; ++i) {
      char read = EEPROM.read(i);
      Serial.println(read);
      name[i - 1] = read;
      if (read == '\0') {
        
        break;
      }
    }
  }
  else {
    strncpy(name, "Default", EEPROMSIZE) + 1;
  }
  name[20] = '\0';

  std::string nameStr(name);

  pinMode(LED, OUTPUT);
  pinMode(BUTTON, INPUT_PULLUP);

  Serial.println(name);

  // Create BLE device
  BLEDevice::init(nameStr);
  // Create BLE server and set its callbacks
  BLEServer *pServer = BLEDevice::createServer();
  pServer -> setCallbacks(new MyServerCallbacks());
  // create a service within server  
  BLEService *pService = pServer->createService(SERVICE_UUID);

  // create a test char to send data
  BLECharacteristic *txChar = pService -> createCharacteristic(
    CHARACTERISTIC_TX, BLECharacteristic::PROPERTY_NOTIFY | BLECharacteristic::PROPERTY_READ
  );
  txChar -> addDescriptor(new BLE2902());
  txChar -> setValue("(G)-IDLE");

  // create a characteristic to recieve data
  BLECharacteristic *rChar = pService -> createCharacteristic(
    RED_UUID, BLECharacteristic::PROPERTY_WRITE
  );
  rChar -> setCallbacks(new MyCharCallbacks(&red));

  BLECharacteristic *bChar = pService -> createCharacteristic(
    BLUE_UUID, BLECharacteristic::PROPERTY_WRITE
  );
  bChar -> setCallbacks(new MyCharCallbacks(&blue));

  BLECharacteristic *gChar = pService -> createCharacteristic(
    GREEN_UUID, BLECharacteristic::PROPERTY_WRITE
  );
  gChar -> setCallbacks(new MyCharCallbacks(&green));

  BLECharacteristic *nameChar = pService -> createCharacteristic(
    NAME_UUID, BLECharacteristic::PROPERTY_WRITE
  );
  nameChar -> setCallbacks(new NameCallback());

  // starts the service
  pService->start();

  // start advertising the server
  pServer-> getAdvertising() -> start();
  Serial.println("Server started");

  lights.begin();
  lights.setBrightness(200);
}

void loop() {
  // button debounce
  unsigned long time = millis();
  int buttonState = digitalRead(BUTTON);

  if (buttonState != lastButtonState) {
    lastDebounceTime = time;
  }

  if (time - lastDebounceTime > debounceDelay) {
    if (buttonState != buttonState) {
      buttonState = buttonState;

      if (buttonState == LOW) {
        currentState = nextState(currentState);
      }
    }
  }
  lastButtonState = buttonState;


  // led states

  switch(currentState) {
    case BLUETOOTH:
      for (int i = 0; i < numLed; ++i) {
        lights.setPixelColor(i, lights.Color(green, red, blue));
      }
      lights.show();
    break;
    case PURPLE:
      for (int i = 0; i < numLed; ++i) {
        lights.setPixelColor(i, lights.Color(238,130,238));
      }
      lights.show();
    break;
    case GRADIENT:
      for (int i = 0; i < numLed; ++i) {
        lights.setPixelColor(i, lights.Color(green, red, blue));
      }
      lights.show();
    case OFF:
      esp_sleep_enable_ext0_wakeup(GPIO_NUM_33, 0); // 0 for low when pressed, 1 for high
      esp_deep_sleep_start();
      // will probably stop after this
    break;
  }

  if (connected) {
    // Serial.println("Connected");
  }
}