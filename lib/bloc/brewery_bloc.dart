import 'package:brewery/models/response_model.dart';
import 'package:brewery/repository/brewery_repo.dart';
import 'package:brewery/ui/widgets/sort_dropdown.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'brewery_event.dart';
import 'brewery_state.dart';
import 'dart:async';
import 'package:stream_transform/stream_transform.dart';
import 'package:latlong2/latlong.dart';

const _searchDebounce = Duration(milliseconds: 500);

EventTransformer<T> debounceTransformer<T>(Duration duration) {
  return (events, mapper) => events.debounce(duration).asyncExpand(mapper);
}

class BreweryBloc extends Bloc<BreweryEvent, BreweryState> {
  final BreweryRepository repository;

  BreweryBloc(this.repository) : super(BreweryState.initial()) {
    on<LoadBreweries>(_loadBreweries);
    on<LoadMoreBreweries>(_loadMoreBreweries);
    on<ToggleFavoriteBrewery>(_toggleFavorite);
    on<SearchQueryChanged>(_onSearchChanged, transformer: debounceTransformer(_searchDebounce));
    on<ApplyFilters>(_onApplyFilters);
    on<ChangeSort>(_onChangeSort);
    on<ClearFilters>(_onClearFilters);
    on<RefreshBreweries>(_onRefresh);
  }

  Future<void> _loadBreweries(LoadBreweries event, Emitter<BreweryState> emit) async {
    emit(state.copyWith(isLoading: true, page: 1, hasReachedEnd: false));
    try {
      final List<Brewery> results = await _fetchPage(page: 1);
      emit(state.copyWith(
        breweries: results,
        isLoading: false,
        hasReachedEnd: results.length < state.perPage,
        page: 1,
      ));
    } catch (e) {
      final List<Brewery> results = await _fetchPage(page: 1, allowFallback: true);
      emit(state.copyWith(
        breweries: results,
        isLoading: false,
        hasReachedEnd: results.length < state.perPage,
        page: 1,
      ));
    }
  }

  Future<void> _loadMoreBreweries(LoadMoreBreweries event, Emitter<BreweryState> emit) async {
    if (state.hasReachedEnd || state.isLoading) return;
    emit(state.copyWith(isLoading: true));
    final nextPage = state.page + 1;
    try {
      final List results = await _fetchPage(page: nextPage);
      emit(state.copyWith(
        breweries: [...state.breweries, ...results],
        isLoading: false,
        hasReachedEnd: results.isEmpty,
        page: nextPage,
      ));
    } catch (_) {
      final List results = await _fetchPage(page: nextPage, allowFallback: true);
      emit(state.copyWith(
        breweries: [...state.breweries, ...results],
        isLoading: false,
        hasReachedEnd: results.isEmpty,
        page: nextPage,
      ));
    }
  }

  Future<void> _onSearchChanged(SearchQueryChanged event, Emitter<BreweryState> emit) async {
    final q = event.query.trim();
    emit(state.copyWith(query: q, isLoading: true, page: 1, hasReachedEnd: false));
    try {
      if (q.isEmpty) {
        final results = await _fetchPage(page: 1);
        emit(state.copyWith(breweries: results, isLoading: false, hasReachedEnd: results.length < state.perPage));
      } else {
        final results = await repository.searchWithOfflineFallback(q, page: 1, perPage: state.perPage);
        emit(state.copyWith(breweries: results, isLoading: false, hasReachedEnd: results.length < state.perPage, page: 1));
      }
    } catch (_) {
      final cached = repository.filterLocal(query: q);
      emit(state.copyWith(breweries: cached, isLoading: false, hasReachedEnd: cached.length < state.perPage, page: 1));
    }
  }

