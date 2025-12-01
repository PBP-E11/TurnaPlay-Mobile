import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:turnaplay_mobile/login.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final Color primaryColor = const Color(0xFF494598);

    return Scaffold(
      backgroundColor: Colors.white,
      // We can remove the AppBar or keep a transparent one if we want a back button.
      // Given the design has a "Login" link at the bottom, and this is a full screen design,
      // standard AppBar might look out of place.
      // However, user experience usually demands a back button.
      // Let's overlay a back button on top of the wave.
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Top Wavy Header with Back Button
            Stack(
              children: [
                ClipPath(
                  clipper: HeaderWaveClipper(),
                  child: Container(
                    height: 240,
                    decoration: BoxDecoration(color: primaryColor),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.asset(
                            'static/authImages/valorant-character.png',
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                          ),
                        ),
                        // Vignette overlay to make character pop
                        Container(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              center: const Alignment(0.0, -0.3),
                              radius: 1.0,
                              colors: [
                                Colors.transparent,
                                Colors.black.withAlpha(220), // Darker edges
                              ],
                              stops: const [0.2, 1.0],
                            ),
                          ),
                        ),
                        // Bottom blending
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                primaryColor.withAlpha(153),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 16,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),

            // 2. Form Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const SizedBox(height: 20.0),
                  // Title and Subtitle
                  Text(
                    "Register",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[800],
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    "Create your new account",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 30.0),

                  // Username Field
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      labelStyle: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                      prefixIcon: Icon(
                        Icons.person_outline,
                        color: primaryColor,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: primaryColor),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16.0,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your username';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20.0),

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: primaryColor,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: primaryColor),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16.0,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20.0),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                      prefixIcon: Icon(Icons.lock_outline, color: primaryColor),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: primaryColor),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16.0,
                      ),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20.0),

                  // Confirm Password Field
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      labelStyle: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                      prefixIcon: Icon(Icons.lock_outline, color: primaryColor),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: primaryColor),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16.0,
                      ),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 40.0),

                  // Register Button
                  ElevatedButton(
                    onPressed: () async {
                      String username = _usernameController.text;
                      String email = _emailController.text;
                      String password1 = _passwordController.text;
                      String password2 = _confirmPasswordController.text;

                      final response = await request.postJson(
                        "http://localhost:8000/api/accounts/register/",
                        jsonEncode({
                          "username": username,
                          "email": email,
                          "password1": password1,
                          "password2": password2,
                        }),
                      );
                      if (context.mounted) {
                        if (response['status'] == 'success') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Successfully registered!'),
                            ),
                          );
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                response['message'] ?? 'Failed to register!',
                              ),
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    child: const Text(
                      'REGISTER',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40.0),

                  // Login Link
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(
                          context,
                        ); // Pop to go back to Login if it was pushed
                      },
                      child: Text.rich(
                        TextSpan(
                          text: "Already have an account? ",
                          style: TextStyle(color: Colors.grey[600]),
                          children: [
                            TextSpan(
                              text: 'Login',
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Duplicating the clipper for self-containment in this file as requested
// to avoid external dependencies if Login isn't exported or if we want this to be standalone.
class HeaderWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    // Start at top-left
    path.lineTo(0, size.height * 0.75);

    var controlPoint = Offset(
      size.width * 0.5,
      size.height,
    ); // Bottom center pull
    var endPoint = Offset(size.width, size.height * 0.75);

    path.quadraticBezierTo(
      controlPoint.dx,
      controlPoint.dy,
      endPoint.dx,
      endPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
