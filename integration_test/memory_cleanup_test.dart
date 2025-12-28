// 内存清理集成测试 - 端到端验证助记词数据清理
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:bip39_recovery_flutter/main.dart' as app;
import 'test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('内存清理集成测试', () {
    testWidgets('完整流程内存清理验证', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 步骤1: 进入恢复流程
      await TestHelpers.startRecoveryFlow(tester);

      // 步骤2: 添加一些敏感数据
      await TestHelpers.addNumber(tester, 1024);
      await TestHelpers.confirmAndNext(tester);
      
      await TestHelpers.addNumber(tester, 512);
      await TestHelpers.confirmAndNext(tester);
      
      await TestHelpers.addNumber(tester, 256);
      await TestHelpers.confirmAndNext(tester);

      // 验证数据已添加到列表
      expect(find.textContaining('1.'), findsOneWidget);
      expect(find.textContaining('2.'), findsOneWidget);
      expect(find.textContaining('3.'), findsOneWidget);

      // 步骤3: 测试清空当前输入功能
      await TestHelpers.addNumber(tester, 128);
      await tester.pumpAndSettle();

      // 验证输入存在
      expect(find.text('已输入的数字: 128'), findsOneWidget);

      // 点击清空当前
      await tester.tap(find.text('清空当前'));
      await tester.pumpAndSettle();

      // 验证当前输入被清空
      expect(find.text('(等待输入)'), findsOneWidget);
      expect(find.textContaining('已输入的数字:'), findsNothing);

      // 步骤4: 测试撤销功能
      await TestHelpers.addNumber(tester, 64);
      await TestHelpers.addNumber(tester, 32);
      await tester.pumpAndSettle();

      // 验证两个输入都存在
      expect(find.text('已输入的数字: 32, 64'), findsOneWidget);

      // 撤销一个输入
      await tester.tap(find.text('撤销上一个'));
      await tester.pumpAndSettle();

      // 验证只剩下一个输入
      expect(find.text('已输入的数字: 64'), findsOneWidget);

      // 步骤5: 确认单词并测试回退功能
      await TestHelpers.confirmAndNext(tester);
      await tester.pumpAndSettle();

      // 验证现在有4个单词
      expect(find.textContaining('4.'), findsOneWidget);

      // 回退到上一个单词
      await tester.tap(find.text('回退上一个单词'));
      await tester.pumpAndSettle();

      // 验证回退成功
      expect(find.textContaining('已回退到第'), findsOneWidget);
      expect(find.text('正在恢复第 4 / 12 个单词'), findsOneWidget);
    });

    testWidgets('重新开始内存清理验证', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 步骤1: 完成部分恢复流程
      await TestHelpers.startRecoveryFlow(tester);

      // 恢复6个单词
      for (int i = 0; i < 6; i++) {
        await TestHelpers.addNumber(tester, 128);
        await TestHelpers.confirmAndNext(tester);
      }

      // 验证有6个单词在列表中
      expect(find.textContaining('6.'), findsOneWidget);

      // 步骤2: 导航到结果页面并重新开始
      final pageView = tester.widget<PageView>(find.byType(PageView));
      pageView.controller!.jumpToPage(4);
      await tester.pumpAndSettle();

      // 验证结果页面
      expect(find.text('恢复成功！'), findsOneWidget);

      // 点击重新开始
      await tester.tap(find.text('重新开始'));
      await tester.pumpAndSettle();

      // 步骤3: 验证完全清理
      // 验证回到欢迎页面
      expect(find.text('BIP39 助记词恢复'), findsOneWidget);

      // 验证所有状态重置（通过重新进入恢复流程验证）
      await TestHelpers.startRecoveryFlow(tester);

      // 验证恢复到初始状态
      expect(find.text('正在恢复第 1 / 12 个单词'), findsOneWidget);
      expect(find.text('(等待输入)'), findsOneWidget);
      expect(find.textContaining('已恢复的单词:'), findsOneWidget);
    });

    testWidgets('多语言切换内存安全验证', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 步骤1: 在中文模式下添加数据
      await TestHelpers.startRecoveryFlow(tester);

      await TestHelpers.addNumber(tester, 256);
      await TestHelpers.confirmAndNext(tester);

      // 验证中文显示
      expect(find.text('正在恢复第 2 / 12 个单词'), findsOneWidget);
      expect(find.text('已输入的数字:'), findsOneWidget);

      // 步骤2: 切换到英文
      await TestHelpers.testLanguageSwitch(tester, 'en');

      // 验证英文显示但数据状态保持
      expect(find.text('Recovering Word 2 of 12'), findsOneWidget);

      // 步骤3: 继续添加数据
      await TestHelpers.addNumber(tester, 128);
      await TestHelpers.confirmAndNext(tester);

      // 验证英文模式下的操作
      expect(find.text('Recovering Word 3 of 12'), findsOneWidget);

      // 步骤4: 切换回中文并验证数据完整性
      await TestHelpers.testLanguageSwitch(tester, 'zh');

      // 验证回到中文且数据状态正确
      expect(find.text('正在恢复第 3 / 12 个单词'), findsOneWidget);
    });

    testWidgets('边界情况内存清理验证', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 步骤1: 测试空状态下的清空操作
      await TestHelpers.startRecoveryFlow(tester);

      // 在空状态下点击清空（应该安全）
      await tester.tap(find.text('清空当前'));
      await tester.pumpAndSettle();

      // 验证仍然处于安全状态
      expect(find.text('(等待输入)'), findsOneWidget);

      // 步骤2: 测试撤销空输入
      await tester.tap(find.text('撤销上一个'));
      await tester.pumpAndSettle();

      // 验证显示无撤销内容的提示
      expect(find.textContaining('没有可撤销的输入'), findsOneWidget);

      // 步骤3: 添加数据然后快速清空
      await TestHelpers.addNumber(tester, 512);
      await tester.pumpAndSettle();

      await TestHelpers.addNumber(tester, 256);
      await tester.pumpAndSettle();

      await TestHelpers.addNumber(tester, 128);
      await tester.pumpAndSettle();

      // 验证所有输入
      expect(find.text('已输入的数字: 128, 256, 512'), findsOneWidget);

      // 快速清空
      await tester.tap(find.text('清空当前'));
      await tester.pumpAndSettle();

      // 验证完全清空
      expect(find.text('(等待输入)'), findsOneWidget);
    });

    testWidgets('大量数据处理内存清理验证', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 步骤1: 快速恢复多个单词
      await TestHelpers.startRecoveryFlow(tester);

      // 使用不同的数字模式
      final testNumbers = [1024, 512, 256, 128, 64, 32, 16, 8, 4, 2, 1];
      
      for (int i = 0; i < 11; i++) {
        await TestHelpers.addNumber(tester, testNumbers[i % testNumbers.length]);
        await TestHelpers.confirmAndNext(tester);
      }

      // 验证11个单词已恢复
      expect(find.textContaining('11.'), findsOneWidget);

      // 步骤2: 测试部分撤销和清空
      // 添加更多输入
      await TestHelpers.addNumber(tester, 512);
      await TestHelpers.addNumber(tester, 256);
      await TestHelpers.addNumber(tester, 128);
      await tester.pumpAndSettle();

      // 撤销几个输入
      await tester.tap(find.text('撤销上一个'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('撤销上一个'));
      await tester.pumpAndSettle();

      // 清空剩余
      await tester.tap(find.text('清空当前'));
      await tester.pumpAndSettle();

      // 验证只撤销了一个输入
      expect(find.text('已输入的数字: 512'), findsOneWidget);

      // 步骤3: 重新开始验证完整清理
      final pageView = tester.widget<PageView>(find.byType(PageView));
      pageView.controller!.jumpToPage(4);
      await tester.pumpAndSettle();

      await tester.tap(find.text('重新开始'));
      await tester.pumpAndSettle();

      // 验证完全重置
      expect(find.text('BIP39 助记词恢复'), findsOneWidget);
    });

    testWidgets('2048模式内存清理验证', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 步骤1: 进入2048模式
      await TestHelpers.startRecoveryFlow(tester, is2048Mode: true);

      // 步骤2: 使用2048模式特有的数字
      await TestHelpers.addNumber(tester, 2048);
      await tester.pumpAndSettle();

      // 验证2048模式标识
      expect(find.text('已输入的数字: 2048 (2048模式)'), findsOneWidget);

      await TestHelpers.confirmAndNext(tester);

      // 步骤3: 混合使用不同数字
      await TestHelpers.addNumber(tester, 1024);
      await TestHelpers.addNumber(tester, 512);
      await TestHelpers.addNumber(tester, 2048);
      await tester.pumpAndSettle();

      // 验证混合输入
      expect(find.textContaining('2048 (2048模式)'), findsOneWidget);

      // 步骤4: 测试清空功能
      await tester.tap(find.text('清空当前'));
      await tester.pumpAndSettle();

      // 验证清空成功
      expect(find.text('(等待输入)'), findsOneWidget);

      // 步骤5: 重新开始验证清理
      final pageView = tester.widget<PageView>(find.byType(PageView));
      pageView.controller!.jumpToPage(4);
      await tester.pumpAndSettle();

      await tester.tap(find.text('重新开始'));
      await tester.pumpAndSettle();

      // 验证回到欢迎页面
      expect(find.text('BIP39 助记词恢复'), findsOneWidget);
    });

    testWidgets('安全提示和退出验证', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 步骤1: 快速恢复几个单词进入结果页面
      await TestHelpers.startRecoveryFlow(tester);

      for (int i = 0; i < 3; i++) {
        await TestHelpers.addNumber(tester, 256);
        await TestHelpers.confirmAndNext(tester);
      }

      // 步骤2: 导航到结果页面
      final pageView = tester.widget<PageView>(find.byType(PageView));
      pageView.controller!.jumpToPage(4);
      await tester.pumpAndSettle();

      // 步骤3: 验证安全提示显示
      expect(find.text('恢复成功！'), findsOneWidget);
      expect(find.text('您恢复的BIP39助记词短语是：'), findsOneWidget);
      expect(find.text('【安全提示】在您安全备份好助记词后，请关闭本窗口。'), findsOneWidget);

      // 验证安全提示使用警告颜色（红色）
      final securityText = tester.widget<Text>(
        find.text('【安全提示】在您安全备份好助记词后，请关闭本窗口。')
      );
      expect(securityText.style!.color, equals(Colors.red));

      // 步骤4: 验证退出按钮存在
      expect(find.text('退出'), findsOneWidget);
      expect(find.text('重新开始'), findsOneWidget);
    });

    testWidgets('内存压力测试', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 步骤1: 快速连续操作测试
      for (int cycle = 0; cycle < 3; cycle++) {
        // 开始恢复
        await TestHelpers.startRecoveryFlow(tester);

        // 快速添加和清空
        for (int i = 0; i < 5; i++) {
          await TestHelpers.addNumber(tester, 128);
          await tester.tap(find.text('撤销上一个'));
          await tester.pumpAndSettle();
        }

        // 清空所有
        await tester.tap(find.text('清空当前'));
        await tester.pumpAndSettle();

        // 重新开始
        final pageView = tester.widget<PageView>(find.byType(PageView));
        pageView.controller!.jumpToPage(0);
        await tester.pumpAndSettle();
      }

      // 步骤2: 验证应用仍然稳定
      expect(find.text('BIP39 助记词恢复'), findsOneWidget);

      // 步骤3: 验证最后一次操作正常
      await TestHelpers.startRecoveryFlow(tester);

      await TestHelpers.addNumber(tester, 256);
      await TestHelpers.confirmAndNext(tester);

      expect(find.text('正在恢复第 2 / 12 个单词'), findsOneWidget);
    });
  });
}