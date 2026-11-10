import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'services/fcm_service.dart';

// Top-level background handler required by FlutterFire
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Background isolates cannot directly call setState() on UI widgets
  debugPrint('FCM Background message received: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Register background callback
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const FCMApp());
}

class FCMApp extends StatelessWidget {
  const FCMApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FCM Promo Showcase',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const PromoScreen(),
    );
  }
}

class PromoScreen extends StatefulWidget {
  const PromoScreen({super.key});

  @override
  State<PromoScreen> createState() => _PromoScreenState();
}

class _PromoScreenState extends State<PromoScreen> {
  final FCMService _fcmService = FCMService();

  String _token = 'Fetching token...';
  String _permissionStatus = 'Checking...';
  String _lastHandler = 'None';
  int _receiptCount = 0;
  String _lastMessageId = 'None';
  String _diagnostic = 'Ready. Awaiting messages.';

  // Default initial state: standard popcorn chicken
  String _currentAsset = 'assets/popcorn_chicken_default.jpeg';
  String _promoTitle = 'Publix Deli Popcorn Chicken';

  @override
  void initState() {
    super.initState();
    _setupFCM();
  }

  Future<void> _setupFCM() async {
    // 1. Permission check
    NotificationSettings settings = await _fcmService.requestPermission();
    setState(() {
      _permissionStatus = settings.authorizationStatus.toString().split('.').last;
    });

    // 2. Fetch Registration Token
    String? token = await _fcmService.getToken();
    setState(() {
      _token = token ?? 'Failed to retrieve token';
    });
    debugPrint('FCM Device Token: $_token');

    // 3. Initialize foreground and background tap listeners
    _fcmService.initializeListeners(
      onMessageReceived: (message) => _handlePayload(message, 'FirebaseMessaging.onMessage (Foreground)'),
      onMessageOpened: (message) => _handlePayload(message, 'FirebaseMessaging.onMessageOpenedApp (Background Tap)'),
    );

    // 4. Check for cold-start launch via notification tap
    RemoteMessage? initialMessage = await _fcmService.checkInitialMessage();
    if (initialMessage != null) {
      _handlePayload(initialMessage, 'FirebaseMessaging.getInitialMessage (Cold Start)');
    }
  }

  // Payload Shield: validates keys and values safely
  void _handlePayload(RemoteMessage message, String handlerName) {
    setState(() {
      _lastHandler = handlerName;
      _receiptCount++;
      _lastMessageId = message.messageId ?? 'Unknown ID';

      final Map<String, dynamic> data = message.data;
      final String? action = data['action'];
      final String? asset = data['asset'];

      if (action == 'update_ui') {
        if (asset == 'promo') {
          _currentAsset = 'assets/bogo_chicken_promo.jpeg';
          _promoTitle = message.notification?.title ?? 'Publix BOGO Chicken Special!';
          _diagnostic = 'Valid payload: Switched to BOGO promo asset.';
        } else if (asset == 'default') {
          _currentAsset = 'assets/popcorn_chicken_default.jpeg';
          _promoTitle = message.notification?.title ?? 'Publix Deli Popcorn Chicken';
          _diagnostic = 'Valid payload: Switched to default popcorn chicken asset.';
        } else {
          // Unsupported value: protect UI and report diagnostic
          _diagnostic = 'Payload Shield Triggered: Unsupported asset value "$asset". Preserving UI.';
        }
      } else {
        // Missing or invalid action key
        _diagnostic = 'Payload Shield Triggered: Missing or invalid action key "$action".';
      }
    });
  }

  @override
  void dispose() {
    _fcmService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('In-Class 14: Promotional FCM'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Promotional Banner / Image View
            Card(
              clipBehavior: Clip.antiAlias,
              elevation: 4,
              child: Column(
                children: [
                  Image.asset(
                    _currentAsset,
                    height: 240,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 240,
                        color: Colors.grey.shade300,
                        child: const Center(
                          child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                        ),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      _promoTitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Diagnostic & Metadata Panel
            Card(
              color: Colors.grey.shade100,
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Telemetry & Diagnostics',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Divider(),
                    Text('• Last Handler: $_lastHandler'),
                    Text('• Receipt Count: $_receiptCount'),
                    Text('• Last Message ID: $_lastMessageId'),
                    Text(
                      '• Diagnostic: $_diagnostic',
                      style: TextStyle(
                        color: _diagnostic.contains('Triggered')
                            ? Colors.red.shade700
                            : Colors.green.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text('• Permission Status: $_permissionStatus'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Token Panel (selectable for copying into Firebase Console)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Device Registration Token (Target):',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    SelectableText(
                      _token,
                      style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}