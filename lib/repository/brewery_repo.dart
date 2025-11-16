import 'package:brewery/services/brewery_api.dart';
import 'package:hive/hive.dart';
import 'package:latlong2/latlong.dart';
import '../models/response_model.dart';

class BreweryRepository {
  final BreweryApiService api;
  final Box<Brewery> breweriesBox;
  final Box<bool> favoritesBox;

  BreweryRepository({
    required this.api,
    required this.breweriesBox,
    required this.favoritesBox,
  });

  Future<List<Brewery>> fetchAndCache({
    int page = 1,
    int perPage = 50,
    String? byCity,
    String? byState,
    String? byType,
    String? byName,
    String? sort,
    LatLng? byDist,
  }) async {
    final results = await api.listBreweries(
      page: page,
      perPage: perPage,
      byCity: byCity,
      byState: byState,
      byType: byType,
      byName: byName,
      sort: sort,
      byDist: byDist,
    );

    final Map<String, Brewery> map = {for (var b in results) b.id!: b};
    await breweriesBox.putAll(map);

    return results;
  }

  Future<List<Brewery>> searchAndCache(
    String query, {
    int page = 1,
    int perPage = 50,
  }) async {
    final results = await api.searchBreweries(
      query,
      page: page,
      perPage: perPage,
    );
    final Map<String, Brewery> map = {for (var b in results) b.id!: b};
    await breweriesBox.putAll(map);
    return results;
  }

  Future<List<Brewery>> listWithOfflineFallback({
    int page = 1,
    int perPage = 50,
    String? byCity,
    String? byState,
    String? byType,
    String? byName,
    String? sort,
    LatLng? byDist,
  }) async {
    try {
      return await fetchAndCache(
        page: page,
        perPage: perPage,
        byCity: byCity,
        byState: byState,
        byType: byType,
        byName: byName,
        sort: sort,
        byDist: byDist,
      );
    } catch (_) {
      final cached = getAllCachedBreweries();
      if (byCity != null ||
          byState != null ||
          byType != null ||
          byName != null ||
          byDist != null) {
        return filterLocal(
          all: cached,
          city: byCity,
          state: byState,
          type: byType,
          query: byName,
          near: byDist,
        );
      }
      final start = (page - 1) * perPage;
      final end = (start + perPage).clamp(0, cached.length);
      if (start >= cached.length) return <Brewery>[];
      return cached.sublist(start, end);
    }
  }

  Future<List<Brewery>> searchWithOfflineFallback(
    String query, {
    int page = 1,
    int perPage = 50,
  }) async {
    try {
      return await searchAndCache(query, page: page, perPage: perPage);
    } catch (_) {
      final cached = getAllCachedBreweries();
      final filtered = cached.where((b) {
        final name = (b.name ?? '').toLowerCase();
        return name.contains(query.toLowerCase());
      }).toList();
      final start = (page - 1) * perPage;
      final end = (start + perPage).clamp(0, filtered.length);
      if (start >= filtered.length) return <Brewery>[];
      return filtered.sublist(start, end);
    }
  }

  List<Brewery> getAllCachedBreweries() {
    return breweriesBox.values.toList();
  }

  Brewery? getCachedById(String id) => breweriesBox.get(id);

  Future<void> cacheBrewery(Brewery b) async {
    if (b.id != null) await breweriesBox.put(b.id!, b);
  }

  List<String> getFavorites() {
    return favoritesBox.keys
        .where((k) => favoritesBox.get(k) == true)
        .map((e) => e.toString())
        .toList();
  }

  bool isFavorite(String id) {
    return favoritesBox.get(id) == true;
  }

  Future<void> saveFavorite(String id) async {
    await favoritesBox.put(id, true);
  }

  Future<void> removeFavorite(String id) async {
    await favoritesBox.delete(id);
  }

  List<Brewery> filterLocal({
    List<Brewery>? all,
    String? city,
    String? state,
    String? type,
    String? query,
    LatLng? near,
    double? radiusKm,
  }) {
    final items = (all ?? getAllCachedBreweries()).where((b) => true).toList();

    var filtered = items;

    if (city != null && city.isNotEmpty) {
      filtered = filtered
          .where(
            (b) => (b.city ?? '').toLowerCase().contains(city.toLowerCase()),
          )
          .toList();
    }

    if (state != null && state.isNotEmpty) {
      filtered = filtered
          .where(
            (b) => (b.stateProvince ?? b.state ?? '').toLowerCase().contains(
              state.toLowerCase(),
            ),
          )
          .toList();
    }

    if (type != null && type.isNotEmpty) {
      filtered = filtered
          .where(
            (b) => (b.breweryType ?? '').toLowerCase() == type.toLowerCase(),
          )
          .toList();
    }

    if (query != null && query.isNotEmpty) {
      filtered = filtered.where((b) {
        final name = (b.name ?? '').toLowerCase();
        final cityVal = (b.city ?? '').toLowerCase();
        return name.contains(query.toLowerCase()) ||
            cityVal.contains(query.toLowerCase());
      }).toList();
    }

    if (near != null) {
      final Distance dist = Distance();
      filtered = filtered.where((b) {
        final lat = b.latitude == null
            ? null
            : double.tryParse(b.latitude.toString());
        final lng = b.longitude == null
            ? null
            : double.tryParse(b.longitude.toString());
        if (lat == null || lng == null) return false;
        final km = dist.as(
          LengthUnit.Kilometer,
          LatLng(lat, lng),
          LatLng(near.latitude, near.longitude),
        );
        if (radiusKm != null) {
          return km <= radiusKm;
        }
        return true;
      }).toList();

      if (radiusKm == null) {
        filtered.sort((a, b) {
          final aLat = double.tryParse(a.latitude.toString()) ?? 0.0;
          final aLng = double.tryParse(a.longitude.toString()) ?? 0.0;
          final bLat = double.tryParse(b.latitude.toString()) ?? 0.0;
          final bLng = double.tryParse(b.longitude.toString()) ?? 0.0;
          final aKm = Distance().as(
            LengthUnit.Kilometer,
            LatLng(aLat, aLng),
            LatLng(near.latitude, near.longitude),
          );
          final bKm = Distance().as(
            LengthUnit.Kilometer,
            LatLng(bLat, bLng),
            LatLng(near.latitude, near.longitude),
          );
          return aKm.compareTo(bKm);
        });
      }
    }

    return filtered;
  }
}
