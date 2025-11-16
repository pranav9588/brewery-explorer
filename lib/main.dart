import 'package:brewery/bloc/brewery_bloc.dart';
import 'package:brewery/repository/brewery_repo.dart';
import 'package:brewery/services/brewery_api.dart';
import 'package:brewery/ui/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/adapters.dart';

import 'bloc/bottom_nav_cubit.dart';
import 'bloc/brewery_event.dart';
import 'models/response_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(BreweryAdapter());
  final Box<Brewery> breweriesBox = await Hive.openBox<Brewery>('breweries');
  final Box<bool> favoritesBox = await Hive.openBox<bool>('favorites');
  final apiService = BreweryApiService();
  final repo = BreweryRepository(
    api: apiService,
    breweriesBox: breweriesBox,
    favoritesBox: favoritesBox,
  );
  runApp(MyApp(repository: repo));
}

class MyApp extends StatelessWidget {
  final BreweryRepository repository;

  const MyApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => BottomNavCubit()),
        BlocProvider(
          create: (_) => BreweryBloc(repository)..add(LoadBreweries()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Brewery App",
        home: SplashScreen(),
      ),
    );
  }
}
