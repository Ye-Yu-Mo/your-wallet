import '../models/asset.dart';
import 'api_service.dart';

class AssetService {
  final ApiService _apiService;

  AssetService(this._apiService);

  Future<Asset> createAsset(CreateAssetRequest request) async {
    final response = await _apiService.post('/api/assets', data: request.toJson());
    return Asset.fromJson(response.data);
  }

  Future<List<Asset>> getAssets() async {
    final response = await _apiService.get('/api/assets');
    return (response.data as List).map((json) => Asset.fromJson(json)).toList();
  }

  Future<Asset> getAsset(int id) async {
    final response = await _apiService.get('/api/assets/$id');
    return Asset.fromJson(response.data);
  }

  Future<Asset> updateAsset(int id, UpdateAssetRequest request) async {
    final response = await _apiService.patch('/api/assets/$id', data: request.toJson());
    return Asset.fromJson(response.data);
  }

  Future<void> deleteAsset(int id) async {
    await _apiService.delete('/api/assets/$id');
  }
}