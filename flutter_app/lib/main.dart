import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyAua55ogDdwqOYWgdRTZP58yTZirjLSri8",
      appId: "1:916125104426:web:cd380776d6562beaee4653",
      messagingSenderId: "916125104426",
      projectId: "iot-ro3b",
      databaseURL: "https://iot-ro3b-default-rtdb.firebaseio.com",
      storageBucket: "iot-ro3b.firebasestorage.app",
    ),
  );

  runApp(const MyApp());
}

// ====== Notifications ======
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
  InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

Future<void> showNotification(String title, String body) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
  AndroidNotificationDetails(
    'alert_channel',
    'Alertes DHT11',
    channelDescription: 'Notifications pour DHT11',
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
  );

  const NotificationDetails platformChannelSpecifics =
  NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    body,
    platformChannelSpecifics,
  );
}

// ====== Application ======
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DHT11 Firebase',
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseReference _dbRef =
  FirebaseDatabase.instance.ref("capteurs/dernier");

  double temperature = 0;
  double humidite = 0;
  String time = "";

  // Intervalle configurable
  double tempMin = 20;
  double tempMax = 30;
  double humMin = 30;
  double humMax = 60;

  bool _alertShown = false;

  @override
  void initState() {
    super.initState();
    initNotifications();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showAlert("Connexion OK", "La carte ESP32 est connectée !");
    });
    _listenFirebase();
  }

  void _listenFirebase() {
    _dbRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        setState(() {
          temperature = (data['tem'] ?? 0).toDouble();
          humidite = (data['hum'] ?? 0).toDouble();
          time = (data['time'] ?? "");
        });

        // Notification si hors intervalle
        if (temperature < tempMin ||
            temperature > tempMax ||
            humidite < humMin ||
            humidite > humMax) {
          showNotification("Alerte DHT11",
              "Temp: $temperature°C Hum: $humidite% hors intervalle !");
        }
      }
    });
  }

  void _showAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Color _getColor(double value, double min, double max) {
    if (value < min || value > max) return Colors.red;
    return Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("DHT11 Sensor"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Intervalle configurable
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        const Text(
                          "Configurer les intervalles",
                          style: TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration:
                                const InputDecoration(labelText: "Temp min"),
                                keyboardType: TextInputType.number,
                                onChanged: (val) {
                                  tempMin = double.tryParse(val) ?? tempMin;
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                decoration:
                                const InputDecoration(labelText: "Temp max"),
                                keyboardType: TextInputType.number,
                                onChanged: (val) {
                                  tempMax = double.tryParse(val) ?? tempMax;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration:
                                const InputDecoration(labelText: "Hum min"),
                                keyboardType: TextInputType.number,
                                onChanged: (val) {
                                  humMin = double.tryParse(val) ?? humMin;
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                decoration:
                                const InputDecoration(labelText: "Hum max"),
                                keyboardType: TextInputType.number,
                                onChanged: (val) {
                                  humMax = double.tryParse(val) ?? humMax;
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Affichage temp/hum
                Card(
                  margin: const EdgeInsets.all(10),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          "Température : $temperature °C",
                          style: TextStyle(
                            fontSize: 24,
                            color: _getColor(temperature, tempMin, tempMax),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Humidité : $humidite %",
                          style: TextStyle(
                            fontSize: 24,
                            color: _getColor(humidite, humMin, humMax),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Dernière mise à jour : $time",
                          style: const TextStyle(
                              fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
