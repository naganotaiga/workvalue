/// WorkValue - ウィジェットテスト
/// アプリのウィジェットと機能をテストする

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:workvalue/main.dart';
import 'package:workvalue/providers/worker_provider.dart';
import 'package:workvalue/providers/settings_provider.dart';

void main() {
  testWidgets('WorkValue app smoke test', (WidgetTester tester) async {
    // WorkValueAppをビルド
    await tester.pumpWidget(const WorkValueApp());

    // アプリが正常に起動することを確認
    expect(find.byType(MaterialApp), findsOneWidget);
    
    // 基本的なUIコンポーネントが存在することを確認
    await tester.pumpAndSettle();
    
    // テストが完了
  });

  testWidgets('Provider initialization test', (WidgetTester tester) async {
    // プロバイダーが正しく初期化されることをテスト
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => SettingsProvider()),
          ChangeNotifierProvider(create: (context) => WorkerProvider()),
        ],
        child: MaterialApp(
          home: Consumer<WorkerProvider>(
            builder: (context, provider, child) {
              return Scaffold(
                body: Text('Worker Provider: ${provider.isWorking}'),
              );
            },
          ),
        ),
      ),
    );

    // プロバイダーが正常に機能することを確認
    await tester.pumpAndSettle();
    expect(find.text('Worker Provider: false'), findsOneWidget);
  });
}