  Future<void> _onApplyFilters(ApplyFilters event, Emitter<BreweryState> emit) async {
    emit(state.copyWith(
      filterCity: event.city,
      filterState: event.state,
      filterType: event.type,
      useLocation: event.useLocation,
      location: event.location,
      page: 1,
      isLoading: true,
      hasReachedEnd: false,
    ));

    try {
      if (state.query.isNotEmpty) {
        final results = await repository.searchWithOfflineFallback(state.query, page: 1, perPage: state.perPage);
        final filtered = repository.filterLocal(all: results, city: event.city, state: event.state, type: event.type, near: event.location);
        emit(state.copyWith(breweries: filtered, isLoading: false, hasReachedEnd: filtered.length < state.perPage));
      } else {
        final results = await repository.listWithOfflineFallback(
          page: 1,
          perPage: state.perPage,
          byCity: event.city,
          byState: event.state,
          byType: event.type,
          byDist: event.useLocation ? event.location : null,
        );
        emit(state.copyWith(breweries: results, isLoading: false, hasReachedEnd: results.length < state.perPage));
      }
    } catch (_) {
      final filtered = repository.filterLocal(city: event.city, state: event.state, type: event.type, near: event.location);
      emit(state.copyWith(breweries: filtered, isLoading: false, hasReachedEnd: filtered.length < state.perPage));
    }
  }

  Future<void> _onChangeSort(ChangeSort event, Emitter<BreweryState> emit) async {
    emit(state.copyWith(sort: event.sort, isLoading: true, page: 1));
    final List<Brewery> current = state.breweries;
    final sorted = _applySort(current, event.sort, state.location);
    emit(state.copyWith(breweries: sorted, isLoading: false));
  }

  Future<void> _onClearFilters(ClearFilters event, Emitter<BreweryState> emit) async {
    emit(state.copyWith(
      filterCity: null,
      filterState: null,
      filterType: null,
      useLocation: false,
      location: null,
      query: '',
      page: 1,
      isLoading: true,
      hasReachedEnd: false,
      sort: null,
    ));
    final results = await _fetchPage(page: 1);
    emit(state.copyWith(breweries: results, isLoading: false, hasReachedEnd: results.length < state.perPage));
  }

  Future<void> _onRefresh(RefreshBreweries event, Emitter<BreweryState> emit) async {
    emit(state.copyWith(isLoading: true, page: 1));
    final results = await _fetchPage(page: 1, forceRemote: true);
    emit(state.copyWith(breweries: results, isLoading: false, hasReachedEnd: results.length < state.perPage));
  }

  Future<void> _toggleFavorite(ToggleFavoriteBrewery event, Emitter<BreweryState> emit) async {
    final favorites = repository.getFavorites();
    if (favorites.contains(event.breweryId)) {
      await repository.removeFavorite(event.breweryId);
    } else {
      await repository.saveFavorite(event.breweryId);
    }
    emit(state.copyWith());
  }

  Future<List<Brewery>> _fetchPage({
    required int page,
    bool allowFallback = true,
    bool forceRemote = false,
  }) async {
    if (state.query.isNotEmpty && !forceRemote) {
      return await repository.searchWithOfflineFallback(
        state.query,
        page: page,
        perPage: state.perPage,
      );
    }

    LatLng? byDist;
    if (state.useLocation && state.location != null) {
      byDist = state.location!;
    }

    if (forceRemote) {
      return await repository.fetchAndCache(
        page: page,
        perPage: state.perPage,
        byCity: state.filterCity,
        byState: state.filterState,
        byType: state.filterType,
        byName: state.query.isNotEmpty ? state.query : null,
        byDist: byDist,
      );
    }

    return await repository.listWithOfflineFallback(
      page: page,
      perPage: state.perPage,
      byCity: state.filterCity,
      byState: state.filterState,
      byType: state.filterType,
      byName: state.query.isNotEmpty ? state.query : null,
      byDist: byDist,
    );
  }


  List<Brewery> _applySort(List<Brewery> items, SortOptionEnum? sort, LatLng? location) {
    if (sort == null) return items;
    final List<Brewery> sorted = List.of(items);
    switch (sort) {
      case SortOptionEnum.nameAsc:
        sorted.sort((a, b) => (a.name ?? '').toLowerCase().compareTo((b.name ?? '').toLowerCase()));
        break;
      case SortOptionEnum.nameDesc:
        sorted.sort((a, b) => (b.name ?? '').toLowerCase().compareTo((a.name ?? '').toLowerCase()));
        break;
      case SortOptionEnum.cityAsc:
        sorted.sort((a, b) => (a.city ?? '').toLowerCase().compareTo((b.city ?? '').toLowerCase()));
        break;
      case SortOptionEnum.cityDesc:
        sorted.sort((a, b) => (b.city ?? '').toLowerCase().compareTo((a.city ?? '').toLowerCase()));
        break;
      }
    return sorted;
  }
}
