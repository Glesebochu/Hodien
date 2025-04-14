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
        hintStyle: TextStyle(
          color: const Color.fromARGB(255, 152, 152, 152),
        ), // 🔹 Hint text style
        prefixIcon: const Icon(
          Icons.search,
          color: Colors.grey,
          size: 20,
        ), // 🔹 Search icon
        suffixIcon: TextButton(
          onPressed: () {
            controller.clear();
            if (onCancel != null) onCancel!();
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.black,
            overlayColor: Colors.transparent, // disables hover/press ripple
            padding: EdgeInsets.zero, // remove extra space if needed
          ),
          child: const Icon(Icons.cancel, color: Colors.grey),
        ),
        filled: true, // 🔹 Fills the background
        fillColor: Colors.grey[200], // 🔹 Soft grey background
        // border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14, // 🔹 Adjust this for vertical centering
          horizontal: 16,
        ),
      ),
    );
  }
}
