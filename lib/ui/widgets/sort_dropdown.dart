import 'package:flutter/material.dart';

enum SortOptionEnum { nameAsc, nameDesc, cityAsc, cityDesc }

class SortDropdown extends StatelessWidget {
  final SortOptionEnum? value;
  final void Function(SortOptionEnum?) onChanged;

  const SortDropdown({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 8, right: 8),
      height: 38,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButton<SortOptionEnum>(
        underline: Container(),
        icon: Icon(Icons.sort),
        value: value,
        hint: const Text('Sort'),
        onChanged: onChanged,
        items: const [
          DropdownMenuItem(value: SortOptionEnum.nameAsc, child: Text('Name A-Z')),
          DropdownMenuItem(value: SortOptionEnum.nameDesc, child: Text('Name Z-A')),
          DropdownMenuItem(value: SortOptionEnum.cityAsc, child: Text('City A-Z')),
          DropdownMenuItem(value: SortOptionEnum.cityDesc, child: Text('City Z-A')),
        ],
      ),
    );
  }
}
