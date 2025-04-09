import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:skill_swap/firebase_options.dart';
import 'package:skill_swap/provider/auth.dart';
import 'package:skill_swap/provider/home_provider.dart';
import 'package:skill_swap/screens/auth/login_screen.dart';
import 'package:skill_swap/screens/homescreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LoginProvider()),
        ChangeNotifierProvider(create: (context) => HomeProvider(), lazy: true),
      ],
      builder:
          (context, child) => MaterialApp(
            title: 'Skill Swap',
            theme: ThemeData(
              scaffoldBackgroundColor: Color.fromRGBO(58, 58, 58, 1),
              appBarTheme: AppBarTheme().copyWith(
                backgroundColor: Colors.transparent,
              ),
              colorScheme: ColorScheme.fromSeed(
                brightness: Brightness.dark,
                seedColor: Color.fromRGBO(58, 58, 58, 1),
              ),
            ),
            debugShowCheckedModeBanner: false,
            home:
                FirebaseAuth.instance.currentUser == null
                    ? const LoginScreen()
                    : const Homescreen(),
          ),
    );
  }
}
