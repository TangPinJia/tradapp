class TransactionValidator {
  static bool isValidAddress(String address) {
    // Basic Ethereum address validation
    if (address.isEmpty) return false;
    
    // Check if it starts with 0x
    if (!address.startsWith('0x')) return false;
    
    // Check if it's exactly 42 characters (0x + 40 hex characters)
    if (address.length != 42) return false;
    
    // Check if all characters after 0x are valid hex
    final hexPart = address.substring(2);
    final hexRegex = RegExp(r'^[0-9a-fA-F]+$');
    if (!hexRegex.hasMatch(hexPart)) return false;
    
    return true;
  }

  static bool isValidAmount(String amount) {
    if (amount.isEmpty) return false;
    
    final double? parsedAmount = double.tryParse(amount);
    if (parsedAmount == null) return false;
    
    if (parsedAmount <= 0) return false;
    
    return true;
  }

  static bool hasSufficientBalance(double balance, double amount, double gasFee) {
    return balance >= (amount + gasFee);
  }

  static String? validateTransaction({
    required String toAddress,
    required double amount,
    required double balance,
    double gasFee = 0.001, // Default gas fee in ETH
  }) {
    if (!isValidAddress(toAddress)) {
      return 'Invalid recipient address';
    }
    
    if (amount <= 0) {
      return 'Amount must be greater than 0';
    }
    
    if (!hasSufficientBalance(balance, amount, gasFee)) {
      return 'Insufficient balance for transaction and gas fees';
    }
    
    return null; // No error
  }

  static double estimateGasFee({
    double gasPrice = 20, // Gwei
    int gasLimit = 21000, // Standard ETH transfer
  }) {
    // Convert Gwei to ETH
    const double gweiToEth = 0.000000001;
    return gasPrice * gasLimit * gweiToEth;
  }
} 