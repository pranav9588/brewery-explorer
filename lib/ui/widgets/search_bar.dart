import 'dart:async';
import 'package:flutter/material.dart';

class SearchBarWidget extends StatefulWidget implements PreferredSizeWidget {
  final void Function(String) onSearch;
  final String? initial;

  const SearchBarWidget({super.key, required this.onSearch, this.initial});

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final _ctrl = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _ctrl.text = widget.initial ?? '';
  }

  void _onChanged(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      widget.onSearch(q.trim());
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Container(
        padding: EdgeInsets.only(left: 6),
        decoration: BoxDecoration(
          // color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: BoxBorder.all()
        ),
        child: TextField(
          controller: _ctrl,
          onChanged: _onChanged,
          textInputAction: TextInputAction.search,
          onSubmitted: (v) => widget.onSearch(v.trim()),
          decoration: const InputDecoration(
            hintText: 'Search breweries by name...',
            border: InputBorder.none,
          ),
        ),
      ),
      actions: [
        IconButton(icon: const Icon(Icons.clear), onPressed: () {
          _ctrl.clear();
          widget.onSearch('');
        }),
      ],
    );
  }
}
