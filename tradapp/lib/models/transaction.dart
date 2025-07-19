enum TransactionType { send, receive, swap }

enum TransactionStatus { pending, confirmed, failed }

class Transaction {
  final String id;
  final String hash;
  final String fromAddress;
  final String toAddress;
  final double amount;
  final double gasPrice;
  final double gasUsed;
  final TransactionType type;
  final TransactionStatus status;
  final DateTime timestamp;
  final String? blockNumber;

  const Transaction({
    required this.id,
    required this.hash,
    required this.fromAddress,
    required this.toAddress,
    required this.amount,
    required this.gasPrice,
    required this.gasUsed,
    required this.type,
    required this.status,
    required this.timestamp,
    this.blockNumber,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      hash: json['hash'] as String,
      fromAddress: json['fromAddress'] as String,
      toAddress: json['toAddress'] as String,
      amount: (json['amount'] as num).toDouble(),
      gasPrice: (json['gasPrice'] as num).toDouble(),
      gasUsed: (json['gasUsed'] as num).toDouble(),
      type: TransactionType.values.firstWhere(
        (e) => e.toString() == 'TransactionType.${json['type']}',
      ),
      status: TransactionStatus.values.firstWhere(
        (e) => e.toString() == 'TransactionStatus.${json['status']}',
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      blockNumber: json['blockNumber'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hash': hash,
      'fromAddress': fromAddress,
      'toAddress': toAddress,
      'amount': amount,
      'gasPrice': gasPrice,
      'gasUsed': gasUsed,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
      'blockNumber': blockNumber,
    };
  }

  double get totalCost => amount + (gasPrice * gasUsed);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Transaction &&
        other.id == id &&
        other.hash == hash &&
        other.fromAddress == fromAddress &&
        other.toAddress == toAddress &&
        other.amount == amount &&
        other.gasPrice == gasPrice &&
        other.gasUsed == gasUsed &&
        other.type == type &&
        other.status == status &&
        other.timestamp == timestamp &&
        other.blockNumber == blockNumber;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        hash.hashCode ^
        fromAddress.hashCode ^
        toAddress.hashCode ^
        amount.hashCode ^
        gasPrice.hashCode ^
        gasUsed.hashCode ^
        type.hashCode ^
        status.hashCode ^
        timestamp.hashCode ^
        blockNumber.hashCode;
  }
} 