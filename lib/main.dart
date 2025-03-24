import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:one_by_one/l10n/app_localizations.dart';

void main() {
  runApp(const OneByOneApp());
}

// グローバルなタスクリポジトリ（MVP用：In-Memory実装）
final TaskRepository taskRepository = TaskRepository();

class OneByOneApp extends StatefulWidget {
  const OneByOneApp({Key? key}) : super(key: key);

  @override
  State<OneByOneApp> createState() => _OneByOneAppState();
}

class _OneByOneAppState extends State<OneByOneApp> {
  Locale _locale = const Locale('en', '');

  // 言語を変更するためのメソッド
  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'One by one',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      locale: _locale, // 現在のLocaleを指定
      localizationsDelegates: [
        AppLocalizations.delegate, // これを追加！
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: OneByOneHomePage(setLocale: setLocale),
    );
  }
}

class OneByOneHomePage extends StatefulWidget {
  final void Function(Locale) setLocale;

  // onLocaleChange を必須パラメータに指定するため、const は削除（実行時に変わる値が渡されるため）
  const OneByOneHomePage({Key? key, required this.setLocale}) : super(key: key);

  @override
  State<OneByOneHomePage> createState() =>
      _OneByOneHomePageState(setLocale: setLocale);
}

class _OneByOneHomePageState extends State<OneByOneHomePage> {
  final void Function(Locale) setLocale;

  _OneByOneHomePageState({required this.setLocale});

  // リポジトリからタスク一覧を参照
  List<Task> get _tasks => taskRepository.getTasks();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!; // ここで取得する
    return Scaffold(
      appBar: AppBar(
        title: const Text('One by one'),
        leading: PopupMenuButton<String>(
          icon: const Icon(Icons.menu),
          onSelected: (value) {
            setState(() {
              switch (value) {
                case 'checkAll':
                  // 全タスクを完了にする処理
                  taskRepository.markAllAsComplete();
                  break;
                case 'uncheckAll':
                  // 全タスクを未完了にする処理
                  taskRepository.markAllAsIncomplete();
                  break;
              }
            });
          },
          itemBuilder:
              (context) => [
                const PopupMenuItem(
                  value: 'checkAll',
                  child: Text('Check All'),
                ),
                const PopupMenuItem(
                  value: 'uncheckAll',
                  child: Text('Uncheck All'),
                ),
              ],
        ),

        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // 設定画面へ遷移
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SettingsScreen(setLocale: setLocale),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          return _buildListItem(_tasks[index]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // FABが押された場合は「New Task」モードのダイアログを表示
          final TaskEditResult? result = await showDialog<TaskEditResult>(
            context: context,
            builder: (context) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const TaskEditDialogContent(isNewTask: true),
              );
            },
          );

          if (result != null && result.task != null) {
            // 新規タスク追加：タスクIDは現在時刻のミリ秒を利用
            final newTask = result.task!;
            newTask.id = DateTime.now().millisecondsSinceEpoch.toString();
            taskRepository.addTask(newTask);
            setState(() {});
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildListItem(Task task) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: InkWell(
          onTap: () async {
            // 編集モードの場合、タップで編集用ダイアログを表示
            final TaskEditResult? result = await showDialog<TaskEditResult>(
              context: context,
              builder: (context) {
                return Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TaskEditDialogContent(isNewTask: false, task: task),
                );
              },
            );
            if (result != null) {
              if (result.isDeleted) {
                taskRepository.deleteTask(task.id);
              } else if (result.task != null) {
                taskRepository.updateTask(result.task!);
              }
              setState(() {});
            }
          },
          customBorder: const CircleBorder(),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Icon(
              task.icon,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ),
        title: Text(task.title),
        subtitle: Text(task.subTitle),
        trailing: Switch(
          value: task.isCompleted,
          onChanged: (val) {
            setState(() {
              task.isCompleted = val;
            });
          },
        ),
      ),
    );
  }
}

/// TaskEditResult: ダイアログ終了時に返す結果クラス
class TaskEditResult {
  final Task? task;
  final bool isDeleted;
  TaskEditResult({this.task, this.isDeleted = false});
}

/// TaskEditDialogContentは、isNewTaskパラメータとtaskパラメータで新規作成と編集モードを切り替えます。
class TaskEditDialogContent extends StatefulWidget {
  final bool isNewTask;
  final Task? task;
  const TaskEditDialogContent({Key? key, required this.isNewTask, this.task})
    : super(key: key);

  @override
  State<TaskEditDialogContent> createState() => _TaskEditDialogContentState();
}

class _TaskEditDialogContentState extends State<TaskEditDialogContent> {
  late TextEditingController _titleController;
  late TextEditingController _subTitleController;
  late IconData _selectedIcon;

