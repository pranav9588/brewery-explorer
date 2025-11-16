import 'package:brewery/ui/widgets/sort_dropdown.dart';
import 'package:equatable/equatable.dart';

import 'package:latlong2/latlong.dart';

abstract class BreweryEvent extends Equatable {
  const BreweryEvent();

  @override
  List<Object?> get props => [];
}

class LoadBreweries extends BreweryEvent {
  const LoadBreweries();
}

class LoadMoreBreweries extends BreweryEvent {
  const LoadMoreBreweries();
}

class RefreshBreweries extends BreweryEvent {
  const RefreshBreweries();
}

class ToggleFavoriteBrewery extends BreweryEvent {
  final String breweryId;

  const ToggleFavoriteBrewery(this.breweryId);

  @override
  List<Object?> get props => [breweryId];
}

class SearchQueryChanged extends BreweryEvent {
  final String query;

  const SearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class ApplyFilters extends BreweryEvent {
  final String? city;
  final String? state;
  final String? type;
  final bool useLocation;
  final LatLng? location;

  const ApplyFilters({
    this.city,
    this.state,
    this.type,
    this.useLocation = false,
    this.location,
  });

  @override
  List<Object?> get props => [city, state, type, useLocation, location];
}


class ChangeSort extends BreweryEvent {
  final SortOptionEnum? sort;

  const ChangeSort(this.sort);

  @override
  List<Object?> get props => [sort];
}

class ClearFilters extends BreweryEvent {
  const ClearFilters();
}
