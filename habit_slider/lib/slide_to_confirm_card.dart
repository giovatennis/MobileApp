import 'package:flutter/material.dart';

/// A reusable card with a slide-to-confirm gesture.
/// The user drags the circular handle across the track.
/// If dragged past the threshold, it snaps to "done" and stays filled.
/// If released early, it springs back to the start.
class SlideToConfirmCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isCompleted;
  final VoidCallback onConfirmed;

  const SlideToConfirmCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isCompleted,
    required this.onConfirmed,
  });

  @override
  State<SlideToConfirmCard> createState() => _SlideToConfirmCardState();
}

class _SlideToConfirmCardState extends State<SlideToConfirmCard> {
  double _dragX = 0; // current handle offset from the left
  bool _isDragging = false;

  static const double _handleSize = 48;
  static const double _trackPadding = 4;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final trackWidth = constraints.maxWidth;
        final maxDrag = trackWidth - _handleSize - _trackPadding * 2;

        // If already completed, lock the handle at the far right.
        final double handleX =
            widget.isCompleted ? maxDrag : _dragX.clamp(0, maxDrag);

        // Fill ratio drives the background color animation.
        final double fillRatio =
            maxDrag == 0 ? 0 : (handleX / maxDrag).clamp(0.0, 1.0);

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 6),
                child: Row(
                  children: [
                    Icon(widget.icon, size: 20, color: Colors.grey[700]),
                    const SizedBox(width: 8),
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Stack(
                alignment: Alignment.centerLeft,
                children: [
                  // Track background, animates color as it fills.
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: _handleSize + _trackPadding * 2,
                    width: trackWidth,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      color: Color.lerp(
                        Colors.grey[200],
                        Colors.green[400],
                        fillRatio,
                      ),
                    ),
                    child: Center(
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 150),
                        opacity: fillRatio > 0.5 ? 1 : 0.6,
                        child: Text(
                          widget.isCompleted
                              ? "Done ✓"
                              : (fillRatio > 0.7
                                  ? "Release to confirm"
                                  : widget.subtitle),
                          style: TextStyle(
                            color: fillRatio > 0.4
                                ? Colors.white
                                : Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Draggable handle.
                  AnimatedPositioned(
                    duration: _isDragging
                        ? Duration.zero
                        : const Duration(milliseconds: 250),
                    curve: Curves.easeOutBack,
                    left: handleX + _trackPadding,
                    top: _trackPadding,
                    child: GestureDetector(
                      onHorizontalDragStart: widget.isCompleted
                          ? null
                          : (_) => setState(() => _isDragging = true),
                      onHorizontalDragUpdate: widget.isCompleted
                          ? null
                          : (details) {
                              setState(() {
                                _dragX += details.delta.dx;
                                _dragX = _dragX.clamp(0, maxDrag);
                              });
                            },
                      onHorizontalDragEnd: widget.isCompleted
                          ? null
                          : (details) {
                              setState(() => _isDragging = false);
                              if (_dragX >= maxDrag * 0.75) {
                                // Snap to end and confirm.
                                setState(() => _dragX = maxDrag);
                                widget.onConfirmed();
                              } else {
                                // Spring back to start.
                                setState(() => _dragX = 0);
                              }
                            },
                      child: Container(
                        width: _handleSize,
                        height: _handleSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          widget.isCompleted
                              ? Icons.check
                              : Icons.arrow_forward_ios,
                          color: widget.isCompleted
                              ? Colors.green
                              : Colors.grey[700],
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void didUpdateWidget(SlideToConfirmCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset the local drag position whenever the parent resets completion.
    if (!widget.isCompleted && oldWidget.isCompleted) {
      _dragX = 0;
    }
  }
}
