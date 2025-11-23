#include <WiFi.h>
#include <FirebaseESP32.h>
#include <DHT.h>
#include <NTPClient.h>
#include <WiFiUdp.h>

// ---------- WiFi ----------
const char* ssid ="iPhone";
const char* pass ="12345678gg";

// ---------- DHT ----------
#define DHTPIN 15
#define DHTTYPE DHT11
DHT dht(DHTPIN, DHTTYPE);

// ---------- NTP ----------
WiFiUDP ntpUDP;
NTPClient timeClient(ntpUDP, "pool.ntp.org", 3600);

// ---------- Firebase ----------
FirebaseData fbdo;
FirebaseConfig config;
FirebaseAuth auth;

// ---------- FIREBASE KEYS ----------
#define FIREBASE_HOST "iot-ro3b-default-rtdb.firebaseio.com"
#define FIREBASE_AUTH "IlBvnetwuhbobTUTAzFj2FSVGAZO2eQ8lU5v3of0"

void setup() {
  Serial.begin(115200);

  // WiFi
  WiFi.begin(ssid, pass);
  Serial.print("Connecting");
  while (WiFi.status() != WL_CONNECTED) {
    delay(300);
    Serial.print(".");
  }
  Serial.println("\nWiFi Connected!");

  // NTP time
  timeClient.begin();

  // Firebase config
  config.host = FIREBASE_HOST;
  config.signer.tokens.legacy_token = FIREBASE_AUTH;
  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);

  dht.begin();
}

void loop() {
  timeClient.update();

  float temp = dht.readTemperature();
  float hum = dht.readHumidity();

  if (!isnan(temp) && !isnan(hum)) {
    FirebaseJson json;
    json.add("tem", temp);
    json.add("hum", hum);
    json.add("time", timeClient.getFormattedTime());

    if (Firebase.setJSON(fbdo, "/capteurs/dernier", json)) {
      Serial.println("Updated:");
      Serial.println("Temp = " + String(temp));
      Serial.println("Hum = " + String(hum));
      Serial.println("Time = " + timeClient.getFormattedTime());
      Serial.println("----------------------");
    }
  }

  delay(2000);  // <--- Refresh kol 2 secondes
}
