

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:sewamitra/provider/contact_Admin.dart';
import 'package:sewamitra/provider/providerHomeScreen.dart';
import 'package:sewamitra/provider/providerProfile.dart';
import 'package:sewamitra/provider/provider_notifications_screen.dart';
import 'package:sewamitra/services/fcm_service.dart';
import 'package:sewamitra/services/get_service_key.dart';
import 'package:sewamitra/services/notification_service.dart';
import 'package:sewamitra/services/send_notification_service.dart';
import 'package:sewamitra/user/cart.dart';
import 'package:sewamitra/user/profile.dart';
import 'package:sewamitra/user/userHomeScreen.dart';
import 'package:sewamitra/user/user_notifications_screen.dart';

import 'notificationService.dart';

// ✅ Must be a top-level function, annotated for background isolate
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // ✅ Register background handler BEFORE runApp
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  runApp(
    ChangeNotifierProvider(
      create: (context) => ServiceDataProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  NotificationServices notificationService = NotificationServices();

  @override
  void initState() {
    super.initState();
    notificationService.requestNotificationPermission();
    notificationService.getDeviceToken();
    FcmService.firebaseInit();
    notificationService.firebaseInit(context);
    notificationService.setupInteractedMessage(context);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SewaMitra',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF5D69BE),
        fontFamily: 'Poppins',
      ),
      routes: {
        '/role_selection': (context) => const RoleSelectionScreen(),
        '/auth': (context) => const AuthTabsScreen(),
        '/home_user': (context) => const HomeScreen(),
        '/home_provider': (context) => const ProviderHomeScreen(),
        '/user_home': (context) => const UserHomeScreen(),
        '/auth_tabs': (context) => const AuthTabsScreen(),
        '/cart': (context) => const BookingsScreen(),
        '/notifications': (context) => const ProviderNotificationsScreen(),
        '/usernotification': (context) => const UserNotificationsScreen(),
        '/contactadmin': (context) => const ContactAdminScreen(),

        '/profile': (context) {
          final user = FirebaseAuth.instance.currentUser;
          if (user == null) return const AuthTabsScreen();
          return ProfileScreen(userId: user.uid);
        },
        '/provider_profile': (context) {
          final user = FirebaseAuth.instance.currentUser;
          if (user == null) return const AuthTabsScreen();
          return ProviderProfileScreen(providerId: user.uid);
        },
        LocationScreen.routeName: (_) => LocationScreen(),
        ServiceProvidersScreen.routeName: (context) =>
        const ServiceProvidersScreen(),
      },
      home: const SplashScreen(),
    );
  }
}



// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});
//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   bool _showSkipButton = false;
//   bool _showProgress = true;
//
//   @override
//   void initState() {
//     super.initState();
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
//     _controller =
//         AnimationController(vsync: this, duration: const Duration(seconds: 3));
//     _controller.forward();
//
//     Future.delayed(const Duration(milliseconds: 1500), () {
//       if (mounted) setState(() => _showSkipButton = true);
//     });
//
//     // On splash end, check login state and navigate accordingly
//     Future.delayed(const Duration(seconds: 3), () async {
//       if (!mounted) return;
//
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) {
//         // No user logged in
//         if (mounted) {
//           Navigator.pushReplacementNamed(context, '/role_selection');
//         }
//       } else {
//         // User is logged in, check role in Realtime Database
//         final db = FirebaseDatabase.instance.ref();
//         final uid = user.uid;
//
//         final snapshotUser = await db.child('users').child(uid).get();
//         final snapshotProvider = await db.child('providers').child(uid).get();
//
//         if (snapshotUser.exists) {
//           if (mounted) Navigator.pushReplacementNamed(context, '/home_user');
//         } else if (snapshotProvider.exists) {
//           if (mounted) Navigator.pushReplacementNamed(context, '/home_provider');
//         } else {
//           // User logged in but no role data - go to profile setup
//           if (mounted) {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => ProfileSetupScreen(
//                   uid: uid,
//                   phone: user.phoneNumber,
//                   email: user.email,
//                   isProviderDefault: false,
//                 ),
//               ),
//             );
//           }
//         }
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
//     super.dispose();
//   }
//
//   void _skip() {
//     if (mounted) Navigator.pushReplacementNamed(context, '/role_selection');
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final gradientColors = [
//       const Color(0xFF5D69BE),
//       const Color(0xFFC89FEB)
//     ];
//
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//               colors: gradientColors,
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter),
//         ),
//         child: SafeArea(
//           child: Stack(
//             children: [
//               Center(
//                 child: Column(mainAxisSize: MainAxisSize.min, children: [
//                   Image.asset('assets/images/logo.png', width: 130, height: 130),
//                   const SizedBox(height: 16),
//                   const Text('HomeServe',
//                       style: TextStyle(
//                           fontSize: 30,
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                           fontFamily: 'Poppins')),
//                   const SizedBox(height: 8),
//                   const Text('Book services at your doorstep',
//                       style: TextStyle(
//                           color: Colors.white70, fontFamily: 'Poppins')),
//                   const SizedBox(height: 24),
//                   if (_showProgress) const CircularProgressIndicator(),
//                 ]),
//               ),
//               if (_showSkipButton)
//                 Positioned(
//                   top: 20,
//                   right: 16,
//                   child: TextButton(
//                     onPressed: _skip,
//                     child: const Text('Skip',
//                         style: TextStyle(
//                             color: Colors.white, fontFamily: 'Poppins')),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _showSkipButton = false;
  bool _showProgress = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _controller.forward();
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _showSkipButton = true);
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _showProgress = false);
        Navigator.pushReplacementNamed(context, '/role_selection');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _skip() {
    if (mounted) Navigator.pushReplacementNamed(context, '/role_selection');
  }

  @override
  Widget build(BuildContext context) {
    final gradientColors = [const Color(0xFF5D69BE), const Color(0xFFC89FEB)];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/logoicon.png',
                      width: 130,
                      height: 130,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'HomeServe',
                      style: TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Book services at your doorstep',
                      style: TextStyle(
                        color: Colors.white70,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_showProgress) const CircularProgressIndicator(),
                  ],
                ),
              ),
              if (_showSkipButton)
                Positioned(
                  top: 20,
                  right: 16,
                  child: TextButton(
                    onPressed: _skip,
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gradientColors = [const Color(0xFF5D69BE), const Color(0xFFC89FEB)];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/logoicon.png',
                  width: 120,
                  height: 120,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Continue as',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: 220, // fixed width for both buttons
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF5D69BE),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed:
                        () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => const AuthTabsScreen(isProvider: false),
                          ),
                        ),
                    child: const Text(
                      'User',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: 220, // same width here
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF5D69BE),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed:
                        () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => const AuthTabsScreen(isProvider: true),
                          ),
                        ),
                    child: const Text(
                      'Service Provider',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
                // const SizedBox(height: 24),
                // ElevatedButton(onPressed: () async {
                //   GetServerKey getServerKey = GetServerKey();
                //   String accessToken = await getServerKey.getServerKeyToken();
                //   print(accessToken);
                //
                // }, child: Text("server key"))
                // const SizedBox(height: 24),
                // ElevatedButton(
                //   onPressed: () async {
                //     await SendNotificationService.sendNotificationUsingApi(
                //       token:
                //           "fLjb2gsAT1W2kozUwyg9GJ:APA91bHYO9a1p00wDzaJdFQe-SENknIwI9s2emqUuEYqVnolC-qYSgvqLlXj41zKRbnsSHBLNJxSDwDA0aUxWN6hBelXgfrEAFAPX7PplofgXDizkoM-q-8",
                //       title: "check",
                //       body: "How are you",
                //       data: {
                //         "click_action": "FLUTTER_NOTIFICATION_CLICK",
                //       },
                //     );
                //     EasyLoading.dismiss();
                //   },
                //   child: Text(" key"),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AuthTabsScreen extends StatefulWidget {
  final bool? isProvider;

  const AuthTabsScreen({super.key, this.isProvider});

  @override
  State<AuthTabsScreen> createState() => _AuthTabsScreenState();
}

class _AuthTabsScreenState extends State<AuthTabsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isProviderSelectionLocked = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    if (widget.isProvider != null) _isProviderSelectionLocked = true;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sign in',
          style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
        ),
        backgroundColor: const Color(0xFF5D69BE),
        bottom: TabBar(
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          controller: _tabController,
          tabs: const [
            Tab(text: 'Phone (OTP)', icon: Icon(Icons.phone)),
            Tab(text: 'Email / Password', icon: Icon(Icons.email)),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF5D69BE), Color(0xFFC89FEB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            PhoneAuthTab(isProvider: widget.isProvider ?? false),
            EmailAuthTab(isProvider: widget.isProvider ?? false),
          ],
        ),
      ),
    );
  }
}

class PhoneAuthTab extends StatefulWidget {
  final bool isProvider;

  const PhoneAuthTab({super.key, required this.isProvider});

