import 'package:flutter/material.dart';

/// A 5-star rating display. When [editable] is true, tapping a star sets
/// the rating and calls [onChanged].
class StarRating extends StatelessWidget {
  const StarRating({
    super.key,
    required this.rating,
    this.editable = false,
    this.onChanged,
    this.size = 24,
  });

  final int rating;
  final bool editable;
  final ValueChanged<int>? onChanged;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final filled = index < rating;
        final icon = Icon(
          filled ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: size,
        );
        if (!editable) return icon;
        return GestureDetector(
          onTap: () => onChanged?.call(index + 1),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: icon,
          ),
        );
      }),
    );
  }
}
