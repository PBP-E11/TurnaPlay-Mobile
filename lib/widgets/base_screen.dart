import 'package:flutter/material.dart';
import 'package:turnaplay_mobile/widgets/footer.dart';
import 'package:turnaplay_mobile/widgets/navbar.dart';

class BaseScreen extends StatefulWidget {
  final Widget body;
  final int initialIndex;
  final Function(int) onTap;
  final Widget? floatingActionButton;

  const BaseScreen({
    super.key,
    required this.body,
    this.initialIndex = 0,
    required this.onTap,
    this.floatingActionButton,
  });

  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _handleTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    widget.onTap(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: const Navbar(),
      body: widget.body,
      floatingActionButton: widget.floatingActionButton,
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _handleTap,
      ),
    );
  }
}
