import 'package:flutter/material.dart';
import '../widgets/animated_balloon.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          '🎈 Balloon Festival',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            shadows: [
              Shadow(
                blurRadius: 6,
                color: Colors.black45,
                offset: Offset(1, 2),
              ),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: const SizedBox.expand(
        child: MultiBalloonScene(),
      ),
    );
  }
}