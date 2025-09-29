import '../models/account.dart';
import 'api_service.dart';

class AccountService {
  final ApiService _apiService;

  AccountService(this._apiService);

  Future<Account> createAccount(CreateAccountRequest request) async {
    final response = await _apiService.post('/api/accounts', data: request.toJson());
    return Account.fromJson(response.data);
  }

  Future<List<Account>> getAccounts() async {
    final response = await _apiService.get('/api/accounts');
    return (response.data as List).map((json) => Account.fromJson(json)).toList();
  }

  Future<Account> getAccount(int id) async {
    final response = await _apiService.get('/api/accounts/$id');
    return Account.fromJson(response.data);
  }

  Future<Account> updateAccount(int id, UpdateAccountRequest request) async {
    final response = await _apiService.patch('/api/accounts/$id', data: request.toJson());
    return Account.fromJson(response.data);
  }

  Future<void> deleteAccount(int id) async {
    await _apiService.delete('/api/accounts/$id');
  }
}