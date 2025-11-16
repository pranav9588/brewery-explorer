import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkAwareWidget extends StatefulWidget {
  final Widget child;

  const NetworkAwareWidget({super.key, required this.child});

  @override
  State<NetworkAwareWidget> createState() => _NetworkAwareWidgetState();
}

class _NetworkAwareWidgetState extends State<NetworkAwareWidget> {
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _initNetworkStatus();
    Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      final hasInternet = results.any((result) =>
      result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.ethernet);

      setState(() {
        _isOffline = !hasInternet;
      });
    });
  }

  Future<void> _initNetworkStatus() async {
    final results = await Connectivity().checkConnectivity();
    final hasInternet = results.any((result) =>
    result == ConnectivityResult.wifi ||
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.ethernet);
    setState(() {
      _isOffline = !hasInternet;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_isOffline)
          Container(
            height: 100,
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            color: Colors.redAccent,
            child: const SafeArea(
              bottom: false,
              child: Text(
                "You are offline",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white, fontSize: 16),
              ),
            ),
          ),

        Expanded(child: widget.child),
      ],
    );
  }
}
