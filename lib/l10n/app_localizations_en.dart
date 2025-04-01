// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get taskTitle => 'Title';

  @override
  String get description => 'Description';

  @override
  String get taskEdit => 'Task Edit';

  @override
  String get taskNew => 'New Task';

  @override
  String get delete => 'Delete Task';

  @override
  String get save => 'Save Task';

  @override
  String get languages => 'Languages';

  @override
  String get colors => 'Colors';

  @override
  String get checkAll => 'checkAll';

  @override
  String get uncheckAll => 'uncheckAll';
}
