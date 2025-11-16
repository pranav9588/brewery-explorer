import 'package:brewery/bloc/brewery_bloc.dart';
import 'package:brewery/bloc/brewery_event.dart';
import 'package:brewery/bloc/brewery_state.dart';
import 'package:brewery/ui/brewery_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'widgets/search_bar.dart';
import 'widgets/filter_sheet.dart';
import 'widgets/sort_dropdown.dart';

class BreweryListScreen extends StatefulWidget {
  const BreweryListScreen({super.key});

  @override
  State<BreweryListScreen> createState() => _BreweryListScreenState();
}

class _BreweryListScreenState extends State<BreweryListScreen> {
  final ScrollController _scrollController = ScrollController();
  late BreweryBloc _bloc;
  SortOptionEnum? _selectedSort;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<BreweryBloc>();
    _scrollController.addListener(_onScroll);
    _bloc.add(const LoadBreweries());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _bloc.add(const LoadMoreBreweries());
    }
  }

  void _onSearch(String query) {
    _bloc.add(SearchQueryChanged(query));
  }

  Future<void> _openFilterSheet(
    BuildContext context,
    BreweryState state,
  ) async {
    final _ = await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => FilterSheet(
        initialCity: state.filterCity,
        initialState: state.filterState,
        initialType: state.filterType,
        onApply: (city, st, type, useLocation) async {
          LatLng? loc;
          if (useLocation) {
            final position = await _getCurrentPosition();
            if (position != null) {
              loc = LatLng(position.latitude, position.longitude);
            }
          }
          _bloc.add(
            ApplyFilters(
              city: city,
              state: st,
              type: type,
              useLocation: useLocation,
              location: loc,
            ),
          );
        },
      ),
    );
  }

  Future<Position?> _getCurrentPosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      if (permission == LocationPermission.deniedForever) return null;
      return await Geolocator.getCurrentPosition();
    } catch (_) {
      return null;
    }
  }

  void _clearAll() {
    _bloc.add(const ClearFilters());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BreweryBloc, BreweryState>(
      builder: (context, state) {
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: SearchBarWidget(onSearch: _onSearch, initial: state.query),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    SortDropdown(
                      value: _selectedSort,
                      onChanged: (opt) {
                        setState(() => _selectedSort = opt);
                        _bloc.add(ChangeSort(opt));
                      },
                    ),

                    const SizedBox(width: 12),

                    ElevatedButton.icon(
                      onPressed: () => _openFilterSheet(context, state),
                      icon: const Icon(Icons.filter_list),
                      label: const Text('Filter'),
                    ),
                    const Spacer(),
                    if (state.query.isNotEmpty ||
                        state.filterCity != null ||
                        state.filterState != null ||
                        state.filterType != null)
                      TextButton(
                        onPressed: _clearAll,
                        child: const Text('Clear'),
                      ),
                  ],
                ),
              ),

              if (state.query.isNotEmpty ||
                  state.filterCity != null ||
                  state.filterState != null ||
                  state.filterType != null)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      if (state.query.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: InputChip(
                            label: Text('Search: "${state.query}"'),
                            onDeleted: () =>
                                _bloc.add(const SearchQueryChanged('')),
                          ),
                        ),
                      if (state.filterCity != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: InputChip(
                            label: Text('City: ${state.filterCity}'),
                            onDeleted: () => _bloc.add(
                              ApplyFilters(
                                city: null,
                                state: state.filterState,
                                type: state.filterType,
                              ),
                            ),
                          ),
                        ),
                      if (state.filterState != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: InputChip(
                            label: Text('State: ${state.filterState}'),
                            onDeleted: () => _bloc.add(
                              ApplyFilters(
                                city: state.filterCity,
                                state: null,
                                type: state.filterType,
                              ),
                            ),
                          ),
                        ),
                      if (state.filterType != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: InputChip(
                            label: Text('Type: ${state.filterType}'),
                            onDeleted: () => _bloc.add(
                              ApplyFilters(
                                city: state.filterCity,
                                state: state.filterState,
                                type: null,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

              const SizedBox(height: 8),

              Expanded(
                child: Builder(
                  builder: (_) {
                    if (state.isLoading && state.breweries.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      itemCount:
                          state.breweries.length +
                          (state.hasReachedEnd ? 0 : 1),
                      itemBuilder: (context, index) {
                        if (index == state.breweries.length) {
                          return const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final brewery = state.breweries[index];

                        final isFav = _bloc.repository.isFavorite(brewery.id!);

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: ListTile(
                            title: Text(
                              brewery.name ?? 'Unknown Brewery',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '${brewery.city ?? ''}, ${brewery.state ?? ''}',
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                isFav ? Icons.favorite : Icons.favorite_border,
                                color: Colors.redAccent,
                              ),
                              onPressed: () {
                                _bloc.add(ToggleFavoriteBrewery(brewery.id!));
                                setState(() {});
                              },
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      BreweryDetailPage(brewery: brewery),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
