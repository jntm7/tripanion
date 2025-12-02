import 'package:flutter/material.dart';

class FlightsScreen extends StatelessWidget {
  const FlightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flights'),
      ),
      body: const Center(
        child: Text('Flights Screen'),
      ),
    );
  }
}
