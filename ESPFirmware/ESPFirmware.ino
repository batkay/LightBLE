/*
Written by Thomas Lang
Uses an ESP32-WROOM-DA Module


*/

#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>
#include <BLE2902.h>


// Defines a default name to showup on the lightstick
std::string name = "Lightstick";

// UUID for the service to be findable
#define SERVICE_UUID "b41a63b1-23e5-490a-9366-5867c165fc2a" // randomly generated https://www.uuidgenerator.net/

// diff uuid for characteristic
#define CHARACTERISTIC_UUID "f0c34848-394f-44fd-8a5a-0e6f39d711fe"
#define CHARACTERISTIC_TX "0b369f53-3b8d-4c24-a4e6-0037dd7f27da"

// Checks when a device connects
bool connected = false;

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
  void onWrite(BLECharacteristic *pCharacteristic) {
    std::string val = pCharacteristic -> getValue();

    if (val.length() > 0) {
      Serial.print("Recieved: ");
      for (int i = 0; i < val.length(); ++i) {
        Serial.print(val[i]);

      }

      // ability to do more here
      if (val[0] == '1') {
        digitalWrite(2, HIGH);
      }
      else if (val[0] == '0') {
        digitalWrite(2, LOW);
      }

      Serial.println();
    }
  }
};

void setup() {
  // put your setup code here, to run once:
  Serial.begin(115200);
  Serial.println("Starting BLE");

  // POTENTIAL: read a name from EPROM


  pinMode(2, OUTPUT);
  // Create BLE device
  BLEDevice::init(name);
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
  BLECharacteristic *rxChar = pService -> createCharacteristic(
    CHARACTERISTIC_UUID, BLECharacteristic::PROPERTY_WRITE
  );

  rxChar -> setCallbacks(new MyCharCallbacks);
  // starts the service
  pService->start();

  // start advertising the server
  pServer-> getAdvertising() -> start();
  Serial.println("Server started");
}

void loop() {
  // put your main code here, to run repeatedly:
  if (connected) {
    // Serial.println("Connected");
  }
}
