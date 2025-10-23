import 'package:flutter/material.dart';

/// RadioGroup widget for Flutter 3.22+ (Material 3)
/// This is a minimal implementation for single selection.
class SimpleRadioGroup<T> extends StatefulWidget {
  final List<T> values;
  final T? selected;
  final Widget Function(T value, bool selected) itemBuilder;
  final ValueChanged<T?> onChanged;
  final Axis direction;
  final EdgeInsetsGeometry? padding;

  const SimpleRadioGroup({
    super.key,
    required this.values,
    required this.selected,
    required this.itemBuilder,
    required this.onChanged,
    this.direction = Axis.vertical,
    this.padding,
  });

  @override
  State<SimpleRadioGroup<T>> createState() => _SimpleRadioGroupState<T>();
}

class _SimpleRadioGroupState<T> extends State<SimpleRadioGroup<T>> {
  T? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selected;
  }

  @override
  void didUpdateWidget(SimpleRadioGroup<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected != oldWidget.selected) {
      _selected = widget.selected;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding ?? EdgeInsets.zero,
      child: Flex(
        direction: widget.direction,
        children: widget.values.map((v) {
          final selected = v == _selected;
          return InkWell(
            onTap: () {
              setState(() => _selected = v);
              widget.onChanged(v);
            },
            child: widget.itemBuilder(v, selected),
          );
        }).toList(),
      ),
    );
  }
}
