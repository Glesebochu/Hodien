import 'package:flutter/material.dart';

class SearchInputBar extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  final VoidCallback? onCancel;

  const SearchInputBar({super.key, this.onChanged, this.onCancel});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();

    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: TextButton(
          onPressed: () {
            controller.clear();
            if (onCancel != null) onCancel!();
          },
          child: const Text('Cancel'),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}
