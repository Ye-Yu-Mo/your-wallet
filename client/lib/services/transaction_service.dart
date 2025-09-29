import '../models/transaction.dart';
import 'api_service.dart';

class TransactionService {
  final ApiService _apiService;

  TransactionService(this._apiService);

  Future<Transaction> createTransaction(CreateTransactionRequest request) async {
    final response = await _apiService.post('/api/transactions', data: request.toJson());
    return Transaction.fromJson(response.data);
  }

  Future<List<Transaction>> getTransactions() async {
    final response = await _apiService.get('/api/transactions');
    return (response.data as List).map((json) => Transaction.fromJson(json)).toList();
  }

  Future<Transaction> getTransaction(int id) async {
    final response = await _apiService.get('/api/transactions/$id');
    return Transaction.fromJson(response.data);
  }

  Future<Transaction> updateTransaction(int id, UpdateTransactionRequest request) async {
    final response = await _apiService.patch('/api/transactions/$id', data: request.toJson());
    return Transaction.fromJson(response.data);
  }

  Future<void> deleteTransaction(int id) async {
    await _apiService.delete('/api/transactions/$id');
  }
}