import 'package:fish_cab/aunthentication%20pages/auth_page.dart';
import 'package:fish_cab/home%20pages/chats_screen.dart';
import 'package:fish_cab/home%20pages/home_page.dart';
import 'package:fish_cab/home%20pages/notifications_screen.dart';
import 'package:fish_cab/home%20pages/search_screen.dart';
import 'package:fish_cab/seller_pages/seller_fish_options_screen.dart';
import 'package:fish_cab/seller_pages/seller_home_screen.dart';
import 'package:fish_cab/seller_pages/seller_schedule_screen.dart';
import 'package:fish_cab/seller_pages/seller_search_singleton.dart';
import 'package:fish_cab/seller_side/seller_fish_options_page.dart';
import 'package:fish_cab/seller_side/seller_home_page.dart';
import 'package:fish_cab/seller_side/seller_schedule_page.dart';
import 'package:fish_cab/seller_side/seller_singleton.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/auth', // Set the initial route
        routes: {
          '/auth': (context) => const AuthPage(),
          '/home': (context) => HomePage(),
          '/search': (context) => SearchScreen(),
          '/chats': (context) => ChatsScreen(),
          '/notifications': (context) => NotificationsScreen(),
          '/seller_home_view': (context) => SellerHomeScreen(
                userId: SellerSeacrhSingleton.instance.userId,
              ),
          '/seller_schedule_view': (context) => SellerScheduleScreen(
                sellerId: SellerSeacrhSingleton.instance.userId,
              ),
          '/seller_fish_options_view': (context) => FishOptionsScreen(
                sellerId: SellerSeacrhSingleton.instance.userId,
              ),
          '/seller_home': (context) => SellerHomePage(),
          '/seller_schedule': (context) => SellerSchedulePage(
                sellerId: SellerSingleton.instance.userId,
              ),
          '/seller_fish_options': (context) => FishOptionsPage(),
//'/schedule_update': (context) => ScheduleUpdatePage(),
        });
  }
}
