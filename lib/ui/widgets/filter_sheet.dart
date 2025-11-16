import 'package:flutter/material.dart';

class FilterSheet extends StatefulWidget {
  final String? initialCity;
  final String? initialState;
  final String? initialType;
  final void Function(String? city, String? state, String? type, bool useLocation) onApply;

  const FilterSheet({super.key, this.initialCity, this.initialState, this.initialType, required this.onApply});

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late TextEditingController cityCtrl;
  late TextEditingController stateCtrl;
  String? _type;
  bool _useLocation = false;

  @override
  void initState() {
    super.initState();
    cityCtrl = TextEditingController(text: widget.initialCity);
    stateCtrl = TextEditingController(text: widget.initialState);
    _type = widget.initialType;
  }

  @override
  void dispose() {
    cityCtrl.dispose();
    stateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.viewInsetsOf(context).add(const EdgeInsets.all(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: cityCtrl, decoration: const InputDecoration(labelText: 'City')),
          TextField(controller: stateCtrl, decoration: const InputDecoration(labelText: 'State (full name)')),
          DropdownButtonFormField<String>(
            value: _type,
            items: const [
              DropdownMenuItem(value: null, child: Text('Any type')),
              DropdownMenuItem(value: 'micro', child: Text('micro')),
              DropdownMenuItem(value: 'brewpub', child: Text('brewpub')),
              DropdownMenuItem(value: 'regional', child: Text('regional')),
              DropdownMenuItem(value: 'closed', child: Text('closed')),
            ],
            onChanged: (v) => setState(() => _type = v),
            decoration: const InputDecoration(labelText: 'Type'),
          ),
          SwitchListTile(
            title: const Text('Use my location for distance'),
            value: _useLocation,
            onChanged: (v) => setState(() => _useLocation = v),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: ElevatedButton(onPressed: () {
                widget.onApply(cityCtrl.text.trim().isEmpty ? null : cityCtrl.text.trim(),
                    stateCtrl.text.trim().isEmpty ? null : stateCtrl.text.trim(),
                    _type, _useLocation);
                Navigator.pop(context);
              }, child: const Text('Apply'))),
            ],
          ),
        ],
      ),
    );
  }
}
