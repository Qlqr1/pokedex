import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Item de lista em formato de cartão (redesign): ícone/miniatura à esquerda,
/// título, subtítulo e seta. Ícones simples ganham uma caixa arredondada.
class PokeTile extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool showChevron;
  final bool highlighted;

  const PokeTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.onTap,
    this.showChevron = true,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget? lead = leading;
    if (lead is Icon) {
      lead = Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.track,
          borderRadius: BorderRadius.circular(10),
        ),
        child: lead,
      );
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      decoration: BoxDecoration(
        color: highlighted ? const Color(0xFF2A1D20) : AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: highlighted ? AppColors.red : AppColors.line),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                if (lead != null) ...[lead, const SizedBox(width: 12)],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      if (subtitle != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            subtitle!,
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 11,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (showChevron)
                  const Icon(Icons.chevron_right, color: AppColors.muted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
