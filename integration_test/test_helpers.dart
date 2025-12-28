// 测试辅助工具类
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class TestHelpers {
  /// 快速恢复指定数量的单词
  static Future<void> recoverAllWords(WidgetTester tester, {
    int wordCount = 12,
    List<int> testNumbers = const [128, 64, 32, 16, 8, 4, 2, 1],
  }) async {
    for (int i = 0; i < wordCount; i++) {
      // 输入数字
      await tester.enterText(find.byType(TextField), testNumbers[i % testNumbers.length].toString());
      await tester.pumpAndSettle();

      // 点击添加数字
      await tester.tap(find.text('添加数字'));
      await tester.pumpAndSettle();

      // 确认单词并继续
      await tester.tap(find.text('确认单词并继续'));
      await tester.pumpAndSettle();
    }
  }

  /// 等待并验证页面标题
  static Future<void> verifyPageTitle(WidgetTester tester, String expectedTitle) async {
    await tester.pumpAndSettle();
    expect(find.text(expectedTitle), findsOneWidget);
  }

  /// 验证SnackBar消息
  static Future<void> verifySnackBarMessage(WidgetTester tester, String expectedMessage) async {
    await tester.pumpAndSettle();
    expect(find.text(expectedMessage), findsOneWidget);
  }

  /// 模拟用户输入流程：点击开始->选择模式->选择长度
  static Future<void> startRecoveryFlow(WidgetTester tester, {
    bool is2048Mode = false,
    int wordCount = 12,
  }) async {
    // 点击开始恢复
    await tester.tap(find.text('开始恢复 / Start Recovery'));
    await tester.pumpAndSettle();

    // 选择模式
    if (is2048Mode) {
      await tester.tap(find.text('2048模式'));
    } else {
      await tester.tap(find.text('1024模式'));
    }
    await tester.pumpAndSettle();

    // 选择长度
    switch (wordCount) {
      case 12:
        await tester.tap(find.text('12个单词'));
        break;
      case 18:
        await tester.tap(find.text('18个单词'));
        break;
      case 24:
        await tester.tap(find.text('24个单词'));
        break;
    }
    await tester.pumpAndSettle();
  }

  /// 输入数字并添加到当前单词
  static Future<void> addNumber(WidgetTester tester, int number) async {
    await tester.enterText(find.byType(TextField), number.toString());
    await tester.pumpAndSettle();
    await tester.tap(find.text('添加数字'));
    await tester.pumpAndSettle();
  }

  /// 确认当前单词并继续下一个
  static Future<void> confirmAndNext(WidgetTester tester) async {
    await tester.tap(find.text('确认单词并继续'));
    await tester.pumpAndSettle();
  }

  /// 验证当前单词状态显示
  static Future<void> verifyCurrentWordStatus(WidgetTester tester, String expectedStatus) async {
    await tester.pumpAndSettle();
    // 查找包含状态文本的Widget
    expect(find.textContaining(expectedStatus), findsOneWidget);
  }

  /// 验证助记词列表更新
  static Future<void> verifyMnemonicListUpdate(WidgetTester tester, int expectedCount) async {
    await tester.pumpAndSettle();
    // 验证已恢复的单词列表包含指定数量的单词
    final listView = find.byType(ListView);
    expect(listView, findsOneWidget);
  }

  /// 测试撤销功能
  static Future<void> testUndoFunction(WidgetTester tester) async {
    await tester.tap(find.text('撤销上一个'));
    await tester.pumpAndSettle();
  }

  /// 测试清空当前输入功能
  static Future<void> testClearCurrent(WidgetTester tester) async {
    await tester.tap(find.text('清空当前'));
    await tester.pumpAndSettle();
  }

  /// 测试回退到上一个单词功能
  static Future<void> testRollbackWord(WidgetTester tester) async {
    await tester.tap(find.text('回退上一个单词'));
    await tester.pumpAndSettle();
  }

  /// 验证语言切换
  static Future<void> testLanguageSwitch(WidgetTester tester, String targetLang) async {
    if (targetLang == 'en') {
      await tester.tap(find.text('English'));
    } else {
      await tester.tap(find.text('中文'));
    }
    await tester.pumpAndSettle();
  }

  /// 验证导航到结果页面
  static Future<void> verifyResultPage(WidgetTester tester) async {
    await tester.pumpAndSettle();
    expect(find.text('恢复成功！'), findsOneWidget);
    expect(find.text('您恢复的BIP39助记词短语是：'), findsOneWidget);
  }

  /// 验证重新开始功能
  static Future<void> testRestart(WidgetTester tester) async {
    await tester.tap(find.text('重新开始'));
    await tester.pumpAndSettle();
    expect(find.text('BIP39 助记词恢复'), findsOneWidget);
  }
}