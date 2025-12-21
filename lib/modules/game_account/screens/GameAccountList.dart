import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:turnaplay_mobile/widgets/base_screen.dart';
import 'package:turnaplay_mobile/modules/tournaments/screens/creationForm.dart';
import '../models/GameAccountController.dart';
import '../widgets/GameAccountTile.dart';
import '../widgets/ConfirmDeleteAccount.dart';

class GameAccountListScreen extends StatefulWidget {
  @override
  State<GameAccountListScreen> createState() => _GameAccountListScreenState();
}

class _GameAccountListScreenState extends State<GameAccountListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<GameAccountController>().loadAccounts();
    });
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.of(context, rootNavigator: true).pushReplacementNamed('/home');
    } else if (index == 1) {
      Navigator.of(
        context,
        rootNavigator: true,
      ).push(MaterialPageRoute(builder: (context) => const TournamentForm()));
    } else if (index == 2) {
      Navigator.of(
        context,
        rootNavigator: true,
      ).pushReplacementNamed('/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameAccountController>();

    return BaseScreen(
      initialIndex: 2,
      onTap: _onItemTapped,
      floatingActionButton: Builder(
        builder: (innerContext) {
          return FloatingActionButton(
            backgroundColor: const Color(0xFF494598),
            child: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed('/add');
            },
          );
        },
      ),
      body: Column(
        children: [
          // Custom Header
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true).pop();
                        },
                      ),
                    ),

                    const SizedBox(width: 8),
                    const Text(
                      'Game Accounts',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 56.0),
                    child: Consumer<GameAccountController>(
                      builder: (context, controller, _) {
                        if (controller.games.isEmpty) return const SizedBox();

                        return DropdownButtonHideUnderline(
                          child: DropdownButton<String?>(
                            value: controller.selectedGameId,
                            icon: const Icon(
                              Icons.filter_list,
                              color: Color(0xFF494598),
                            ),
                            onChanged: (value) {
                              controller.setGameFilter(value);
                            },
                            items: [
                              const DropdownMenuItem<String?>(
                                value: null,
                                child: Text('All games'),
                              ),
                              ...controller.games.map(
                                (game) => DropdownMenuItem<String?>(
                                  value: game.id,
                                  child: Text(game.name),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: controller.loading
                ? const Center(child: CircularProgressIndicator())
                : controller.error != null
                ? Center(child: Text(controller.error!))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: controller.accounts.length,
                    itemBuilder: (context, index) {
                      final account = controller.accounts[index];
                      return GameAccountTile(
                        account: account,
                        onTap: () {
                          Navigator.of(
                            context,
                          ).pushNamed('/detail', arguments: account);
                        },
                        onDelete: () async {
                          final confirm = await showConfirmDelete(context);
                          if (confirm == true) {
                            controller.deleteAccount(account.id);
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
