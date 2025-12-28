// BIP39恢复工具错误处理和边界情况测试
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bip39_recovery_flutter/main.dart';

// 辅助函数：导航到恢复页面
Future<void> _navigateToRecoveryPage(WidgetTester tester) async {
  await tester.tap(find.text('开始恢复 / Start Recovery'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('1024模式'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('12个单词'));
  await tester.pumpAndSettle();
}

void main() {
  group('BIP39错误处理和边界情况测试', () {
    testWidgets('无效输入数字错误处理', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // 进入恢复页面
      await _navigateToRecoveryPage(tester);

      // 测试非2的幂数字输入
      await tester.enterText(find.byType(TextField), '3');
      await tester.tap(find.text('添加数字'));
      await tester.pumpAndSettle();

      // 验证错误消息显示
      expect(find.textContaining('请输入一个有效的2的幂'), findsOneWidget);

      // 测试其他无效数字
      for (final invalidNumber in [0, -1, 5, 6, 7, 10, 100, 1000]) {
        await tester.enterText(find.byType(TextField), invalidNumber.toString());
        await tester.tap(find.text('添加数字'));
        await tester.pumpAndSettle();
        expect(find.textContaining('请输入一个有效的2的幂'), findsOneWidget);
      }
    });

    testWidgets('重复输入错误处理', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // 进入恢复页面
      await _navigateToRecoveryPage(tester);

      // 添加第一个数字
      await tester.enterText(find.byType(TextField), '2');
      await tester.tap(find.text('添加数字'));
      await tester.pumpAndSettle();

      // 尝试添加相同的数字
      await tester.enterText(find.byType(TextField), '2');
      await tester.tap(find.text('添加数字'));
      await tester.pumpAndSettle();

      // 验证重复警告
      expect(find.textContaining('数字 2 已经为这个单词添加过了'), findsOneWidget);
    });

    testWidgets('数字1重复限制测试', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // 进入恢复页面
      await _navigateToRecoveryPage(tester);

      // 添加数字1第一次
      await tester.enterText(find.byType(TextField), '1');
      await tester.tap(find.text('添加数字'));
      await tester.pumpAndSettle();

      // 添加数字1第二次（应该允许）
      await tester.enterText(find.byType(TextField), '1');
      await tester.tap(find.text('添加数字'));
      await tester.pumpAndSettle();

      // 添加数字1第三次（应该被拒绝）
      await tester.enterText(find.byType(TextField), '1');
      await tester.tap(find.text('添加数字'));
      await tester.pumpAndSettle();

      // 验证数字1最多重复两次的错误消息
      expect(find.textContaining('数字1最多只能重复两次'), findsOneWidget);
    });

    testWidgets('空输入确认错误处理', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // 进入恢复页面
      await _navigateToRecoveryPage(tester);

      // 不添加任何数字直接确认
      await tester.tap(find.text('确认单词并继续'));
      await tester.pumpAndSettle();

      // 验证空输入警告
      expect(find.textContaining('请至少为这个单词添加一个数字'), findsOneWidget);
    });

    testWidgets('撤销功能边界测试', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // 进入恢复页面
      await _navigateToRecoveryPage(tester);

      // 在没有输入的情况下尝试撤销
      await tester.tap(find.text('撤销上一个'));
      await tester.pumpAndSettle();

      // 验证没有可撤销内容的提示
      expect(find.textContaining('没有可撤销的输入'), findsOneWidget);

      // 添加一个数字然后撤销
      await tester.enterText(find.byType(TextField), '128');
      await tester.tap(find.text('添加数字'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('撤销上一个'));
      await tester.pumpAndSettle();

      // 验证撤销成功（应该回到等待状态）
      expect(find.textContaining('(等待输入)'), findsOneWidget);
    });

    testWidgets('回退单词功能测试', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // 进入恢复页面
      await _navigateToRecoveryPage(tester);

      // 在第一个单词上尝试回退（应该无效）
      await tester.tap(find.text('回退上一个单词'));
      await tester.pumpAndSettle();

      // 添加一个数字并确认一个单词
      await tester.enterText(find.byType(TextField), '128');
      await tester.tap(find.text('添加数字'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('确认单词并继续'));
      await tester.pumpAndSettle();

      // 现在可以回退到上一个单词
      await tester.tap(find.text('回退上一个单词'));
      await tester.pumpAndSettle();

      // 验证回退成功的提示
      expect(find.textContaining('已回退到第'), findsOneWidget);
    });

    testWidgets('清空当前输入测试', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // 进入恢复页面
      await _navigateToRecoveryPage(tester);

      // 添加多个数字
      await tester.enterText(find.byType(TextField), '128');
      await tester.tap(find.text('添加数字'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '64');
      await tester.tap(find.text('添加数字'));
      await tester.pumpAndSettle();

      // 清空当前输入
      await tester.tap(find.text('清空当前'));
      await tester.pumpAndSettle();

      // 验证输入已清空，回到等待状态
      expect(find.textContaining('(等待输入)'), findsOneWidget);
    });

    testWidgets('输入框键盘类型测试', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // 进入恢复页面
      await _navigateToRecoveryPage(tester);

      // 验证输入框是数字键盘
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.keyboardType, TextInputType.number);
    });

    testWidgets('长文本输入测试', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // 进入恢复页面
      await _navigateToRecoveryPage(tester);

      // 输入很长的数字
      await tester.enterText(find.byType(TextField), '999999999999999999');
      await tester.tap(find.text('添加数字'));
      await tester.pumpAndSettle();

      // 应该显示无效输入错误
      expect(find.textContaining('请输入一个有效的2的幂'), findsOneWidget);
    });

    testWidgets('特殊字符输入测试', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // 进入恢复页面
      await _navigateToRecoveryPage(tester);

      // 输入非数字字符
      await tester.enterText(find.byType(TextField), 'abc');
      await tester.tap(find.text('添加数字'));
      await tester.pumpAndSettle();

      // 应该显示整数警告
      expect(find.textContaining('请输入一个有效的整数'), findsOneWidget);
    });

    testWidgets('2048模式边界测试', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // 进入恢复页面并选择2048模式
      await tester.tap(find.text('开始恢复 / Start Recovery'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('2048模式'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('12个单词'));
      await tester.pumpAndSettle();

      // 验证2048模式可以输入2048
      await tester.enterText(find.byType(TextField), '2048');
      await tester.tap(find.text('添加数字'));
      await tester.pumpAndSettle();

      // 验证2048模式标识
      expect(find.textContaining('2048 (2048模式)'), findsOneWidget);
    });

    testWidgets('大量输入累积测试', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // 进入恢复页面
      await _navigateToRecoveryPage(tester);

      // 添加多个数字测试累积
      final testNumbers = [512, 256, 128, 64, 32, 16, 8, 4, 2, 1];
      int expectedSum = 0;

      for (final number in testNumbers) {
        await tester.enterText(find.byType(TextField), number.toString());
        await tester.tap(find.text('添加数字'));
        await tester.pumpAndSettle();
        expectedSum += number;

        // 验证数字列表更新
        expect(find.textContaining(number.toString()), findsOneWidget);
      }

      // 验证总和计算正确
      expect(find.textContaining(expectedSum.toString()), findsAtLeastNWidgets(1));
    });

    testWidgets('导航边界测试', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // 测试页面导航的边界情况
      // 从欢迎页面可以前进到模式选择
      await tester.tap(find.text('开始恢复 / Start Recovery'));
      await tester.pumpAndSettle();
      expect(find.text('请选择恢复模式：'), findsOneWidget);

      // 从模式选择可以返回欢迎页面
      await tester.tap(find.text('返回 / Back'));
      await tester.pumpAndSettle();
      expect(find.text('BIP39 助记词恢复'), findsOneWidget);

      // 再次进入，选择模式
      await tester.tap(find.text('开始恢复 / Start Recovery'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('1024模式'));
      await tester.pumpAndSettle();

      // 从长度选择可以返回模式选择
      await tester.tap(find.text('返回 / Back'));
      await tester.pumpAndSettle();
      expect(find.text('请选择恢复模式：'), findsOneWidget);
    });
  });
}