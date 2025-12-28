// BIP39恢复工具的端到端测试
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:bip39_recovery_flutter/main.dart' as app;
import 'test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('BIP39恢复工具端到端测试', () {
    testWidgets('完整恢复流程测试 - 1024模式12个单词', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 验证欢迎页面
      expect(find.text('BIP39 助记词恢复'), findsOneWidget);
      expect(find.text('本工具为100%离线工具，绝不发送任何数据。'), findsOneWidget);

      // 点击开始恢复
      await tester.tap(find.text('开始恢复 / Start Recovery'));
      await tester.pumpAndSettle();

      // 验证模式选择页面
      expect(find.text('请选择恢复模式：'), findsOneWidget);
      expect(find.text('1024模式'), findsOneWidget);
      expect(find.text('2048模式'), findsOneWidget);

      // 选择1024模式
      await tester.tap(find.text('1024模式'));
      await tester.pumpAndSettle();

      // 验证长度选择页面
      expect(find.text('请选择您的助记词短语长度：'), findsOneWidget);
      expect(find.text('12个单词'), findsOneWidget);
      expect(find.text('18个单词'), findsOneWidget);
      expect(find.text('24个单词'), findsOneWidget);

      // 选择12个单词
      await tester.tap(find.text('12个单词'));
      await tester.pumpAndSettle();

      // 验证恢复页面
      expect(find.text('正在恢复第 1 / 12 个单词'), findsOneWidget);
      expect(find.text('输入数字 (例如 2, 4, 256):'), findsOneWidget);
      expect(find.text('添加数字'), findsOneWidget);

      // 测试输入数字并验证
      await tester.enterText(find.byType(TextField), '256');
      await tester.tap(find.text('添加数字'));
      await tester.pumpAndSettle();

      // 验证数字已添加
      expect(find.text('已输入的数字: 256'), findsOneWidget);

      // 确认单词并继续
      await tester.tap(find.text('确认单词并继续'));
      await tester.pumpAndSettle();

      // 验证进入下一个单词
      expect(find.text('正在恢复第 2 / 12 个单词'), findsOneWidget);
      expect(find.text('已恢复的单词:'), findsOneWidget);

      // 重复几个单词的恢复过程
      for (int i = 0; i < 3; i++) {
        await tester.enterText(find.byType(TextField), '128');
        await tester.tap(find.text('添加数字'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('确认单词并继续'));
        await tester.pumpAndSettle();
      }

      // 验证助记词列表更新
      final recoveredWordsList = find.byType(ListView);
      expect(recoveredWordsList, findsOneWidget);

      // 测试撤销功能
      await tester.tap(find.text('撤销上一个'));
      await tester.pumpAndSettle();

      // 验证撤销结果
      expect(find.textContaining('已回退到第'), findsOneWidget);
    });

    testWidgets('2048模式测试', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 开始恢复流程
      await tester.tap(find.text('开始恢复 / Start Recovery'));
      await tester.pumpAndSettle();

      // 选择2048模式
      await tester.tap(find.text('2048模式'));
      await tester.pumpAndSettle();

      // 选择12个单词
      await tester.tap(find.text('12个单词'));
      await tester.pumpAndSettle();

      // 验证2048模式可用（应该可以输入2048）
      await tester.enterText(find.byType(TextField), '2048');
      await tester.tap(find.text('添加数字'));
      await tester.pumpAndSettle();

      expect(find.text('已输入的数字: 2048 (2048模式)'), findsOneWidget);
    });

    testWidgets('语言切换测试', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 找到语言切换按钮并点击中文
      final chineseButton = find.text('中文');
      final englishButton = find.text('English');

      // 默认应该是中文，检查中文文本
      expect(find.text('BIP39 助记词恢复'), findsOneWidget);

      // 切换到英文
      await tester.tap(englishButton);
      await tester.pumpAndSettle();

      // 验证英文文本
      expect(find.text('BIP39 Mnemonic Recovery'), findsOneWidget);
      expect(find.text('Please select the recovery mode:'), findsOneWidget);

      // 切换回中文
      await tester.tap(chineseButton);
      await tester.pumpAndSettle();

      // 验证中文文本
      expect(find.text('BIP39 助记词恢复'), findsOneWidget);
    });

    testWidgets('错误处理测试', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 开始恢复流程
      await tester.tap(find.text('开始恢复 / Start Recovery'));
      await tester.pumpAndSettle();

      // 选择1024模式
      await tester.tap(find.text('1024模式'));
      await tester.pumpAndSettle();

      // 选择12个单词
      await tester.tap(find.text('12个单词'));
      await tester.pumpAndSettle();

      // 测试无效输入（非2的幂）
      await tester.enterText(find.byType(TextField), '3');
      await tester.tap(find.text('添加数字'));
      await tester.pumpAndSettle();

      // 验证错误消息
      expect(find.textContaining('请输入一个有效的2的幂'), findsOneWidget);

      // 测试重复输入
      await tester.enterText(find.byType(TextField), '2');
      await tester.tap(find.text('添加数字'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '2');
      await tester.tap(find.text('添加数字'));
      await tester.pumpAndSettle();

      // 验证重复警告
      expect(find.textContaining('数字 2 已经为这个单词添加过了'), findsOneWidget);
    });

    testWidgets('完整12单词恢复流程', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 开始恢复流程
      await tester.tap(find.text('开始恢复 / Start Recovery'));
      await tester.pumpAndSettle();

      // 选择1024模式
      await tester.tap(find.text('1024模式'));
      await tester.pumpAndSettle();

      // 选择12个单词
      await tester.tap(find.text('12个单词'));
      await tester.pumpAndSettle();

      // 使用测试助手快速恢复12个单词
      await TestHelpers.recoverAllWords(tester, wordCount: 12);
      await tester.pumpAndSettle();

      // 验证最终结果页面
      expect(find.text('恢复成功！'), findsOneWidget);
      expect(find.text('您恢复的BIP39助记词短语是：'), findsOneWidget);

      // 验证显示的助记词数量
      final resultList = find.byType(ListView);
      expect(resultList, findsOneWidget);
    });
  });
}