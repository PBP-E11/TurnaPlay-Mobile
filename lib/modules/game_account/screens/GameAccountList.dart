import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/GameAccountController.dart';
import '../widgets/GameAccountTile.dart';
import '../widgets/ConfirmDeleteAccount.dart';
import 'GameAccountForm.dart';
import 'GameAccountDetail.dart';

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

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameAccountController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
        ),
        title: const Text('Game Accounts'),
        actions: [
          Consumer<GameAccountController>(
            builder: (context, controller, _) {
              if (controller.games.isEmpty) return const SizedBox();

              return DropdownButtonHideUnderline(
                child: DropdownButton<String?>(
                  value: controller.selectedGameId,
                  icon: const Icon(Icons.filter_list, color: Color(0xFF494598)),
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
        ],
      ),
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
      body: controller.loading
          ? const Center(child: CircularProgressIndicator())
          : controller.error != null
          ? Center(child: Text(controller.error!))
          : ListView.builder(
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
    );
  }
}
