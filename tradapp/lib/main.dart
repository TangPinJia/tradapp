import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/wallet_screen.dart';

void main() {
  runApp(const ProviderScope(child: TradApp()));
}

class TradApp extends StatelessWidget {
  const TradApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TradApp Wallet',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      home: const WalletScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
