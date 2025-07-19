import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/transaction.dart';

class SecureApiManager {
  // static const String _baseUrl = 'https://api.tradapp.com'; // Replace with your API
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  
  // Demo data for development
  static const String _demoAddress = '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6';
  static const double _demoBalance = 2.4567;
  
  static List<Transaction> get _demoTransactions => [
    Transaction(
      id: '1',
      hash: '0x1234567890abcdef',
      fromAddress: '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6',
      toAddress: '0x9876543210fedcba',
      amount: 0.1,
      gasPrice: 0.00000002,
      gasUsed: 21000,
      type: TransactionType.send,
      status: TransactionStatus.confirmed,
      timestamp: DateTime(2024, 7, 20, 10, 30),
      blockNumber: '12345678',
    ),
    Transaction(
      id: '2',
      hash: '0xabcdef1234567890',
      fromAddress: '0x9876543210fedcba',
      toAddress: '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6',
      amount: 0.05,
      gasPrice: 0.00000002,
      gasUsed: 21000,
      type: TransactionType.receive,
      status: TransactionStatus.confirmed,
      timestamp: DateTime(2024, 7, 19, 15, 45),
      blockNumber: '12345677',
    ),
  ];

  Future<String> getWalletAddress() async {
    try {
      // Try to get from secure storage first
      String? address = await _storage.read(key: 'wallet_address');
      
      if (address == null) {
        // For demo purposes, use demo address
        address = _demoAddress;
        await _storage.write(key: 'wallet_address', value: address);
      }
      
      return address;
    } catch (e) {
      // Fallback to demo address
      return _demoAddress;
    }
  }

  Future<double> getBalance() async {
    try {
      // final address = await getWalletAddress();
      
      // In production, make API call to get real balance
      // final response = await http.get(
      //   Uri.parse('$_baseUrl/balance/$address'),
      //   headers: await _getAuthHeaders(),
      // );
      
      // For demo purposes, return demo balance
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate API delay
      return _demoBalance;
    } catch (e) {
      throw Exception('Failed to get balance: $e');
    }
  }

  Future<List<Transaction>> getRecentTransactions() async {
    try {
      // In production, make API call to get real transactions
      // final response = await http.get(
      //   Uri.parse('$_baseUrl/transactions'),
      //   headers: await _getAuthHeaders(),
      // );
      
      // For demo purposes, return demo transactions
      await Future.delayed(const Duration(milliseconds: 300)); // Simulate API delay
      return _demoTransactions;
    } catch (e) {
      throw Exception('Failed to get transactions: $e');
    }
  }

  Future<bool> sendTransaction(String toAddress, double amount) async {
    try {
      // Validate transaction
      if (amount <= 0) {
        throw Exception('Amount must be greater than 0');
      }
      
      if (toAddress.isEmpty || !toAddress.startsWith('0x')) {
        throw Exception('Invalid recipient address');
      }
      
      // In production, make API call to send transaction
      // final response = await http.post(
      //   Uri.parse('$_baseUrl/send'),
      //   headers: await _getAuthHeaders(),
      //   body: json.encode({
      //     'toAddress': toAddress,
      //     'amount': amount,
      //   }),
      // );
      
      // For demo purposes, simulate successful transaction
      await Future.delayed(const Duration(seconds: 2)); // Simulate processing time
      
      // Simulate success (90% success rate for demo)
      return true;
    } catch (e) {
      throw Exception('Failed to send transaction: $e');
    }
  }

  // Future<Map<String, String>> _getAuthHeaders() async {
  //   final token = await _storage.read(key: 'auth_token');
  //   return {
  //     'Content-Type': 'application/json',
  //     'Authorization': 'Bearer $token',
  //   };
  // }

  Future<void> saveWalletAddress(String address) async {
    await _storage.write(key: 'wallet_address', value: address);
  }

  Future<void> saveAuthToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  Future<void> clearSecureData() async {
    await _storage.deleteAll();
  }
} 