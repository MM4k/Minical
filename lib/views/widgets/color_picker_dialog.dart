import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../../l10n/app_localizations.dart';

/// Shows a solid-color picker (no alpha) and returns the chosen color, or null
/// if the user cancels.
Future<Color?> showColorPickerDialog(BuildContext context, Color initial) {
  final l = AppLocalizations.of(context);
  var selected = initial;
  return showDialog<Color>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l.pickColor),
      content: SingleChildScrollView(
        child: ColorPicker(
          pickerColor: initial,
          enableAlpha: false,
          labelTypes: const [],
          onColorChanged: (color) => selected = color,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(selected),
          child: Text(l.select),
        ),
      ],
    ),
  );
}
