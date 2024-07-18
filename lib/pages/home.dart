import 'package:Teriya/components/adaptive_bottom_nav.dart';
import 'package:Teriya/services/auth_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AdaptiveBottomNavBar(items: [
      AdaptiveBottomNavItem(
        icon: Icons.home,
        label: "Home",
        page: const Center(
          child: Text("Home page"),
        ),
      ),
      AdaptiveBottomNavItem(
        icon: CupertinoIcons.book,
        label: "Courses",
        page: const Center(
          child: Text("Courses page"),
        ),
      ),
      AdaptiveBottomNavItem(
        icon: Symbols.neurology,
        label: "Talk with Ally",
        page: const Center(
          child: Text("Ally page"),
        ),
      ),
      AdaptiveBottomNavItem(
        icon: Icons.person,
        label: "Profile",
        page: const Center(
          child: Text("Profile page"),
        ),
      ),
    ]);
    // return CupertinoTabScaffold(
    //   tabBar: CupertinoTabBar(
    //     height: 70,
    //     items: const <BottomNavigationBarItem>[
    //       BottomNavigationBarItem(
    //         icon: Icon(CupertinoIcons.home),
    //         label: 'Home',
    //       ),
    //       BottomNavigationBarItem(
    //         icon: Icon(CupertinoIcons.book),
    //         label: 'Courses',
    //       ),
    //       BottomNavigationBarItem(
    //         icon: Icon(Symbols.neurology, size: 35),
    //         label: 'Ally',
    //       ),
    //       BottomNavigationBarItem(
    //         icon: Icon(CupertinoIcons.person_alt_circle_fill),
    //         label: 'Profile',
    //       ),
    //     ],
    //   ),
    //   tabBuilder: (BuildContext context, int index) {
    //     return CupertinoTabView(
    //       builder: (BuildContext context) {
    //         return Center(
    //           child: Text('Content of tab $index'),
    //         );
    //       },
    //     );
    //   },
    // );

    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(CupertinoIcons.book),
            label: 'Courses',
          ),
          NavigationDestination(
            icon: Icon(Symbols.neurology, size: 32),
            label: 'Ally',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      body: <Widget>[
        /// Home page
        const Card(
          shadowColor: Colors.transparent,
          margin: const EdgeInsets.all(8.0),
          child: SizedBox.expand(
            child: Center(
              child: Text(
                'Home page',
              ),
            ),
          ),
        ),
        const Card(
          shadowColor: Colors.transparent,
          margin: const EdgeInsets.all(8.0),
          child: SizedBox.expand(
            child: Center(
              child: Text(
                'Courses page',
              ),
            ),
          ),
        ),
        const Card(
          shadowColor: Colors.transparent,
          child: Center(
            child: Text(
              'Ally page',
            ),
          ),
        ),
        const Card(
          shadowColor: Colors.transparent,
          margin: const EdgeInsets.all(8.0),
          child: SizedBox.expand(
            child: Center(
              child: Text(
                'Profile Page',
              ),
            ),
          ),
        ),
      ][currentPageIndex],
    );
  }
}
