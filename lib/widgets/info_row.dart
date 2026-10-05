import 'package:flutter/material.dart';

/// Linha "rótulo — valor" com divisória. Com [onTap], mostra uma seta.
class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onTap;
  const InfoRow(this.label, this.value, {super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(label,
                      style: TextStyle(color: Colors.grey.shade700)),
                ),
                Flexible(
                  child: Text(value,
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
                if (onTap != null) const Icon(Icons.chevron_right, size: 18),
              ],
            ),
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}