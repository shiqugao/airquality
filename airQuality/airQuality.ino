
#include <PubSubClient.h>
#include <SoftwareSerial.h>
#include <Adafruit_PM25AQI.h>
#include <Wire.h>
#include <Adafruit_Sensor.h>
#include <Adafruit_BME280.h>
#include <ArduinoJson.h>
#if defined(ESP32)
#include <WiFi.h>
#elif defined(ESP8266)
#include <ESP8266WiFi.h>
#endif
#include <Firebase_ESP_Client.h>
#include <addons/TokenHelper.h>
#include <ezTime.h>

/* 1. Define the WiFi credentials */
#define WIFI_SSID "CE-Hub-Student"
#define WIFI_PASSWORD "casa-ce-gagarin-public-service"

#define API_KEY "AIzaSyBFCa5oTp8XbPdIrr5NGqe0CHc5dUn335o"

/* 3. Define the project ID */
#define FIREBASE_PROJECT_ID "airquality-ad334"

/* 4. Define the user Email and password that already registered or added in your project */
#define USER_EMAIL "ucfnaob@ucl.ac.uk"
#define USER_PASSWORD "123456"
// Define Firebase Data object

const char* mqtt_server = "mqtt.cetools.org";
const char* mqttpass ="ce2021-mqtt-forget-whale";
const char* mqttuser = "student";
WiFiClient espClient;//handle wifi messages
PubSubClient client(espClient);
FirebaseData fbdo;

FirebaseAuth auth;
FirebaseConfig config;

String uid;
String path;

#define SDA_PIN D4   
#define SCL_PIN D1

// Define the RX and TX pins for software serial communication
const int rxPin = D2; // Connect PMS5003 TX pin to NodeMCU D2 pin
const int txPin = D3; // Connect PMS5003 RX pin to NodeMCU D3 pin
const int MQ135_PIN = A0;
Timezone GB;
Adafruit_BME280 bme;
SoftwareSerial pmsSerial(rxPin, txPin); // Create a software serial object
Adafruit_PM25AQI aqi; // Create an instance of Adafruit_PM25AQI

const char* ssid = "CE-Hub-Student";
const char* password = "casa-ce-gagarin-public-service";

unsigned long previousMillis = 0;
const long interval = 300000; // 5 minutes in milliseconds

void setup() {
  Serial.begin(115200);
  pmsSerial.begin(9600); // Set the baud rate for software serial
  client.setServer(mqtt_server, 1884);
  if (!aqi.begin_UART(&pmsSerial)) {
    Serial.println("Could not find PM 2.5 sensor!");
    while (1) delay(10);
  }
  
  Wire.begin(SDA_PIN, SCL_PIN);
  
  if (!bme.begin(0x76)) {
    Serial.println("Could not find a valid BME280 sensor, check wiring!");
    while (1);
  }

  Serial.println("PM25 sensor found!");

  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to Wi-Fi");
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(300);
  }
  Serial.println();
  Serial.print("Connected with IP: ");
  Serial.println(WiFi.localIP());
  Serial.println();

  Serial.printf("Firebase Client v%s\n\n", FIREBASE_CLIENT_VERSION);

  /* Assign the api key (required) */
  config.api_key = API_KEY;

  /* Assign the user sign-in credentials */
  auth.user.email = USER_EMAIL;
  auth.user.password = USER_PASSWORD;

  /* Assign the callback function for the long running token generation task */
  config.token_status_callback = tokenStatusCallback; //see addons/TokenHelper.h

  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);

  GB.setLocation("Europe/London");
  waitForSync(); // Wait for NTP sync to get accurate time
}

