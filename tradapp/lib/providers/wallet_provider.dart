import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/wallet_state.dart';
import '../models/transaction.dart';
import '../services/secure_api_manager.dart';

final walletProvider = StateNotifierProvider<WalletNotifier, WalletState>((ref) {
  return WalletNotifier();
});

class WalletNotifier extends StateNotifier<WalletState> {
  WalletNotifier() : super(WalletState.initial());

  final SecureApiManager _apiManager = SecureApiManager();

  Future<void> initializeWallet() async {
    state = state.copyWith(isLoading: true);
    
    try {
      // Load wallet from secure storage
      final address = await _apiManager.getWalletAddress();
      final balance = await _apiManager.getBalance();
      final transactions = await _apiManager.getRecentTransactions();
      
      state = state.copyWith(
        address: address,
        balance: balance,
        recentTransactions: transactions,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> refreshBalance() async {
    try {
      final balance = await _apiManager.getBalance();
      state = state.copyWith(balance: balance);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> loadTransactions() async {
    state = state.copyWith(isLoadingTransactions: true);
    
    try {
      final transactions = await _apiManager.getRecentTransactions();
      state = state.copyWith(
        recentTransactions: transactions,
        isLoadingTransactions: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoadingTransactions: false,
      );
    }
  }

  Future<bool> sendTransaction(String toAddress, double amount) async {
    try {
      final success = await _apiManager.sendTransaction(toAddress, amount);
      if (success) {
        await refreshBalance();
        await loadTransactions();
      }
      return success;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
} 