import 'package:brewery/models/response_model.dart';
import 'package:brewery/ui/widgets/sort_dropdown.dart';
import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import 'brewery_event.dart';

class BreweryState extends Equatable {
  final List<Brewery> breweries;
  final bool isLoading;
  final bool hasReachedEnd;
  final int page;
  final int perPage;

  final String query;
  final String? filterCity;
  final String? filterState;
  final String? filterType;
  final bool useLocation;
  final LatLng? location;
  final SortOptionEnum? sort;

  const BreweryState({
    required this.breweries,
    required this.isLoading,
    required this.hasReachedEnd,
    required this.page,
    required this.perPage,
    required this.query,
    this.filterCity,
    this.filterState,
    this.filterType,
    this.useLocation = false,
    this.location,
    this.sort,
  });

  factory BreweryState.initial() => BreweryState(
    breweries: const [],
    isLoading: false,
    hasReachedEnd: false,
    page: 1,
    perPage: 50,
    query: '',
    filterCity: null,
    filterState: null,
    filterType: null,
    useLocation: false,
    location: null,
    sort: null,
  );

  BreweryState copyWith({
    List<Brewery>? breweries,
    bool? isLoading,
    bool? hasReachedEnd,
    int? page,
    int? perPage,
    String? query,
    String? filterCity,
    String? filterState,
    String? filterType,
    bool? useLocation,
    LatLng? location,
    SortOptionEnum? sort,
  }) {
    return BreweryState(
      breweries: breweries ?? this.breweries,
      isLoading: isLoading ?? this.isLoading,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
      query: query ?? this.query,
      filterCity: filterCity ?? this.filterCity,
      filterState: filterState ?? this.filterState,
      filterType: filterType ?? this.filterType,
      useLocation: useLocation ?? this.useLocation,
      location: location ?? this.location,
      sort: sort ?? this.sort,
    );
  }

  @override
  List<Object?> get props => [
    breweries,
    isLoading,
    hasReachedEnd,
    page,
    perPage,
    query,
    filterCity,
    filterState,
    filterType,
    useLocation,
    location,
    sort,
  ];
}
