import 'package:client/screen/ProfileScreen.dart';
import 'package:client/screen/admin/AdminDashboardScreen.dart';
import 'package:client/screen/admin/AdminCategoryScreen.dart';
import 'package:client/screen/admin/AdminNotificationScreen.dart';
import 'package:client/screen/admin/AdminProductsScreen.dart';
import 'package:client/screen/admin/AdminUsersScreen.dart';
import 'package:client/screen/admin/admin_bottom_nav.dart';
import 'package:flutter/material.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int currentIndex = 0;

  final List<Widget> pages = const [
    AdminDashboardScreen(),
    AdminProductScreen(),
    AdminCategoryScreen(),
    AdminNotificationScreen(),
    ProfileScreen(),
  ];

  final List<String> titles = const [
    'Dashboard',
    'Products',
    'Categories',
    'Users',
    'Profile'
  ];

  void changeTab(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(titles[currentIndex]),
          centerTitle: true,
        ),

        body: IndexedStack(
          index: currentIndex,
          children: pages,
        ),

        bottomNavigationBar: AdminBottomNav(
          currentIndex: currentIndex,
          onTap: changeTab,
        ),
      ),
    );
  }
}