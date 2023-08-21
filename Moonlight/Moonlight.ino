// #include <Adafruit_NeoPixel.h>
// #include "arduino_secrets.h"
// #include <ArduinoJson.h>
// #include <ArduinoJson.hpp>
// #ifdef __AVR__
//   #include <avr/power.h>
// #endif
// #define PIN        2
// #define NUMPIXELS 24

// Adafruit_NeoPixel pixels(NUMPIXELS, PIN, NEO_GRB + NEO_KHZ800);
// #define DELAYVAL 500
// #include <ESP8266WiFi.h>
// #include <ESP8266WebServer.h>
// #include <PubSubClient.h>
// #include "arduino_secrets.h"
// const char* ssid     = SECRET_SSID;
// const char* password = SECRET_PASS;
// const char* mqttuser = SECRET_MQTTUSER;
// const char* mqttpass = SECRET_MQTTPASS;

// const char* mqtt_server = "mqtt.cetools.org";
// WiFiClient espClient;//handle wifi messages
// PubSubClient client(espClient);
// int airQ;


// void setup() {
// #if defined(__AVR_ATtiny85__) && (F_CPU == 16000000)
//   clock_prescale_set(clock_div_1);
// #endif
//   Serial.begin(115200);
//   pixels.begin();
//     startWifi(); 
//   client.setServer(mqtt_server, 1884);
//   client.setCallback(callback);
//   reconnect();
// }
// void red() {
//   pixels.clear();

//   for(int i=0; i<NUMPIXELS; i++) {

//     pixels.setPixelColor(i, pixels.Color(255, 0, 0));
//     pixels.show();
//     delay(DELAYVAL);
//   }
// }
// void yellow() {
//   pixels.clear();

//   for(int i=0; i<NUMPIXELS; i++) {

//     pixels.setPixelColor(i, pixels.Color(255, 255, 0));
//     pixels.show();
//     delay(DELAYVAL);
//   }
// }
// void green() {
//   pixels.clear();

//   for(int i=0; i<NUMPIXELS; i++) {

//     pixels.setPixelColor(i, pixels.Color(0, 250, 0));
//     pixels.show();
//     delay(DELAYVAL);
//   }
// }
// void loop(){
//   if (airQ == 1){
//   green();
//   }
//   if (airQ == 2 ){
//     yellow();
//   }
//   if(airQ == 3){
//     red();
//   }
//   client.loop();
// }

// void startWifi() {
//   // connecting to a WiFi network
//   Serial.println();
//   Serial.print("Connecting to ");
//   Serial.println(ssid);
//   WiFi.begin(ssid, password);

//   // when not connected keep trying until you are
//   while (WiFi.status() != WL_CONNECTED) {
//     delay(500);
//     Serial.print(".");
//   } 
  
//   //Exit the while loop means have a connection
//   Serial.println("");
//   Serial.println("WiFi connected");
//   Serial.print("IP address: ");
//   Serial.println(WiFi.localIP()); //IP address of Huzzah
// }


// void callback(char* topic, byte* payload, unsigned int length) {
//   Serial.print("Message arrived [");
//   Serial.print(topic);
//   Serial.print("] ");
//   for (int i = 0; i < length; i++) {
//     Serial.print((char)payload[i]);
//   }
//   Serial.println();

//   StaticJsonDocument<1024> doc;// Allocate the JSON document
//   String myString = String((char*)payload);
  
//   deserializeJson(doc, myString); // Deserialize the JSON document

//   // Fetch values.
//   int PM25 = doc["PM2.5"]; 
//   int PM10 = doc["PM10"];
//   Serial.print(PM25);
//   if (PM25 <12 & PM10 < 54){
//     airQ = 1;
//   }
//   if (35.4>PM25>12 | PM10 < 154 ){
//     airQ = 2;
//   }
//   if(PM25 < 35.4 |  54< PM10 <154 ){
//     airQ = 2;
// }
// if(PM25>35.4 | PM10> 154){
//   airQ = 3;
// }
// }
// void reconnect() {
//   // Loop until we're reconnected
//   while (!client.connected()) {
//     Serial.print("Attempting MQTT connection...");
//     // Create a random client ID
//     String clientId = "ESP8266Client-";
//     clientId += String(random(0xffff), HEX);
    
