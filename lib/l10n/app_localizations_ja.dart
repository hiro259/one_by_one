// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get taskTitle => 'タイトル';

  @override
  String get description => '詳細';

  @override
  String get taskEdit => '編集';

  @override
  String get taskNew => '新規';

  @override
  String get delete => '削除';

  @override
  String get save => '保存';

  @override
  String get languages => '言語設定';

  @override
  String get colors => '色設定';

  @override
  String get checkAll => '全てチェックする';

  @override
  String get uncheckAll => '全てチェックを外す';
}
