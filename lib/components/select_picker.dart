import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;

class PlatformDependentPicker extends StatelessWidget {
  final List<String> items;
  final Widget child;
  final double? modalHeight;
  final Function(dynamic) onSelectedItemChanged;

  const PlatformDependentPicker({
    super.key,
    required this.child,
    required this.items,
    required this.onSelectedItemChanged,
    this.modalHeight = 250,
  });

  @override
  Widget build(BuildContext context) {
    // return Platform.isIOS ? _iosPicker(context) : _androidDropdown();
    return _iosPicker(context);
  }

  Widget _iosPicker(BuildContext context) {
    final isDarkTheme = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    return SizedBox(
      width: double.infinity,
      child: CupertinoButton(
        color: isDarkTheme ? Colors.grey[800] : Colors.grey[200],
        child: child,
        onPressed: () => showCupertinoModalPopup(
          context: context,
          builder: (_) => SizedBox(
              width: double.infinity,
              height: modalHeight,
              child: CupertinoPicker(
                itemExtent: 30,
                backgroundColor: Colors.white,
                scrollController: FixedExtentScrollController(initialItem: 0),
                onSelectedItemChanged: onSelectedItemChanged,
                children: items.map((item) => Text(item)).toList(),
              )),
        ),
      ),
    );
  }

  Widget _androidDropdown() {
    return Material(
      child: DropdownButton<String>(
        value: items.first,
        onChanged: (String? newValue) {
          if (newValue != null) {
            onSelectedItemChanged(newValue);
          }
        },
        items: items.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }
}
