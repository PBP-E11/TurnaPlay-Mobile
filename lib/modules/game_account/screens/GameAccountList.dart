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
      appBar: AppBar(title: const Text('Game Accounts')),
      floatingActionButton: Builder(
        builder: (innerContext) {
          return FloatingActionButton(
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
