import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'controllers/category_controller.dart';
import 'controllers/event_controller.dart';
import 'controllers/settings_controller.dart';
import 'data/category_repository.dart';
import 'data/event_repository.dart';
import 'data/notification_service.dart';
import 'data/settings_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settingsStore = SettingsStore();
  final settings = await settingsStore.load();
  final settingsController = SettingsController(settingsStore, settings);

  await NotificationService.instance.init();

  final categoryController = CategoryController(CategoryRepository());
  final eventController =
      EventController(EventRepository(), NotificationService.instance);
  await categoryController.load();
  await eventController.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settingsController),
        ChangeNotifierProvider.value(value: categoryController),
        ChangeNotifierProvider.value(value: eventController),
      ],
      child: const MinicalApp(),
    ),
  );
}