//     // Attempt to connect with clientID, username and password
//     if (client.connect(clientId.c_str(), mqttuser, mqttpass)) {
//       Serial.println("connected");
//       client.subscribe("student/ucfnaob/AirQuality");//subscribe to the topic
//     } else {
//       Serial.print("failed, rc=");
//       Serial.print(client.state());
//       Serial.println(" try again in 5 seconds");
//       // Wait 5 seconds before retrying
//       delay(5000);
//     }
//   }
// }


#include <Adafruit_NeoPixel.h>
#include "arduino_secrets.h"
#include <ArduinoJson.h>
#include <ArduinoJson.hpp>
#ifdef __AVR__
  #include <avr/power.h>
#endif
#define PIN        2
#define NUMPIXELS 24

Adafruit_NeoPixel pixels(NUMPIXELS, PIN, NEO_GRB + NEO_KHZ800);
#define DELAYVAL 500
#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>
#include <PubSubClient.h>
#include "arduino_secrets.h"
const char* ssid     = SECRET_SSID;
const char* password = SECRET_PASS;
const char* mqttuser = SECRET_MQTTUSER;
const char* mqttpass = SECRET_MQTTPASS;

const char* mqtt_server = "mqtt.cetools.org";
WiFiClient espClient;//handle wifi messages
PubSubClient client(espClient);
int airQ;


void setup() {
#if defined(__AVR_ATtiny85__) && (F_CPU == 16000000)
  clock_prescale_set(clock_div_1);
#endif
  Serial.begin(115200);
  pixels.begin();
    startWifi(); 
  client.setServer(mqtt_server, 1884);
  client.setCallback(callback);
  reconnect();
  
}
void red() {
  pixels.clear();

  for(int i=0; i<NUMPIXELS; i++) {

    pixels.setPixelColor(i, pixels.Color(255, 0, 0));

    
  }
      pixels.show();
      delay(DELAYVAL);
}
void yellow() {
  pixels.clear();

  for(int i=0; i<NUMPIXELS; i++) {

    pixels.setPixelColor(i, pixels.Color(255, 255, 0));

  }
        pixels.show();
      delay(DELAYVAL);
}
void green() {
  pixels.clear();

  for(int i=0; i<NUMPIXELS; i++) {

    pixels.setPixelColor(i, pixels.Color(0, 250, 0));

  }
        pixels.show();
      delay(DELAYVAL);
}
void loop(){
  if (airQ == 1){
  green();
  }
  if (airQ == 2 ){
    yellow();
  }
  if(airQ == 3){
    red();
  }
  client.loop();
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


void callback(char* topic, byte* payload, unsigned int length) {
  Serial.print("Message arrived [");
  Serial.print(topic);
  Serial.print("] ");
  for (int i = 0; i < length; i++) {
    Serial.print((char)payload[i]);
  }
  Serial.println();

  StaticJsonDocument<1024> doc;// Allocate the JSON document
  String myString = String((char*)payload);
  
  deserializeJson(doc, myString); // Deserialize the JSON document

  // Fetch values.
  int PM25 = doc["PM2.5"]; 
  int PM10 = doc["PM10"];
  Serial.print(PM25);
  if (PM25 <12 & PM10 < 54){
    airQ = 1;
  }
  if (35.4>PM25>12 | PM10 < 154 ){
    airQ = 2;
  }
  if(PM25 < 35.4 |  54< PM10 <154 ){
    airQ = 2;
}
if(PM25>35.4 | PM10> 154){
  airQ = 3;
}
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