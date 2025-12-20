import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/GameAccountController.dart';
import '../models/GameAccountAPI.dart';
import '../screens/GameAccountList.dart';
import '../screens/GameAccountForm.dart';
import '../screens/GameAccountDetail.dart';
import '../models/GameAccountEntry.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class GameAccountFeature extends StatelessWidget {
  const GameAccountFeature({super.key});

  @override
  Widget build(BuildContext context) {
    final request = context.read<CookieRequest>();
    return ChangeNotifierProvider(
      create: (_) => GameAccountController(GameAccountApi(request)),
      child: Navigator(
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/add':
              return MaterialPageRoute(builder: (_) => GameAccountFormScreen());
            case '/detail':
              final account = settings.arguments as GameAccountEntry;
              return MaterialPageRoute(
                builder: (_) => GameAccountDetailScreen(account),
              );
            default:
              return MaterialPageRoute(builder: (_) => GameAccountListScreen());
          }
        },
      ),
    );
  }
}
