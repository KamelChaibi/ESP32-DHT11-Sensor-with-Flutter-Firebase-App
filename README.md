# ESP32 DHT11 Sensor with Flutter Firebase App

## Project Overview

This project integrates an ESP32 microcontroller with a DHT11 temperature and humidity sensor and a Flutter mobile app. The ESP32 firmware reads sensor data and sends it to a Firebase Realtime Database. The Flutter app connects to the same Firebase database to display live sensor readings, alerts, and notifications on a mobile device.

---

## Features

- ESP32 reads temperature and humidity using DHT11 sensor
- ESP32 synchronizes time using NTP to timestamp sensor readings
- Sensor data (temperature, humidity, time) is sent to Firebase Realtime Database every 2 seconds
- Flutter app listens to Firebase for real-time updates
- Configurable alert thresholds for temperature and humidity in the app
- Local notifications on the device when values are out of set ranges
- Alert dialog on app startup confirming ESP32 connection

![1](https://github.com/user-attachments/assets/d204ff0d-2f02-450c-8872-f3555d05901a)



https://github.com/user-attachments/assets/72c60c6c-5e31-4c16-9a99-fcc6db4a5409



---

## Hardware Setup

- ESP32 development board
- DHT11 temperature and humidity sensor connected to GPIO 15 of ESP32

---

## Software Setup

### ESP32 Firmware

- Uses Arduino IDE or compatible environment
- Required libraries:
  - WiFi.h
  - FirebaseESP32.h
  - DHT.h
  - NTPClient.h
  - WiFiUdp.h
- Configuration parameters in `esp32.ino`:
  - WiFi SSID and password
  - Firebase Realtime Database host and authentication token
- The firmware reads the sensor values, gets current time from NTP, and uploads JSON data with keys `"tem"`, `"hum"`, and `"time"` to Firebase path `/capteurs/dernier`.

### Flutter App

- Developed using Flutter SDK
- Dependencies:
  - firebase_core
  - firebase_database
  - flutter_local_notifications
- Firebase initialized using project-specific API keys and database URL (configured in `lib/main.dart`)
- Listens to the `/capteurs/dernier` node on Firebase to receive sensor data updates
- UI allows users to configure acceptable ranges for temperature and humidity
- Shows alerts and local notifications when sensor values fall outside these ranges

---

## Usage Instructions

1. Flash the `esp32.ino` firmware onto your ESP32.
2. Ensure the ESP32 connects to your WiFi network and can authenticate with Firebase.
3. Run the Flutter app on a mobile device or emulator.
4. On app startup, an alert dialog will confirm the ESP32 connection.
5. Configure temperature and humidity thresholds in the app if needed.
6. View real-time temperature, humidity, and last update time.
7. Receive notifications if readings go outside the configured ranges.

---

## How It Works

- ESP32 collects sensor data and timestamps it via NTP.
- Data is sent to Firebase Realtime Database under the path `/capteurs/dernier`.
- Flutter app listens to the Firebase database changes in real time.
- When new data arrives, the app updates the UI and checks if the readings are within the user-defined ranges.
- If out of range, a local notification alerts the user.

---

## Notes

- Make sure your Firebase project settings and database rules allow read/write access for the ESP32 and Flutter app.
- Adjust the WiFi credentials and Firebase tokens in `esp32.ino` to match your environment.
- The sensor readings update every 2 seconds by default.

---

## License

This project is open source and available for modification and distribution.

---
