import 'package:fish_cab/api/firebase_api.dart';
import 'package:fish_cab/auth%20pages/auth_page.dart';
import 'package:fish_cab/home%20pages/chat_screen.dart';
import 'package:fish_cab/home%20pages/home_page.dart';
import 'package:fish_cab/home%20pages/map_ongoing.dart';
import 'package:fish_cab/home%20pages/map_page.dart';
import 'package:fish_cab/home%20pages/notifications_screen.dart';
import 'package:fish_cab/home%20pages/order_screen.dart';
import 'package:fish_cab/home%20pages/search_screen.dart';
import 'package:fish_cab/review-rating%20pages/make_review_screen.dart';
import 'package:fish_cab/seller_pages/seller_fish_options_screen.dart';
import 'package:fish_cab/seller_pages/seller_home_screen.dart';
import 'package:fish_cab/seller_pages/seller_schedule_screen.dart';
import 'package:fish_cab/seller_pages/seller_search_singleton.dart';
import 'package:fish_cab/seller_side/seller_add_demand_option.dart';
import 'package:fish_cab/seller_side/seller_add_fish_option.dart';
import 'package:fish_cab/seller_side/seller_chats_screen.dart';
import 'package:fish_cab/seller_side/seller_demand_page.dart';
import 'package:fish_cab/seller_side/seller_fish_options_page.dart';
import 'package:fish_cab/seller_side/seller_home_page.dart';
import 'package:fish_cab/seller_side/seller_map_page.dart';
import 'package:fish_cab/seller_side/seller_order_page.dart';
import 'package:fish_cab/seller_side/seller_schedule_page.dart';
import 'package:fish_cab/seller_side/seller_set_location2.dart';
import 'package:fish_cab/seller_side/seller_set_route.dart';
import 'package:fish_cab/seller_side/seller_singleton.dart';
import 'package:fish_cab/seller_side/seller_set_location1.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

String? token;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  token = await FirebaseApi().initNotifications();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: AppBarTheme(
            iconTheme: IconThemeData(
              color: Colors.blue,
            ),
          ),
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: '/auth', // Set the initial route
        routes: {
          '/auth': (context) => AuthPage(
                token: token!,
              ),
          '/home': (context) => HomePage(),
          '/search': (context) => SearchScreen(),
          '/map': (context) => MapPage(),
          '/map_ongoing': (context) => MapOngoingPage(
                sellerId: '',
              ),
          '/chats': (context) => ChatScreen(),
          '/orders': (context) => OrdersScreen(),
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
          '/seller_fish_options': (context) => FishOptionsPage(
                sellerId: SellerSingleton.instance.userId,
              ),
          '/seller_orders': (context) => SellerOrderPage(),
          '/add_fish_option': (context) => AddFishOptionPage(
                sellerId: SellerSingleton.instance.userId,
              ),
          '/add_fish_demand_option': (context) => AddFishDemandOptionPage(
                sellerId: SellerSingleton.instance.userId,
              ),
          '/seller_schedule': (context) => SellerSchedulePage(
                sellerId: SellerSingleton.instance.userId,
              ),
          '/seller_demand': (context) => SellerDemandPage(
                sellerID: SellerSingleton.instance.userId,
              ),
          '/seller_home': (context) => SellerHomePage(),
          '/seller_chats': (context) => SellerChatsScreen(),
          '/seller_set_route': (context) => SellerSetRoute(),
          '/make_review': (context) => ReviewView(
                reviewee: "JJc2ZatwgmPLF8clNr8mkWukqVl1",
              ),
          '/seller_set_location1': (context) => SellerSetLocation1(),
          '/seller_set_location2': (context) => SellerSetLocation2(),
          '/seller_map': (context) => SellerMapPage(),
        });
  }
}
