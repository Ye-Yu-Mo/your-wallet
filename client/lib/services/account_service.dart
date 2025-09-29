import '../models/account.dart';
import 'api_service.dart';

class AccountService {
  final ApiService _apiService;

  AccountService(this._apiService);

  Future<Account> createAccount(CreateAccountRequest request, int userId) async {
    final requestData = request.toJson();
    requestData['user_id'] = userId;
    // Backend expects decimal as string
    final bal = requestData['balance'];
    if (bal is num) {
      requestData['balance'] = bal.toString();
    }
    final response = await _apiService.post('/api/accounts', data: requestData);
    return Account.fromJson(response.data);
  }

  Future<List<Account>> getAccounts(int userId) async {
    final response = await _apiService.get('/api/accounts?user_id=$userId');
    return (response.data as List).map((json) => Account.fromJson(json)).toList();
  }

  Future<Account> getAccount(int id) async {
    final response = await _apiService.get('/api/accounts/$id');
    return Account.fromJson(response.data);
  }

  Future<Account> updateAccount(int id, UpdateAccountRequest request) async {
    final data = request.toJson();
    final bal = data['balance'];
    if (bal is num) {
      data['balance'] = bal.toString();
    }
    final response = await _apiService.patch('/api/accounts/$id', data: data);
    return Account.fromJson(response.data);
  }

  Future<void> deleteAccount(int id) async {
    await _apiService.delete('/api/accounts/$id');
  }
}
