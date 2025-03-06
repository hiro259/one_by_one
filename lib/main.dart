import 'package:flutter/material.dart';

void main() {
  runApp(const OneByOneApp());
}

class OneByOneApp extends StatelessWidget {
  const OneByOneApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'One by one',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple, // お好みのベースカラーに変更可
        ),
      ),
      home: const OneByOneHomePage(),
    );
  }
}

class OneByOneHomePage extends StatefulWidget {
  const OneByOneHomePage({Key? key}) : super(key: key);

  @override
  State<OneByOneHomePage> createState() => _OneByOneHomePageState();
}

class _OneByOneHomePageState extends State<OneByOneHomePage> {
  // 例として3つのスイッチ状態を管理
  final List<bool> _switchValues = [false, true, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. AppBar
      appBar: AppBar(
        title: const Text('One by one'),
        leading: IconButton(
          icon: const Icon(Icons.menu), // ハンバーガーアイコン
          onPressed: () {
            // TODO: ドロワーを開く、もしくは何らかの処理
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings), // 歯車アイコン
            onPressed: () {
              // TODO: 設定画面へ遷移など
            },
          ),
        ],
      ),

      // 2. Body: ListViewで3つのListTileを表示
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        itemCount: 3,
        itemBuilder: (context, index) {
          return _buildListItem(index);
        },
      ),

      // 3. FAB（右下に＋ボタン）
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: 新規タスク追加など
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildListItem(int index) {
    return Card(
      // Material 3っぽい角丸や影を調整
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0.5, // M3では影を少なめにすることが多い
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: IconTap(),
        ),
        title: const Text('Header'),
        subtitle: const Text('Subhead'),
        trailing: Switch(
          value: _switchValues[index],
          onChanged: (bool value) {
            setState(() {
              _switchValues[index] = value;
            });
          },
        ),
      ),
    );
  }
}

// アイコン部分を別クラスとして定義
class IconTap extends StatelessWidget {
  const IconTap({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // アイコンをタップするとDialogを表示
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: const TaskEditDialogContent(),
            );
          },
        );
      },
      child: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(
          Icons.person,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    );
  }
}

// ダイアログの中身も別Widgetにすると管理しやすい
class TaskEditDialogContent extends StatelessWidget {
  const TaskEditDialogContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min, // コンテンツ量に合わせて高さ調整
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // タイトル
            Text('Task edit', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),

            // アイコン + "Icon"
            Row(
              children: [
                Icon(
                  Icons.person,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                const SizedBox(width: 8),
                Text('Icon', style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: 16),

            // Title 入力
            TextField(
              decoration: InputDecoration(
                labelText: 'Title',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    // タイトルクリア処理
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // SubTitle 入力
            TextField(
              decoration: InputDecoration(
                labelText: 'SubTitle',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    // サブタイトルクリア処理
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Delete Task / Save Task
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    // Delete Taskの処理
                    Navigator.of(context).pop();
                  },
                  child: const Text('Delete Task'),
                ),
                TextButton(
                  onPressed: () {
                    // Save Taskの処理
                    Navigator.of(context).pop();
                  },
                  child: const Text('Save Task'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
