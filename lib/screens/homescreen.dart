import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skill_swap/controllers/user_controller.dart';
import 'package:skill_swap/provider/search_provider.dart';
import 'package:skill_swap/screens/navbar/chat.dart';
import 'package:skill_swap/screens/navbar/community.dart';
import 'package:skill_swap/screens/navbar/home.dart';
import 'package:skill_swap/screens/navbar/profile.dart';
import 'package:skill_swap/screens/navbar/search.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  int _selectedIndex = 0;
  PageController pageController = PageController();
  bool allowPage = true;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getUser();
  }

  void getUser() async {
    await UserController.init();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> changeIndex(int index, bool fromBottomNavBar) async {
    if (!allowPage) {
      return;
    }
    if (fromBottomNavBar) {
      allowPage = false;
    }
    setState(() {
      _selectedIndex = index;
    });
    if (fromBottomNavBar) {
      await pageController.animateToPage(
        _selectedIndex,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeIn,
      );
    }
    allowPage = true;
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Scaffold(body: Center(child: CircularProgressIndicator()))
        : Scaffold(
          body: ChangeNotifierProvider(
            create: (context) => SearchProvider(),
            lazy: false,
            builder:
                (context, child) => SafeArea(
                  child: PageView(
                    controller: pageController,
                    onPageChanged: (value) {
                      changeIndex(value, false);
                    },
                    padEnds: false,
                    children: [
                      Home(),
                      Search(),
                      Community(),
                      Chat(),
                      Profile(user: UserController.user),
                    ],
                  ),
                ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            unselectedItemColor: Colors.white54,
            selectedItemColor: Colors.white,
            onTap: (value) async {
              await changeIndex(value, true);
            },
            currentIndex: _selectedIndex,
            items: [
              BottomNavigationBarItem(
                backgroundColor: Color.fromRGBO(58, 58, 58, 1),
                icon: Icon(Icons.home_outlined),
                label: "Home",
              ),
              BottomNavigationBarItem(
                backgroundColor: Color.fromRGBO(58, 58, 58, 1),
                icon: Icon(Icons.search),
                label: "Search",
              ),
              BottomNavigationBarItem(
                backgroundColor: Color.fromRGBO(58, 58, 58, 1),
                icon: Icon(Icons.groups_3_outlined),
                label: "Community",
              ),
              BottomNavigationBarItem(
                backgroundColor: Color.fromRGBO(58, 58, 58, 1),
                icon: Icon(Icons.chat_outlined),
                label: "Chat",
              ),
              BottomNavigationBarItem(
                backgroundColor: Color.fromRGBO(58, 58, 58, 1),
                icon: Icon(Icons.person_outline),
                label: "Profile",
              ),
            ],
          ),
        );
  }
}