  @override
  void initState() {
    super.initState();
    if (widget.isNewTask) {
      _titleController = TextEditingController();
      _subTitleController = TextEditingController();
      _selectedIcon = Icons.person; // デフォルトアイコン
    } else {
      // 編集モード：既存のTaskから初期値を設定
      _titleController = TextEditingController(text: widget.task?.title ?? '');
      _subTitleController = TextEditingController(
        text: widget.task?.subTitle ?? '',
      );
      _selectedIcon = widget.task?.icon ?? Icons.person;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!; // ここで取得する
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // タイトル部
            Text(
              widget.isNewTask ? loc.taskNew : loc.taskEdit,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            // アイコン＋ラベル部
            Row(
              children: [
                InkWell(
                  onTap: () async {
                    final IconData? pickedIcon =
                        await showModalBottomSheet<IconData>(
                          context: context,
                          builder: (context) {
                            return const IconPickerSheet();
                          },
                        );
                    if (pickedIcon != null) {
                      setState(() {
                        _selectedIcon = pickedIcon;
                      });
                    }
                  },
                  customBorder: const CircleBorder(),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,

                  child: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(
                      _selectedIcon,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text('Icon', style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: 16),
            // Title入力フィールド
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: loc.taskTitle,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _titleController.clear();
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            // SubTitle入力フィールド
            TextField(
              controller: _subTitleController,
              decoration: InputDecoration(
                labelText: loc.description,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _subTitleController.clear();
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            // ボタン部：新規モードならSaveのみ、編集モードならDeleteとSaveを表示
            Row(
              children: [
                if (!widget.isNewTask)
                  TextButton(
                    onPressed: () {
                      // Delete処理：結果としてisDeleted=trueを返す
                      Navigator.of(
                        context,
                      ).pop(TaskEditResult(isDeleted: true));
                    },
                    child: Text(loc.delete),
                  ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // Save処理：入力値からTaskを作成（編集なら既存のIDを引き継ぐ）
                    final newTask = Task(
                      id:
                          widget.isNewTask
                              ? ''
                              : widget.task!.id, // 新規ならIDは空、後で設定する
                      title: _titleController.text,
                      subTitle: _subTitleController.text,
                      icon: _selectedIcon,
                      isCompleted:
                          widget.isNewTask ? false : widget.task!.isCompleted,
                    );
                    Navigator.of(
                      context,
                    ).pop(TaskEditResult(task: newTask, isDeleted: false));
                  },
                  child: Text(loc.save),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// IconPickerSheetは、ボトムシート形式で複数のアイコンから選択できるUIです。
class IconPickerSheet extends StatelessWidget {
  const IconPickerSheet({Key? key}) : super(key: key);

  static final List<IconData> _iconOptions = [
    Icons.person,
    Icons.home,
    Icons.work,
    Icons.school,
    Icons.favorite,
    Icons.star,
    Icons.alarm,
    Icons.phone,
    Icons.access_alarm,
    Icons.accessibility,
    Icons.account_balance,
    Icons.adb,
    Icons.airplanemode_active,
    Icons.backup,
    Icons.camera_alt,
    Icons.chat,
    Icons.map,
    Icons.shopping_cart,
    Icons.lightbulb,
    Icons.event,
    Icons.music_note,
    Icons.book,
    Icons.note_add,
    Icons.wifi,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: GridView.builder(
        itemCount: _iconOptions.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemBuilder: (context, index) {
          final iconData = _iconOptions[index];
          return InkWell(
            onTap: () {
              Navigator.of(context).pop(iconData);
            },
            child: CircleAvatar(
              radius: 10, //add by hiro259
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                iconData,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// ドメインモデル
class Task {
  String id;
  String title;
  String subTitle;
  IconData icon;
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.subTitle,
    required this.icon,
    this.isCompleted = false,
  });
}

/// タスク管理のリポジトリ（In-Memory実装）
class TaskRepository {
  final List<Task> _tasks = [];

  List<Task> getTasks() => _tasks;

  void addTask(Task task) {
    _tasks.add(task);
  }

  void updateTask(Task task) {
    int index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
    }
  }

  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
  }

  void markAllAsComplete() {
    for (var task in _tasks) {
      task.isCompleted = true;
    }
  }

  void markAllAsIncomplete() {
    for (var task in _tasks) {
      task.isCompleted = false;
    }
  }
}

// 1. SettingsScreenをStatefulWidgetに変更し、言語・色の選択を管理
class SettingsScreen extends StatefulWidget {
  final void Function(Locale) setLocale;

  const SettingsScreen({Key? key, required this.setLocale}) : super(key: key);

  @override
  State<SettingsScreen> createState() =>
      _SettingsScreenState(setLocale: setLocale);
}

class _SettingsScreenState extends State<SettingsScreen> {
  final void Function(Locale) setLocale;
  _SettingsScreenState({required this.setLocale});
  // 簡易的に英語・日本語のみ
  String _selectedLanguage = 'English';
  // 選択した色（MaterialColorやColorなど）
  Color _selectedColor = Colors.blue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // Languages
          ListTile(
            title: const Text('Languages'),
            subtitle: Text(_selectedLanguage),
            onTap: () {
              // 言語選択のダイアログを表示
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Choose Language'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RadioListTile<String>(
                          title: const Text('English'),
                          value: 'English',
                          groupValue: _selectedLanguage,
                          onChanged: (value) {
                            setState(() {
                              _selectedLanguage = value ?? 'English';
                              setLocale(const Locale('en'));
                            });
                            Navigator.of(context).pop();
                          },
                        ),
                        RadioListTile<String>(
                          title: const Text('Japanese'),
                          value: 'Japanese',
                          groupValue: _selectedLanguage,
                          onChanged: (value) {
                            setState(() {
                              _selectedLanguage = value ?? 'English';

                              setLocale(const Locale('ja'));
                            });
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),

          // Colors
          ListTile(
            title: const Text('Colors'),
            subtitle: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: _selectedColor,
                shape: BoxShape.circle,
              ),
            ),
            onTap: () {
              // 色選択のBottom Sheetを表示
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: GridView.count(
                      crossAxisCount: 4,
                      children: [
                        _colorOption(Colors.blue),
                        _colorOption(Colors.red),
                        _colorOption(Colors.green),
                        _colorOption(Colors.orange),
                        _colorOption(Colors.purple),
                        _colorOption(Colors.brown),
                        _colorOption(Colors.teal),
                        _colorOption(Colors.pink),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // カラー選択用のヘルパーメソッド
  Widget _colorOption(Color color) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedColor = color;
        });
        Navigator.of(context).pop();
      },
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}
