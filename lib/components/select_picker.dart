import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;

class PlatformDependentPicker extends StatelessWidget {
  final List<String> items;
  final Widget iosSelectedItem;
  final Widget? hint;
  final double? modalHeight;
  final dynamic androidValue;
  final String Function(dynamic)? itemLabel;
  final Function(dynamic) onSelectedItemChanged;

  const PlatformDependentPicker({
    super.key,
    required this.iosSelectedItem,
    this.androidValue,
    required this.items,
    required this.onSelectedItemChanged,
    this.modalHeight = 250,
    this.hint,
    this.itemLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS ? _iosPicker(context) : _androidDropdown(context);
    // return _iosPicker(context);
  }

  Widget _iosPicker(BuildContext context) {
    final isDarkTheme = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    return SizedBox(
      width: double.infinity,
      child: CupertinoButton(
        color: isDarkTheme ? Colors.grey[800] : Colors.grey[200],
        child: iosSelectedItem,
        padding: const EdgeInsets.symmetric(vertical: 12),
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
                children: items
                    .map((item) =>
                        Text(itemLabel != null ? itemLabel!(item) : item))
                    .toList(),
              )),
        ),
      ),
    );
  }

  Widget _androidDropdown(BuildContext context) {
    var isDarkTheme = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isDarkTheme ? Colors.grey[800] : Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: DropdownButton<String>(
          dropdownColor: isDarkTheme ? Colors.grey[800] : Colors.grey[200],
          isExpanded: true,
          itemHeight: 50,
          hint: hint,
          underline: const SizedBox.shrink(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              onSelectedItemChanged(newValue);
            }
          },
          items: items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                itemLabel != null ? itemLabel!(value) : value,
                style: TextStyle(
                  color: isDarkTheme ? Colors.white60 : Colors.black54,
                ),
              ),
            );
          }).toList(),
          value: androidValue,
        ),
      ),
    );
  }
}
