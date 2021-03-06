import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:konsrr/src/app/screens/my_ticket_screen.dart';
import 'package:konsrr/src/app/screens/my_wishlist_screen.dart';
import 'package:konsrr/src/home/screens/home_screen.dart';
import 'package:konsrr/src/app/screens/settings_screen.dart';

import '../app_icons.dart';

class NavigationItem {
  final Widget screen;
  final BottomNavigationBarItem bottomNavigationBarItem;
  final bool featureFlag;

  NavigationItem({
    @required this.screen,
    @required this.bottomNavigationBarItem,
    this.featureFlag = true,
  });

  factory NavigationItem.home() => NavigationItem(
    screen: HomeScreen(),
    bottomNavigationBarItem: BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'Home',
    ),
  );

  factory NavigationItem.myTicket() => NavigationItem(
    screen: MyTicketScreen(),
    bottomNavigationBarItem: BottomNavigationBarItem(
      icon: Icon(AppIcons.ticket),
      label: 'My Ticket',
    ),
  );

  factory NavigationItem.wishlist() => NavigationItem(
    screen: MyWishlistScreen(),
    bottomNavigationBarItem: BottomNavigationBarItem(
      icon: Icon(AppIcons.heart),
      label: 'Wishlist',
    ),
  );

  factory NavigationItem.settings() => NavigationItem(
    screen: SettingsScreen(),
    bottomNavigationBarItem: BottomNavigationBarItem(
      icon: Icon(Icons.settings),
      label: 'Settings'
    )
  );
}

List<NavigationItem> get navigationItems {
  return [
    NavigationItem.home(),
    NavigationItem.wishlist(),
    NavigationItem.myTicket(),
    NavigationItem.settings(),
  ];
}