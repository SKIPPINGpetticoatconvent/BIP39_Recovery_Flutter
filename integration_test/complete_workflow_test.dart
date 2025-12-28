// 完整的BIP39恢复工作流端到端测试
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:bip39_recovery_flutter/main.dart' as app;
import 'test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('完整工作流端到端测试', () {
    testWidgets('完整12单词恢复流程 - 1024模式', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 步骤1: 验证欢迎页面
      await TestHelpers.verifyPageTitle(tester, 'BIP39 助记词恢复');
      expect(find.text('本工具为100%离线工具，绝不发送任何数据。'), findsOneWidget);

      // 步骤2: 开始恢复流程
      await TestHelpers.startRecoveryFlow(tester, is2048Mode: false, wordCount: 12);

      // 步骤3: 验证进入恢复页面
      await TestHelpers.verifyPageTitle(tester, '正在恢复第 1 / 12 个单词');
      expect(find.text('输入数字 (例如 2, 4, 256):'), findsOneWidget);

      // 步骤4: 恢复所有12个单词
      await TestHelpers.recoverAllWords(tester, wordCount: 12);

      // 步骤5: 验证最终结果页面
      await TestHelpers.verifyResultPage(tester);

      // 步骤6: 验证助记词列表显示
      final resultList = find.byType(ListView);
      expect(resultList, findsOneWidget);

      // 步骤7: 测试重新开始功能
      await TestHelpers.testRestart(tester);
    });

    testWidgets('完整18单词恢复流程 - 2048模式', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 步骤1: 开始2048模式18单词恢复
      await TestHelpers.startRecoveryFlow(tester, is2048Mode: true, wordCount: 18);

      // 步骤2: 验证进入恢复页面
      await TestHelpers.verifyPageTitle(tester, '正在恢复第 1 / 18 个单词');

      // 步骤3: 使用2048模式特有的数字测试
      await TestHelpers.addNumber(tester, 2048);
      await tester.pumpAndSettle();
      expect(find.text('2048 (2048模式)'), findsOneWidget);

      await TestHelpers.confirmAndNext(tester);

      // 步骤4: 恢复剩余的17个单词
      for (int i = 0; i < 17; i++) {
        await TestHelpers.addNumber(tester, 128);
        await TestHelpers.confirmAndNext(tester);
      }

      // 步骤5: 验证最终结果页面
      await TestHelpers.verifyResultPage(tester);
    });

    testWidgets('完整24单词恢复流程', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 步骤1: 开始24单词恢复
      await TestHelpers.startRecoveryFlow(tester, wordCount: 24);

      // 步骤2: 验证页面标题
      await TestHelpers.verifyPageTitle(tester, '正在恢复第 1 / 24 个单词');

      // 步骤3: 快速恢复24个单词（使用不同的数字模式）
      final testNumbers = [1024, 512, 256, 128, 64, 32, 16, 8, 4, 2, 1];
      
      for (int i = 0; i < 24; i++) {
        final number = testNumbers[i % testNumbers.length];
        await TestHelpers.addNumber(tester, number);
        await TestHelpers.confirmAndNext(tester);
      }

      // 步骤4: 验证结果页面
      await TestHelpers.verifyResultPage(tester);
    });

    testWidgets('语言切换完整流程测试', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 步骤1: 验证默认中文
      await TestHelpers.verifyPageTitle(tester, 'BIP39 助记词恢复');

      // 步骤2: 切换到英文并验证
      await TestHelpers.testLanguageSwitch(tester, 'en');
      await TestHelpers.verifyPageTitle(tester, 'BIP39 Mnemonic Recovery');
      expect(find.text('Please select the recovery mode:'), findsOneWidget);

      // 步骤3: 在英文模式下开始恢复流程
      await tester.tap(find.text('Start Recovery'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('1024 Mode'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('12 Words'));
      await tester.pumpAndSettle();

      // 步骤4: 验证英文恢复页面
      expect(find.text('Recovering Word 1 of 12'), findsOneWidget);

      // 步骤5: 恢复几个单词
      await TestHelpers.addNumber(tester, 256);
      await TestHelpers.confirmAndNext(tester);

      await TestHelpers.addNumber(tester, 128);
      await TestHelpers.confirmAndNext(tester);

      await TestHelpers.addNumber(tester, 64);
      await TestHelpers.confirmAndNext(tester);

      // 步骤6: 切换回中文并验证
      await TestHelpers.testLanguageSwitch(tester, 'zh');
      await tester.pumpAndSettle();
      expect(find.text('BIP39 助记词恢复'), findsOneWidget);
    });

    testWidgets('操作功能完整测试', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 步骤1: 进入恢复页面
      await TestHelpers.startRecoveryFlow(tester);

      // 步骤2: 测试撤销功能
      await TestHelpers.addNumber(tester, 128);
      await tester.pumpAndSettle();

      await TestHelpers.testUndoFunction(tester);
      await tester.pumpAndSettle();

      // 验证撤销后回到等待状态
      expect(find.text('(等待输入)'), findsOneWidget);

      // 步骤3: 测试清空功能
      await TestHelpers.addNumber(tester, 256);
      await TestHelpers.addNumber(tester, 128);
      await tester.pumpAndSettle();

      await TestHelpers.testClearCurrent(tester);
      await tester.pumpAndSettle();

      // 验证清空后回到等待状态
      expect(find.text('(等待输入)'), findsOneWidget);

      // 步骤4: 测试回退单词功能
      await TestHelpers.addNumber(tester, 512);
      await TestHelpers.confirmAndNext(tester);
      await tester.pumpAndSettle();

      // 现在可以回退到上一个单词
      await TestHelpers.testRollbackWord(tester);
      await tester.pumpAndSettle();

      // 验证回退提示
      expect(find.textContaining('已回退到第'), findsOneWidget);
    });

    testWidgets('错误恢复流程测试', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 步骤1: 进入恢复页面
      await TestHelpers.startRecoveryFlow(tester);

      // 步骤2: 测试各种错误情况并恢复
      // 无效输入
      await TestHelpers.addNumber(tester, 3);
      await tester.pumpAndSettle();

      // 验证错误消息
      expect(find.textContaining('请输入一个有效的2的幂'), findsOneWidget);

      // 重复输入
      await TestHelpers.addNumber(tester, 2);
      await tester.pumpAndSettle();

      await TestHelpers.addNumber(tester, 2);
      await tester.pumpAndSettle();

      // 验证重复警告
      expect(find.textContaining('数字 2 已经为这个单词添加过了'), findsOneWidget);

      // 清空并重新开始
      await TestHelpers.testClearCurrent(tester);
      await tester.pumpAndSettle();

      // 步骤3: 继续正常流程
      await TestHelpers.addNumber(tester, 256);
      await TestHelpers.confirmAndNext(tester);

      await TestHelpers.addNumber(tester, 128);
      await TestHelpers.confirmAndNext(tester);

      // 步骤4: 验证恢复继续正常进行
      expect(find.text('正在恢复第 3 / 12 个单词'), findsOneWidget);
    });

    testWidgets('性能和稳定性测试', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 步骤1: 快速导航测试
      for (int i = 0; i < 5; i++) {
        await TestHelpers.startRecoveryFlow(tester);
        await tester.tap(find.text('返回 / Back'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('返回 / Back'));
        await tester.pumpAndSettle();
      }

      // 步骤2: 语言切换压力测试
      for (int i = 0; i < 10; i++) {
        await TestHelpers.testLanguageSwitch(tester, 'en');
        await TestHelpers.testLanguageSwitch(tester, 'zh');
      }

      // 步骤3: 验证应用仍然正常工作
      await TestHelpers.startRecoveryFlow(tester);

      // 快速恢复几个单词验证功能
      for (int i = 0; i < 3; i++) {
        await TestHelpers.addNumber(tester, 128);
        await TestHelpers.confirmAndNext(tester);
      }

      expect(find.text('正在恢复第 4 / 12 个单词'), findsOneWidget);
    });

    testWidgets('边界条件完整测试', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 步骤1: 2048模式边界测试
      await TestHelpers.startRecoveryFlow(tester, is2048Mode: true);

      // 输入最大有效数字2048
      await TestHelpers.addNumber(tester, 2048);
      await TestHelpers.confirmAndNext(tester);

      // 步骤2: 1024模式边界测试
      await tester.tap(find.text('返回 / Back'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('返回 / Back'));
      await tester.pumpAndSettle();

      await TestHelpers.startRecoveryFlow(tester, is2048Mode: false);

      // 输入最大有效数字1024
      await TestHelpers.addNumber(tester, 1024);
      await TestHelpers.confirmAndNext(tester);

      // 步骤3: 数字1重复限制测试
      await TestHelpers.addNumber(tester, 1);
      await TestHelpers.addNumber(tester, 1);
      await tester.pumpAndSettle();

      // 第三次应该被拒绝
      await TestHelpers.addNumber(tester, 1);
      await tester.pumpAndSettle();

      // 验证错误消息
      expect(find.textContaining('数字1最多只能重复两次'), findsOneWidget);
    });
  });
}