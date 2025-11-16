import 'dart:convert';

import 'package:brewery/models/response_model.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class BreweryApiService {
  static const String _host = 'api.openbrewerydb.org';
  static const String _basePath = '/v1/breweries';

  Future<List<Brewery>> listBreweries({
    int page = 1,
    int perPage = 50,
    String? byCity,
    String? byState,
    String? byType,
    String? byName,
    String? sort,
    LatLng? byDist,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
    };

    if (byCity != null && byCity.isNotEmpty) params['by_city'] = byCity.replaceAll(' ', '_');
    if (byState != null && byState.isNotEmpty) params['by_state'] = byState.replaceAll(' ', '_');
    if (byType != null && byType.isNotEmpty) params['by_type'] = byType;
    if (byName != null && byName.isNotEmpty) params['by_name'] = byName;
    if (sort != null && sort.isNotEmpty) params['sort'] = sort;
    if (byDist != null) params['by_dist'] = '${byDist.latitude},${byDist.longitude}';

    final uri = Uri.https(_host, _basePath, params);
    final res = await http.get(uri);

    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body) as List<dynamic>;
      return data.map((e) => Brewery.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('API listBreweries failed: ${res.statusCode}');
    }
  }

  Future<List<Brewery>> searchBreweries(String query, {int page = 1, int perPage = 50}) async {
    final params = <String, String>{
      'query': query,
      'page': page.toString(),
      'per_page': perPage.toString(),
    };

    final uri = Uri.https(_host, '$_basePath/search', params);
    final res = await http.get(uri);

    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body) as List<dynamic>;
      return data.map((e) => Brewery.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('API searchBreweries failed: ${res.statusCode}');
    }
  }

  Future<Brewery> fetchBreweryById(String id) async {
    final uri = Uri.https(_host, '$_basePath/$id');
    final res = await http.get(uri);

    if (res.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(res.body) as Map<String, dynamic>;
      return Brewery.fromJson(data);
    } else {
      throw Exception('API fetchBreweryById failed: ${res.statusCode}');
    }
  }
}
