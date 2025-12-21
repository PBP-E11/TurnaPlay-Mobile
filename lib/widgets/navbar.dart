import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:turnaplay_mobile/modules/tournaments/screens/tournament_search.dart';
import 'package:turnaplay_mobile/providers/user_provider.dart';
import 'package:turnaplay_mobile/settings.dart';

class Navbar extends StatelessWidget implements PreferredSizeWidget {
  const Navbar({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return AppBar(
      backgroundColor: const Color(0xFFF5F5F5),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.search, color: Colors.black, size: 28),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TournamentSearchScreen(),
            ),
          );
        },
      ),
      title: const Text(
        'TurnaPlay',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
      centerTitle: true,
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(
            Icons.account_circle_outlined,
            color: Colors.black,
            size: 28,
          ),
          onSelected: (value) async {
            if (value == 'profile') {
              // Check if we are already on the profile page to avoid stacking
              if (ModalRoute.of(context)?.settings.name != '/profile') {
                Navigator.pushNamed(context, '/profile');
              }
            } else if (value == 'dashboard') {
              // Navigate to Admin Dashboard
              Navigator.pushNamed(context, '/dashboard-users');
            } else if (value == 'logout') {
              final request = context.read<CookieRequest>();
              final response = await request.logout(
                "$HOST/api/accounts/logout/",
              );
              String message = response["message"];

              // Clear local user state
              if (context.mounted) {
                await Provider.of<UserProvider>(
                  context,
                  listen: false,
                ).logout();
              }

              if (context.mounted) {
                if (response['status']) {
                  String uname = response["username"];
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("$message Goodbye, $uname.")),
                  );
                  Navigator.pushReplacementNamed(context, "/login");
                } else {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(message)));
                }
              }
            }
          },
          itemBuilder: (BuildContext context) {
            return [
              const PopupMenuItem<String>(
                value: 'profile',
                child: Text('My Profile'),
              ),
              if (userProvider.isAdmin)
                const PopupMenuItem<String>(
                  value: 'dashboard',
                  child: Text('Dashboard'),
                ),
              PopupMenuItem<String>(
                value: 'logout',
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ];
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
