import 'package:client/screen/CartScreen.dart';
import 'package:client/screen/CategoryScreen.dart';
import 'package:client/screen/LoginScreen.dart';
import 'package:client/screen/ProfileScreen.dart';
import 'package:client/screen/WishlistScreen.dart';
import 'package:client/screen/home_screen.dart';
import 'package:client/screen/product_screen.dart';
import 'package:client/services/api_service.dart';
import 'package:client/widgets/bottom_nav.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  final List<int> navigationHistory = [0];

  final List<Widget> pages = const [
    HomeScreen(),
    CategoryScreen(),
    Wishlistscreen(),
    ProductScreen(),
    ProfileScreen(),
  ];

  final List<String> titles = const [
    'Home',
    'Categories',
    'Wishlist',
    'Products',
    'Profile',
  ];

  Future<void> changeTab(int index) async {
    if (index == currentIndex) return;

    // Profile par click
    if (index == 4) {
      try {
        await ApiService.getMe();

        // Logged in hai
        if (!mounted) return;

        setState(() {
          currentIndex = index;
          navigationHistory.remove(index);
          navigationHistory.add(index);
        });
      } catch (e) {
        // Login nahi hai
        if (!mounted) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginScreen(),
          ),
        );
      }

      return;
    }

    // Baaki tabs
    setState(() {
      currentIndex = index;
      navigationHistory.remove(index);
      navigationHistory.add(index);
    });
  }

  void handleBack() {
    if (navigationHistory.length > 1) {
      setState(() {
        navigationHistory.removeLast();
        currentIndex = navigationHistory.last;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        handleBack();
      },
      child: Scaffold(
        appBar: AppBar(
          leadingWidth: 100,
          leading: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Transform.scale(
              scale: 1.5,
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          title: Text(titles[currentIndex]),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.search),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: CircleAvatar(
                backgroundColor: Color(0xFF9F5965),
                child: Icon(
                  Icons.person_outline,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        body: IndexedStack(
          index: currentIndex,
          children: pages,
        ),
        bottomNavigationBar: BottomNav(
          currentIndex: currentIndex,
          onTap: changeTab,
        ),
      ),
    );
  }
}