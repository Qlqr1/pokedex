import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Campo de busca padrão das listas, com botão de limpar.
class ListSearchField extends StatefulWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  final bool autofocus;

  const ListSearchField({
    super.key,
    required this.hint,
    required this.onChanged,
    this.autofocus = false,
  });

  @override
  State<ListSearchField> createState() => _ListSearchFieldState();
}

class _ListSearchFieldState extends State<ListSearchField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    widget.onChanged('');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: TextField(
        controller: _controller,
        autofocus: widget.autofocus,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          hintText: widget.hint,
          filled: true,
          fillColor: AppColors.card,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          isDense: true,
          suffixIcon: _controller.text.isEmpty
              ? null
              : IconButton(icon: const Icon(Icons.clear), onPressed: _clear),
        ),
        onChanged: (v) {
          widget.onChanged(v);
          setState(() {}); // atualiza o botão de limpar
        },
      ),
    );
  }
}
