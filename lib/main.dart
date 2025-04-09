import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:vibration/vibration.dart';
import 'details_screen.dart';

Future<void> _messageHandler(RemoteMessage message) async {
  print('background message ${message.notification!.body}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_messageHandler);
  runApp(MessagingTutorial());
}

class MessagingTutorial extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firebase Messaging',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Firebase Messaging'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);
  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late FirebaseMessaging messaging;
  String? notificationText;
  List<String> notificationHistory = [];

  @override
  void initState() {
    super.initState();
    messaging = FirebaseMessaging.instance;
    messaging.subscribeToTopic("messaging");

    // Get FCM token and print it
    messaging.getToken().then((value) {
      print('FCM Token: $value');
    });

    // Handle incoming messages when app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      String type = message.data['type'] ?? 'regular';
      Color bgColor = type == 'important' ? Colors.red : Colors.blue;

      setState(() {
        notificationHistory.add(message.notification?.body ?? '');
      });

      // Vibrate for important notifications
      if (type == 'important') {
        Vibration.vibrate(duration: 500);
      }

      // Show the notification as a dialog
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: bgColor,
          title: Text("Notification", style: TextStyle(color: Colors.white)),
          content: Text(message.notification?.body ?? '', style: TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      );
    });

    // Handle notification tap when app is opened
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      String screen = message.data['screen'] ?? '';

      if (screen == 'details') {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => DetailsScreen(),
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
      ),
      body: notificationHistory.isEmpty
          ? Center(child: Text("No notifications yet", style: TextStyle(fontSize: 18)))
          : ListView.separated(
              itemCount: notificationHistory.length,
              itemBuilder: (context, index) {
                return ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  title: Text(
                    notificationHistory[index],
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    "Received at: ${DateTime.now().toLocal().toString()}",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  leading: Icon(Icons.notifications, color: Colors.blue),
                  onTap: () {
                    // Handle notification tap
                    String screen = "details";
                    if (screen == 'details') {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) => DetailsScreen(),
                      ));
                    }
                  },
                );
              },
              separatorBuilder: (context, index) => Divider(color: Colors.grey),
            ),
    );
  }
}