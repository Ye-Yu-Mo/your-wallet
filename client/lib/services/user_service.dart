import '../models/user.dart';
import 'api_service.dart';

class UserService {
  final ApiService _apiService;

  UserService(this._apiService);

  Future<User> createUser(CreateUserRequest request) async {
    final response = await _apiService.post('/api/users', data: request.toJson());
    return User.fromJson(response.data);
  }

  Future<User> getUser(int id) async {
    final response = await _apiService.get('/api/users/$id');
    return User.fromJson(response.data);
  }

  Future<User> updateUser(int id, UpdateUserRequest request) async {
    final response = await _apiService.patch('/api/users/$id', data: request.toJson());
    return User.fromJson(response.data);
  }

  Future<void> deleteUser(int id) async {
    await _apiService.delete('/api/users/$id');
  }
}