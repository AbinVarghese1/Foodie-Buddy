import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:foodiebuddyapp/Screens/Components/Cart/cart.dart';
import 'package:foodiebuddyapp/Screens/Components/favouritepage.dart';
import 'package:foodiebuddyapp/Screens/Components/Scan/scanpage.dart';
import 'package:foodiebuddyapp/Screens/Home/homepage.dart';
import 'package:foodiebuddyapp/Screens/Components/Profile/profile.dart';
import 'package:page_transition/page_transition.dart';

class RootPage extends StatefulWidget {
  const RootPage({Key? key}) : super(key: key);

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int _bottomNavIndex = 0;

  // List of the pages
  List<Widget> _widgetOptions() {
    return [
      homepage(), // Ensure the homepage class name is correctly cased
      FavoritePage(), 
      CartPage(),
      ProfilePage(),
    ];
  }

  // List of the pages icons
  List<IconData> iconList = [
    Icons.home,
    Icons.favorite,
    Icons.shopping_cart,
    Icons.person,
  ];

  // List of the pages titles
  List<String> titleList = [
    'Home',
    'Favorite',
    'Cart',
    'Profile',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _bottomNavIndex,
        children: _widgetOptions(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            PageTransition(
              child: const ScanPage(),
              type: PageTransitionType.bottomToTop,
            ),
          );
        },
        child: Image.asset(
          'assets/images/code-scan-two.png',
          height: 30.0,
        ),
        backgroundColor: const Color(0xFF5c985a), // Replacing Constants.primaryColor
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
  splashColor: const Color(0xFF5C985A),  // Changed to new color
  activeColor: const Color(0xFF5C985A),  // Changed to new color
  inactiveColor: Color.fromARGB(255, 247, 247, 247).withOpacity(.5),
  icons: iconList,
  activeIndex: _bottomNavIndex,
  gapLocation: GapLocation.center,
  notchSmoothness: NotchSmoothness.softEdge,
  backgroundColor: const Color(0xFF5C985A),  // Add this line
  onTap: (index) {
    setState(() {
      _bottomNavIndex = index;
    });
  },
),
    );
  }
}