  @override
  State<PhoneAuthTab> createState() => _PhoneAuthTabState();
}

class _PhoneAuthTabState extends State<PhoneAuthTab> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  String? _verificationId;
  bool _codeSent = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'Enter phone number';
      });
      return;
    }

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
          await _postSignIn(FirebaseAuth.instance.currentUser);
        },
        verificationFailed: (e) {
          setState(() {
            _loading = false;
            _error = e.message;
          });
        },
        codeSent: (verificationId, forceResendingToken) {
          setState(() {
            _verificationId = verificationId;
            _codeSent = true;
            _loading = false;
          });
        },
        codeAutoRetrievalTimeout: (verificationId) {
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Failed to send OTP: $e';
      });
    }
  }

  Future<void> _verifyCodeAndSignIn() async {
    final code = _otpController.text.trim();
    if (_verificationId == null) {
      setState(() {
        _error = 'No verification id. Request OTP again.';
      });
      return;
    }
    if (code.length < 4) {
      setState(() {
        _error = 'Enter valid OTP';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: code,
      );
      final userCred = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      await _postSignIn(userCred.user);
    } on FirebaseAuthException catch (e) {
      setState(() {
        _loading = false;
        _error = e.message;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Unexpected error: $e';
      });
    }
  }

  Future<void> _postSignIn(User? user) async {
    if (user == null) {
      setState(() {
        _loading = false;
        _error = 'Authentication failed';
      });
      return;
    }
    final db = FirebaseDatabase.instance.ref();
    final uid = user.uid;

    final snapshotUser = await db.child('users').child(uid).get();
    final snapshotProvider = await db.child('providers').child(uid).get();

    if (snapshotUser.exists) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home_user');
      return;
    } else if (snapshotProvider.exists) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home_provider');
      return;
    } else {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (_) => ProfileSetupScreen(
                uid: uid,
                phone: user.phoneNumber ?? _phoneController.text.trim(),
                email: user.email,
                isProviderDefault: widget.isProvider,
              ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final phoneField = TextField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Phone (include country code)',
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white70),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );

    final otpField = TextField(
      controller: _otpController,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Enter OTP',
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white70),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          phoneField,
          const SizedBox(height: 24),
          if (_codeSent) otpField,
          const SizedBox(height: 24),
          if (_error != null)
            Text(
              _error!,
              style: const TextStyle(
                color: Colors.amber,
                fontFamily: 'Poppins',
              ),
            ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF5D69BE),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed:
                  _loading
                      ? null
                      : (_codeSent ? _verifyCodeAndSignIn : _sendCode),
              child:
                  _loading
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : Text(
                        _codeSent ? 'Verify & Sign in' : 'Send OTP',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
            ),
          ),
          if (_codeSent)
            TextButton(
              onPressed: _sendCode,
              child: const Text(
                'Resend OTP',
                style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
              ),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class EmailAuthTab extends StatefulWidget {
  final bool isProvider;

  const EmailAuthTab({super.key, required this.isProvider});

  @override
  State<EmailAuthTab> createState() => _EmailAuthTabState();
}

class _EmailAuthTabState extends State<EmailAuthTab> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _showSignup = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final email = _emailController.text.trim();
    final pass = _passwordController.text;

    if (email.isEmpty || pass.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'Enter email and password';
      });
      return;
    }

    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: pass,
      );
      await _postSignIn(cred.user);
    } on FirebaseAuthException catch (e) {
      setState(() {
        _loading = false;
        if (e.code == 'user-not-found') {
          _showSignup = true;
          _error = 'User not found — please sign up';
        } else {
          _error = e.message;
        }
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Unexpected error: $e';
      });
    }
  }

  Future<void> _signup() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final email = _emailController.text.trim();
    final pass = _passwordController.text;

    if (email.isEmpty || pass.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'Enter email and password';
      });
      return;
    }

    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: pass,
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (_) => ProfileSetupScreen(
                uid: cred.user!.uid,
                phone: null,
                email: email,
                isProviderDefault: widget.isProvider,
              ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _loading = false;
        _error = e.message;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Unexpected error: $e';
      });
    }
  }

  Future<void> _postSignIn(User? user) async {
    if (user == null) {
      setState(() {
        _loading = false;
        _error = 'Authentication failed';
      });
      return;
    }
    final uid = user.uid;
    final db = FirebaseDatabase.instance.ref();

    final snapshotUser = await db.child('users').child(uid).get();
    final snapshotProvider = await db.child('providers').child(uid).get();

    if (snapshotUser.exists) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home_user');
    } else if (snapshotProvider.exists) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home_provider');
    } else {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (_) => ProfileSetupScreen(
                uid: uid,
                phone: user.phoneNumber,
                email: user.email,
                isProviderDefault: widget.isProvider,
              ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Email',
              labelStyle: const TextStyle(color: Colors.white70),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white70),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _passwordController,
            obscureText: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Password (min 6 chars)',
              labelStyle: const TextStyle(color: Colors.white70),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white70),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (_error != null)
            Text(
              _error!,
              style: const TextStyle(
                color: Colors.amber,
                fontFamily: 'Poppins',
              ),
            ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF5D69BE),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _loading ? null : (_showSignup ? _signup : _login),
              child:
                  _loading
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : Text(
                        _showSignup ? 'Sign Up' : 'Sign In',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              setState(() {
                _showSignup = !_showSignup;
                _error = null;
              });
            },
            child: Text(
              _showSignup ? 'Have an account? Sign in' : 'No account? Sign up',
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileSetupScreen extends StatefulWidget {
  final String uid;
  final String? phone;
  final String? email;
  final bool isProviderDefault;

  const ProfileSetupScreen({
    super.key,
    required this.uid,
    this.phone,
    this.email,
    this.isProviderDefault = false,
  });

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isProvider = false;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _isProvider = widget.isProviderDefault;
    if (widget.phone != null) _phoneController.text = widget.phone!;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    NotificationServices notificationServices = NotificationServices();
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    String userDeviceToken = await notificationServices.getDeviceToken();

    if (name.isEmpty) {
      setState(() {
        _error = 'Please enter name';
      });
      return;
    }
    if (phone.isEmpty) {
      setState(() {
        _error = 'Please enter phone';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final db = FirebaseDatabase.instance.ref();
    final rolePath = _isProvider ? 'providers' : 'users';
    final uid = widget.uid;

    final data = {
      'uid': uid,
      'name': name,
      'phone': phone,
      'role': _isProvider ? 'provider' : 'user',
      'email': widget.email ?? '',
      'createdAt': ServerValue.timestamp,
      'token': userDeviceToken,
    };

    try {
      await db.child(rolePath).child(uid).set(data);
      if (!mounted) return;
      if (_isProvider) {
        Navigator.pushReplacementNamed(context, '/home_provider');
      } else {
        Navigator.pushReplacementNamed(context, '/home_user');
      }
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Failed to save profile: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Complete Profile',
          style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
        ),
        backgroundColor: const Color(0xFF5D69BE),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF5D69BE), Color(0xFFC89FEB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  labelStyle: const TextStyle(color: Colors.white70),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white70),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Phone (include country code)',
                  labelStyle: const TextStyle(color: Colors.white70),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white70),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Text(
                    'Role:',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(width: 12),
                  ChoiceChip(
                    label: const Text(
                      'User',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    selected: !_isProvider,
                    selectedColor: const Color(0xFF5D69BE),
                    backgroundColor: Colors.white.withOpacity(0.2),
                    onSelected:
                        (v) => setState(() => _isProvider = !v ? true : false),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text(
                      'Provider',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    selected: _isProvider,
                    selectedColor: const Color(0xFF5D69BE),
                    backgroundColor: Colors.white.withOpacity(0.2),
                    onSelected: (v) => setState(() => _isProvider = v),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (_error != null)
                Text(
                  _error!,
                  style: const TextStyle(
                    color: Colors.amber,
                    fontFamily: 'Poppins',
                  ),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF5D69BE),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _loading ? null : _saveProfile,
                  child:
                      _loading
                          ? const CircularProgressIndicator()
                          : const Text(
                            'Save & Continue',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = true;
  String? userRole;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final database = FirebaseDatabase.instance.ref();
      final userSnapshot = await database.child('users').child(user.uid).get();
      final providerSnapshot =
          await database.child('providers').child(user.uid).get();

      setState(() {
        if (userSnapshot.exists) {
          userRole = 'user';
        } else if (providerSnapshot.exists) {
          userRole = 'provider';
        }
        isLoading = false;
      });

      // After loading role, navigate accordingly
      if (userRole == 'user') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => UserHomeScreen()),
        );
      } else if (userRole == 'provider') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProviderHomeScreen()),
        );
      } else {
        // Role not found, show error or navigate to login
      }
    } else {
      // User not logged in, maybe navigate to login
      setState(() {
        isLoading = false;
      });
      // Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child:
            isLoading
                ? const CircularProgressIndicator()
                : const Text('No user logged in'),
      ),
    );
  }
}
