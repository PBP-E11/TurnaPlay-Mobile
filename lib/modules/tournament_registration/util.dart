import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:turnaplay_mobile/settings.dart';

Future<Map?> sendPost(CookieRequest request, String path, Map payload) async {
  try {
    final responseBody = await request.post('$HOST/$path', jsonEncode(payload));

    if (responseBody['success'] == true) {
      return responseBody['data'];
    } else {
      final errorCode = responseBody['error_code'];
      final errorMessage = responseBody['error_message'];
      debugPrint('Error code $errorCode with message: $errorMessage');
    }
  } catch (e) {
    debugPrint('Something went wrong: $e');
  }

  return null;
}

bool isAuthenticated(BuildContext context) =>
    context.read<CookieRequest>().loggedIn;
