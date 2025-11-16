import 'package:flutter/material.dart';
import '../../core/utils/utilities.dart';
import '../../models/response_model.dart';

class BreweryBottomSheet extends StatelessWidget {
  final Brewery brewery;

  const BreweryBottomSheet(this.brewery, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        children: [
          Text(
            brewery.name ?? "Unknown Brewery",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),
          _detail("Brewery Type", brewery.breweryType),
          _detail("City", brewery.city),
          _detail("State", brewery.stateProvince),
          _detail("Country", brewery.country),
          _detail("Phone", brewery.phone),
          _detail("Street", brewery.street),
          _detail("Postal Code", brewery.postalCode),

          const SizedBox(height: 16),
          if (brewery.websiteUrl != null)
            ElevatedButton.icon(
              onPressed: () => Utilities.launchURL(brewery.websiteUrl!),
              icon: const Icon(Icons.open_in_browser),
              label: const Text("Open Website"),
            ),
        ],
      ),
    );
  }

  Widget _detail(String title, String? value) {
    if (value == null || value.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text("$title: ",
              style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
