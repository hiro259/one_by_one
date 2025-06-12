import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:one_by_one/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:reorderables/reorderables.dart';

// 設定用モデル
class AppSettings extends ChangeNotifier {
  Locale locale;
  Color seedColor;
  bool isDark;

  AppSettings({
    required this.locale,
    required this.seedColor,
    required this.isDark,
  });

  void updateLocale(Locale newLocale) {
    locale = newLocale;
    notifyListeners();
  }

  void updateSeedColor(Color newColor) {
    seedColor = newColor;
    notifyListeners();
  }

  void updateBritness(bool value) {
    isDark = value;
    notifyListeners();
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create:
          (_) => AppSettings(
            locale: const Locale('en'),
            seedColor: Colors.blue,
            isDark: false,
          ),
      child: const OneByOneApp(),
    ),
  );
}

// グローバルなタスクリポジトリ（MVP用：In-Memory実装）
final TaskRepository taskRepository = TaskRepository();

class OneByOneApp extends StatefulWidget {
  const OneByOneApp({Key? key}) : super(key: key);

  @override
  State<OneByOneApp> createState() => _OneByOneAppState();
}

class _OneByOneAppState extends State<OneByOneApp> {
  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettings>(context);
    return MaterialApp(
      title: 'One by one',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: settings.seedColor,
          brightness: settings.isDark ? Brightness.dark : Brightness.light,
        ),
      ),
      locale: settings.locale, // 現在のLocaleを指定
      localizationsDelegates: [
        AppLocalizations.delegate, // これを追加！
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      // home: OneByOneHomePage(),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<int> _items = List.generate(10, (index) => index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () {
            // Handle menu button press
          },
        ),
        title: const Text(
          'One by one',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () {
              // Handle settings button press
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => SettingsScreen()));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              // children: const [
              //   Text('Card 01', style: TextStyle(fontWeight: FontWeight.bold)),
              //   Text('Card 02', style: TextStyle(fontWeight: FontWeight.bold)),
              //   Text('Card 03', style: TextStyle(fontWeight: FontWeight.bold)),
              // ],
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: SingleChildScrollView(
                child: ReorderableWrap(
                  spacing: 10,
                  runSpacing: 10,
                  maxMainAxisCount: 3,
                  needsLongPressDraggable: false,
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      final item = _items.removeAt(oldIndex);
                      _items.insert(newIndex, item);
                    });
                  },
                  children: [
                    for (int i = 0; i < _items.length; i++)
                      AspectRatio(
                        key: ValueKey(_items[i]),
                        aspectRatio: 1,
                        child: CardWidget(
                          title: 'Title',
                          updatedText: _getUpdatedText(i),
                          showCloseButton: true,
                          onClose: () {
                            setState(() {
                              _items.removeAt(i);
                            });
                          },
                        ),
                      ),
                    const AspectRatio(
                      aspectRatio: 1,
                      child: AddCardWidget(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getUpdatedText(int index) {
    // This logic mimics the image's "Updated today", "Updated yesterday", "Updated 2 days ago" pattern
    final int column = index % 3;
    if (column == 0) {
      return 'Updated today';
    } else if (column == 1) {
      return 'Updated yesterday';
    } else {
      return 'Updated 2 days ago';
    }
  }
}

class CardWidget extends StatelessWidget {
  final String title;
  final String updatedText;
  final bool showCloseButton;
  final VoidCallback? onClose;

  const CardWidget({
    super.key,
    required this.title,
    required this.updatedText,
    this.showCloseButton = true,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      color: Colors.grey[200], // Light grey background for cards
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topRight,
              child:
                  showCloseButton
                      ? Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          iconSize: 18,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: onClose,
                        ),
                      )
                      : const SizedBox.shrink(),
            ),
            const SizedBox(
              height: 8,
            ), // Spacing between close button and image placeholders
            // Placeholder for the image/icons as shown in the screenshot
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.category, size: 30, color: Colors.grey[600]),
                        const SizedBox(width: 10),
                        Icon(Icons.ac_unit, size: 30, color: Colors.grey[600]),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Icon(Icons.square, size: 30, color: Colors.grey[600]),
                  ],
                ),
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              updatedText,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class AddCardWidget extends StatelessWidget {
  const AddCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
        side: BorderSide(
          color: Colors.grey[400]!,
          width: 1.5,
        ), // Dotted border effect
      ),
      color: Colors.transparent, // Transparent background
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue[100], // Light blue background for the plus icon
          ),
          child: IconButton(
            icon: const Icon(Icons.add, color: Colors.blue, size: 30),
            onPressed: () {
              // Handle add button press
            },
          ),
        ),
      ),
    );
  }
}

//タスクのリスト
class OneByOneHomePage extends StatefulWidget {
  // onLocaleChange を必須パラメータに指定するため、const は削除（実行時に変わる値が渡されるため）
  const OneByOneHomePage({Key? key}) : super(key: key);

  @override
  State<OneByOneHomePage> createState() => _OneByOneHomePageState();
}

class _OneByOneHomePageState extends State<OneByOneHomePage> {
  late List<Task> _tasks;

  @override
  void initState() {
    super.initState();
    _tasks = List.from(taskRepository.getTasks());
  }

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
                PopupMenuItem(value: 'checkAll', child: Text(loc.checkAll)),
                PopupMenuItem(value: 'uncheckAll', child: Text(loc.uncheckAll)),
              ],
        ),

        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // 設定画面へ遷移
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => SettingsScreen()));
            },
          ),
        ],
      ),
      body: ReorderableListView(
        onReorder: _onReorder, // ← このあと定義する関数
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          for (final task in _tasks)
            Card(key: ValueKey(task.id), child: _buildListItem(task)),
        ],
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
            setState(() {
              _tasks.add(newTask);
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      taskRepository.reorderTasks(oldIndex, newIndex);
      _tasks = List.from(taskRepository.getTasks()); // 表示を更新
    });
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

  void reorderTasks(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final moved = _tasks.removeAt(oldIndex);
    _tasks.insert(newIndex, moved);
  }
}

// 1. SettingsScreenをStatefulWidgetに変更し、言語・色の選択を管理
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // 簡易的に英語・日本語のみ
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettings>(context);

    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // Languages
          ListTile(
            title: Text(loc.languages),
            subtitle: Text(_selectedLanguage),
            onTap: () {
              // 言語選択のダイアログを表示
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text(loc.languages),
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
                              settings.updateLocale(const Locale('en'));
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

                              settings.updateLocale(const Locale('ja'));
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
          //brigness
          ListTile(
            title: Text(loc.brigness),
            trailing: Switch(
              value: settings.isDark,
              onChanged: (bool value) {
                settings.updateBritness(value);
              },
            ),
          ),
          // Colors
          ListTile(
            title: Text(loc.colors),
            subtitle: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: settings.seedColor,
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
                        _colorOption(Colors.blue, settings),
                        _colorOption(Colors.red, settings),
                        _colorOption(Colors.green, settings),
                        _colorOption(Colors.orange, settings),
                        _colorOption(Colors.deepPurple, settings),
                        _colorOption(Colors.brown, settings),
                        _colorOption(Colors.teal, settings),
                        _colorOption(Colors.pink, settings),
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
  Widget _colorOption(Color color, AppSettings settings) {
    return InkWell(
      onTap: () {
        setState(() {
          settings.updateSeedColor(color);
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
