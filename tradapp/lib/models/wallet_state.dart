import 'transaction.dart';

class WalletState {
  final String address;
  final double balance;
  final List<Transaction> recentTransactions;
  final bool isLoading;
  final bool isLoadingTransactions;
  final String? error;

  const WalletState({
    required this.address,
    required this.balance,
    required this.recentTransactions,
    required this.isLoading,
    required this.isLoadingTransactions,
    this.error,
  });

  factory WalletState.initial() {
    return const WalletState(
      address: '',
      balance: 0.0,
      recentTransactions: [],
      isLoading: false,
      isLoadingTransactions: false,
    );
  }

  WalletState copyWith({
    String? address,
    double? balance,
    List<Transaction>? recentTransactions,
    bool? isLoading,
    bool? isLoadingTransactions,
    String? error,
  }) {
    return WalletState(
      address: address ?? this.address,
      balance: balance ?? this.balance,
      recentTransactions: recentTransactions ?? this.recentTransactions,
      isLoading: isLoading ?? this.isLoading,
      isLoadingTransactions: isLoadingTransactions ?? this.isLoadingTransactions,
      error: error ?? this.error,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WalletState &&
        other.address == address &&
        other.balance == balance &&
        other.recentTransactions == recentTransactions &&
        other.isLoading == isLoading &&
        other.isLoadingTransactions == isLoadingTransactions &&
        other.error == error;
  }

  @override
  int get hashCode {
    return address.hashCode ^
        balance.hashCode ^
        recentTransactions.hashCode ^
        isLoading.hashCode ^
        isLoadingTransactions.hashCode ^
        error.hashCode;
  }
} 