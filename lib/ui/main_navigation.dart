import 'package:brewery/bloc/brewery_state.dart';
import 'package:brewery/core/network/network_aware_widget.dart';
import 'package:brewery/ui/brewery_list_page.dart';
import 'package:brewery/ui/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import '../bloc/bottom_nav_cubit.dart';
import '../bloc/brewery_bloc.dart';
import 'map_screen.dart';
import 'favourites_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late final PageController _pageController;
  static const _animationDuration = Duration(milliseconds: 350);
  static const _animationCurve = Curves.easeInOut;

  @override
  void initState() {
    super.initState();
    final initialIndex = context.read<BottomNavCubit>().state;
    _pageController = PageController(initialPage: initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        final currentIndex = context.read<BottomNavCubit>().state;
        if (currentIndex != 0) {
          context.read<BottomNavCubit>().changeTab(0);
        } else {
          SystemNavigator.pop();
        }
      },
      child: NetworkAwareWidget(
        child: BlocListener<BottomNavCubit, int>(
          listener: (context, index) {
            if (_pageController.hasClients) {
              _pageController.animateToPage(
                index,
                duration: _animationDuration,
                curve: _animationCurve,
              );
            }
          },
          child: BlocBuilder<BottomNavCubit, int>(
            builder: (context, currentIndex) {
              return BlocBuilder<BreweryBloc, BreweryState>(
                builder: (context, state) {
                  final breweryList = state.breweries;

                  final screens = [
                    const BreweryListScreen(),
                    MapScreen(breweries: breweryList),
                    const FavoritesPage(),
                    const ProfileAboutScreen(),
                  ];

                  return Scaffold(
                    body: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: screens,
                    ),
                    bottomNavigationBar: BottomNavigationBar(
                      currentIndex: currentIndex,
                      onTap: (i) {
                        context.read<BottomNavCubit>().changeTab(i);
                      },
                      items: const [
                        BottomNavigationBarItem(
                          icon: Icon(Icons.home, color: Colors.black),
                          label: "Home",
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.map, color: Colors.black),
                          label: "Map",
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.favorite, color: Colors.black),
                          label: "Favorites",
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.person, color: Colors.black),
                          label: "Profile",
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