void loop() {
  unsigned long currentMillis = millis();

  if (currentMillis - previousMillis >= interval) {
    previousMillis = currentMillis;

    PM25_AQI_Data data;

    if (!aqi.read(&data)) {
      Serial.println("Could not read from PM 2.5 sensor!");
      return;
    }

    int sensorValue = analogRead(MQ135_PIN);
    float voltage = sensorValue * (5.0 / 1023.0); // Convert ADC value to voltage
    float ppm = getPPM(voltage); // Convert voltage to PPM

    // Create a JSON object
    StaticJsonDocument<256> jsonDocument;
    
    // Add sensor data to the JSON object
    jsonDocument["PM1"] = data.particles_10um;
    jsonDocument["PM2.5"] = data.particles_25um;
    jsonDocument["PM10"] = data.particles_100um;
    jsonDocument["MQ135_SensorValue"] = sensorValue;
    jsonDocument["MQ135_Voltage"] = voltage;
    jsonDocument["MQ135_PPM"] = ppm;
    jsonDocument["Temperature"] = bme.readTemperature();
    jsonDocument["Humidity"] = bme.readHumidity();
    jsonDocument["Pressure"] = bme.readPressure() / 100.0F;

    // Serialize the JSON object into a string
    String jsonString;
    serializeJson(jsonDocument, jsonString);
    Serial.println(jsonString);

    // Send data to Firebase Realtime Database
    sendDataToFirebase(jsonString);
    sendDataToMQTT(jsonString);
  }
}
void startWifi() {
  // connecting to a WiFi network
  Serial.println();
  Serial.print("Connecting to ");
  Serial.println(ssid);
  WiFi.begin(ssid, password);

  // when not connected keep trying until you are
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  } 
  
  //Exit the while loop means have a connection
  Serial.println("");
  Serial.println("WiFi connected");
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP()); //IP address of Huzzah
}

void sendDataToMQTT(String jsonData) {
  if (!client.connected()) {
    reconnect(); // Reconnect to MQTT broker if not connected
  }

  // Publish the JSON data to the MQTT topic
  const char* mqttTopic = "student/ucfnaob/AirQuality"; // Modify this to your topic
  client.publish(mqttTopic, jsonData.c_str());

  Serial.println("Data sent to MQTT topic: " + String(mqttTopic));
}

void reconnect() {
  // Loop until we're reconnected
  while (!client.connected()) {
    Serial.print("Attempting MQTT connection...");
    // Create a random client ID
    String clientId = "ESP8266Client-";
    clientId += String(random(0xffff), HEX);
    
    // Attempt to connect with clientID, username and password
    if (client.connect(clientId.c_str(), mqttuser, mqttpass)) {
      Serial.println("connected");
      client.subscribe("student/ucfnaob/AirQuality");//subscribe to the topic
    } else {
      Serial.print("failed, rc=");
      Serial.print(client.state());
      Serial.println(" try again in 5 seconds");
      // Wait 5 seconds before retrying
      delay(5000);
    }
  }
}
void sendDataToFirebase(String jsonData) {
  FirebaseJson content;
  content.set("fields/p/stringValue", jsonData);

  // Get the current UK time
  String documentPath = String(GB.dateTime("Y-m-d")) + "/" + String(GB.dateTime("H:i"));

  Serial.print("Create document... ");
  if (Firebase.Firestore.createDocument(&fbdo, FIREBASE_PROJECT_ID, "", documentPath.c_str(), content.raw()))
    Serial.printf("ok\n%s\n\n", fbdo.payload().c_str());
  else
    Serial.println(fbdo.errorReason());
}

float getPPM(float voltage) {
  // Calibration data for MQ135
  float RZERO = 76.63; // Resistance in clean air
  float PARA = 116.6020682; // Parabolic exponent
  float PARB = 2.769034857; // Parabolic coefficient

  float ratio = voltage / 5.0; // Voltage ratio
  float resistance = (5.0 - voltage) / ratio; // Sensor resistance

  float ppm = PARA * pow((resistance / RZERO), -PARB); // Calculate PPM

  return ppm;
}

String formatFirebaseKey(String original) {
  // Remove characters not allowed in Firebase database keys
  original.replace("-", "");
  original.replace(":", "");
  original.replace(" ", ""); // Remove spaces as well
  return original;
}

