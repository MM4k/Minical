import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/category_controller.dart';
import '../../l10n/app_localizations.dart';
import '../../models/category.dart';
import '../../theme/app_themes.dart';
import '../widgets/color_picker_dialog.dart';

/// Lists categories and lets the user create, edit and delete them.
class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  Future<void> _edit(BuildContext context, {Category? existing}) async {
    final controller = context.read<CategoryController>();
    final result = await showDialog<Category>(
      context: context,
      builder: (_) => _CategoryDialog(existing: existing),
    );
    if (result == null) return;
    if (existing == null) {
      await controller.add(result);
    } else {
      await controller.update(result);
    }
  }

  Future<void> _delete(BuildContext context, Category category) async {
    final l = AppLocalizations.of(context);
    final controller = context.read<CategoryController>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.deleteCategoryTitle),
        content: Text(l.deleteCategoryMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l.delete),
          ),
        ],
      ),
    );
    if (confirmed == true && category.id != null) {
      await controller.remove(category.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final categories = context.watch<CategoryController>().categories;

    return Scaffold(
      appBar: AppBar(title: Text(l.categories)),
      body: categories.isEmpty
          ? Center(
              child: Text(
                l.noCategories,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            )
          : ListView.separated(
              itemCount: categories.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final category = categories[index];
                return ListTile(
                  leading: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Color(category.color),
                      shape: BoxShape.circle,
                    ),
                  ),
                  title: Text(category.name),
                  trailing: IconButton(
                    tooltip: l.delete,
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _delete(context, category),
                  ),
                  onTap: () => _edit(context, existing: category),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        tooltip: l.newCategory,
        onPressed: () => _edit(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CategoryDialog extends StatefulWidget {
  const _CategoryDialog({this.existing});
  final Category? existing;

  @override
  State<_CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<_CategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late Color _color;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.existing?.name ?? '');
    _color = widget.existing != null
        ? Color(widget.existing!.color)
        : AppThemes.presets['blue']!;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final base = widget.existing ?? const Category(name: '', color: 0);
    Navigator.of(context).pop(
      base.copyWith(name: _name.text.trim(), color: _color.toARGB32()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.existing == null ? l.newCategory : l.editCategory),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _name,
              autofocus: true,
              decoration: InputDecoration(labelText: l.categoryName),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? l.nameRequired
                  : null,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text(l.color),
                const Spacer(),
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () async {
                    final picked = await showColorPickerDialog(context, _color);
                    if (picked != null) setState(() => _color = picked);
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _color,
                      shape: BoxShape.circle,
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.cancel),
        ),
        FilledButton(onPressed: _submit, child: Text(l.save)),
      ],
    );
  }
}
