import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:turnaplay_mobile/providers/user_provider.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final bool showAddButton = userProvider.isOrganizerOrAdmin;

    // Map external index (0=Home, 1=Add, 2=Profile) to internal index
    int internalIndex = currentIndex;
    if (!showAddButton) {
      if (currentIndex == 2) {
        internalIndex = 1;
      } else if (currentIndex == 1) {
         // Should not happen if logic is correct, but fallback to home
        internalIndex = 0;
      }
    }

    return BottomNavigationBar(
      currentIndex: internalIndex,
      onTap: (index) {
        if (!showAddButton) {
          // Map internal index back to external
          if (index == 0) {
            onTap(0);
          } else if (index == 1) {
            onTap(2); // Profile
          }
        } else {
          onTap(index);
        }
      },
      selectedItemColor: const Color(0xFF494598), // primaryColor
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        if (showAddButton)
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(12), // Adjust padding for circle size
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF494598), // primaryColor
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
            label: '', // No label for the middle button
          ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}