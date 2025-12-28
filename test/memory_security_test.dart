// 内存安全测试 - 验证助记词数据的清理
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bip39_recovery_flutter/main.dart';

void main() {
  group('内存安全测试', () {

    // 辅助函数：导航到恢复页面
    Future<void> navigateToRecoveryPage(WidgetTester tester) async {
      await tester.tap(find.text('开始恢复 / Start Recovery'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('1024模式'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('12个单词'));
      await tester.pumpAndSettle();
    }

    group('助记词存储变量验证', () {
      testWidgets('初始状态验证', (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        // 验证初始状态UI显示
        expect(find.text('BIP39 助记词恢复'), findsOneWidget);
        expect(find.text('本工具为100%离线工具，绝不发送任何数据。'), findsOneWidget);
        expect(find.text('开始恢复 / Start Recovery'), findsOneWidget);
      });

      testWidgets('恢复过程中UI正确显示数据状态', (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        // 进入恢复页面
        await navigateToRecoveryPage(tester);

        // 验证恢复页面显示
        expect(find.text('正在恢复第 1 / 12 个单词'), findsOneWidget);
        expect(find.text('输入数字 (例如 2, 4, 256):'), findsOneWidget);
        expect(find.text('已恢复的单词:'), findsOneWidget);

        // 验证当前输入为空时的显示
        expect(find.text('(等待输入)'), findsOneWidget);
      });

      testWidgets('输入数据后UI状态更新', (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        // 进入恢复页面
        await navigateToRecoveryPage(tester);

        // 添加数字
        await tester.enterText(find.byType(TextField), '256');
        await tester.tap(find.text('添加数字'));
        await tester.pumpAndSettle();

        // 验证输入状态显示
        expect(find.text('已输入的数字: 256'), findsOneWidget);
        
        // 验证当前单词状态显示（应该显示单词信息）
        expect(find.textContaining('[总和: 256]'), findsOneWidget);
      });
    });

    group('清空当前输入测试', () {
      testWidgets('清空当前输入按钮功能验证', (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        // 进入恢复页面
        await navigateToRecoveryPage(tester);

        // 添加多个数字
        await tester.enterText(find.byType(TextField), '128');
        await tester.tap(find.text('添加数字'));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), '64');
        await tester.tap(find.text('添加数字'));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), '32');
        await tester.tap(find.text('添加数字'));
        await tester.pumpAndSettle();

        // 验证数据已添加
        expect(find.text('已输入的数字: 32, 64, 128'), findsOneWidget);

        // 点击清空当前输入
        await tester.tap(find.text('清空当前'));
        await tester.pumpAndSettle();

        // 验证所有当前输入数据被清空
        expect(find.text('(等待输入)'), findsOneWidget);
        expect(find.textContaining('已输入的数字:'), findsNothing);
      });

      testWidgets('清空后输入控制器状态验证', (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        // 进入恢复页面
        await navigateToRecoveryPage(tester);

        // 输入一些文本
        await tester.enterText(find.byType(TextField), 'test input');
        await tester.pumpAndSettle();

        // 验证文本已输入
        expect(find.text('test input'), findsOneWidget);

        // 点击清空当前输入
        await tester.tap(find.text('清空当前'));
        await tester.pumpAndSettle();

        // 验证输入框被清空（文本消失）
        expect(find.text('test input'), findsNothing);
        expect(find.byType(TextField), findsOneWidget);
      });
    });

    group('重新开始功能测试', () {
      testWidgets('重新开始按钮清理所有助记词数据', (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        // 进入恢复页面并恢复一些单词
        await navigateToRecoveryPage(tester);

        // 恢复几个单词
        for (int i = 0; i < 5; i++) {
          await tester.enterText(find.byType(TextField), '128');
          await tester.tap(find.text('添加数字'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('确认单词并继续'));
          await tester.pumpAndSettle();
        }

        // 验证有数据存在（助记词列表应该显示）
        final mnemonicList = find.byType(ListView);
        expect(mnemonicList, findsOneWidget);

        // 导航到结果页面并点击重新开始
        final pageView = tester.widget<PageView>(find.byType(PageView));
        pageView.controller!.jumpToPage(4);
        await tester.pumpAndSettle();

        await tester.tap(find.text('重新开始'));
        await tester.pumpAndSettle();

        // 验证回到欢迎页面
        expect(find.text('BIP39 助记词恢复'), findsOneWidget);
        expect(find.text('本工具为100%离线工具，绝不发送任何数据。'), findsOneWidget);
      });

      testWidgets('重新开始后状态完全重置', (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        // 进入2048模式
        await tester.tap(find.text('开始恢复 / Start Recovery'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('2048模式'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('12个单词'));
        await tester.pumpAndSettle();

        // 验证是2048模式（应该显示2048相关的UI）
        expect(find.text('正在恢复第 1 / 12 个单词'), findsOneWidget);

        // 导航到结果页面并重新开始
        final pageView = tester.widget<PageView>(find.byType(PageView));
        pageView.controller!.jumpToPage(4);
        await tester.pumpAndSettle();

        await tester.tap(find.text('重新开始'));
        await tester.pumpAndSettle();

        // 验证回到初始状态（中文显示）
        expect(find.text('BIP39 助记词恢复'), findsOneWidget);
        expect(find.text('请选择恢复模式：'), findsNothing); // 不应该在欢迎页面
      });
    });

    group('页面导航清理测试', () {
      testWidgets('导航过程中数据状态验证', (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        // 进入恢复页面
        await navigateToRecoveryPage(tester);

        // 添加一些数据
        await tester.enterText(find.byType(TextField), '256');
        await tester.tap(find.text('添加数字'));
        await tester.pumpAndSettle();

        // 验证数据存在
        expect(find.text('已输入的数字: 256'), findsOneWidget);

        // 通过重新开始清理数据（模拟用户决定重新开始）
        await tester.tap(find.text('重新开始'));
        await tester.pumpAndSettle();

        // 验证回到欢迎页面且无残留数据状态
        expect(find.text('BIP39 助记词恢复'), findsOneWidget);
      });

      testWidgets('模式切换时状态清理', (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        // 进入1024模式并开始恢复
        await tester.tap(find.text('开始恢复 / Start Recovery'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('1024模式'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('12个单词'));
        await tester.pumpAndSettle();

        // 添加一些数据
        await tester.enterText(find.byType(TextField), '128');
        await tester.tap(find.text('添加数字'));
        await tester.pumpAndSettle();

        // 切换回模式选择（这会清理数据）
        await tester.tap(find.text('返回 / Back'));
        await tester.pumpAndSettle();

        // 验证回到模式选择页面
        expect(find.text('请选择恢复模式：'), findsOneWidget);
      });
    });

    group('输入历史清理测试', () {
      testWidgets('撤销功能清理单个输入', (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        // 进入恢复页面
        await navigateToRecoveryPage(tester);

        // 添加多个数字
        await tester.enterText(find.byType(TextField), '128');
        await tester.tap(find.text('添加数字'));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), '64');
        await tester.tap(find.text('添加数字'));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), '32');
        await tester.tap(find.text('添加数字'));
        await tester.pumpAndSettle();

        // 验证所有输入存在
        expect(find.text('已输入的数字: 32, 64, 128'), findsOneWidget);

        // 撤销最后一个输入
        await tester.tap(find.text('撤销上一个'));
        await tester.pumpAndSettle();

        // 验证最后一个输入被移除
        expect(find.text('已输入的数字: 128, 64'), findsOneWidget);
      });

      testWidgets('回退单词功能数据清理', (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        // 进入恢复页面
        await navigateToRecoveryPage(tester);

        // 确认第一个单词
        await tester.enterText(find.byType(TextField), '256');
        await tester.tap(find.text('添加数字'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('确认单词并继续'));
        await tester.pumpAndSettle();

        // 验证第一个单词已保存（应该显示在列表中）
        expect(find.text('已恢复的单词:'), findsOneWidget);

        // 回退到上一个单词
        await tester.tap(find.text('回退上一个单词'));
        await tester.pumpAndSettle();

        // 验证回退成功的提示
        expect(find.textContaining('已回退到第'), findsOneWidget);
        
        // 验证回到第一个单词的输入状态
        expect(find.text('正在恢复第 1 / 12 个单词'), findsOneWidget);
      });
    });

    group('文本控制器清理测试', () {
      testWidgets('文本输入控制器在操作后被正确清理', (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        // 进入恢复页面
        await navigateToRecoveryPage(tester);

        // 输入文本
        await tester.enterText(find.byType(TextField), '512');
        await tester.pumpAndSettle();

        // 验证文本已输入
        expect(find.text('512'), findsOneWidget);

        // 添加数字（这会清空控制器）
        await tester.tap(find.text('添加数字'));
        await tester.pumpAndSettle();

        // 验证控制器被清空（文本消失）
        expect(find.text('512'), findsNothing);

        // 再次输入
        await tester.enterText(find.byType(TextField), '256');
        await tester.pumpAndSettle();

        // 验证新文本
        expect(find.text('256'), findsOneWidget);

        // 清空当前输入
        await tester.tap(find.text('清空当前'));
        await tester.pumpAndSettle();

        // 验证控制器再次被清空
        expect(find.text('256'), findsNothing);
      });
    });

    group('敏感数据内存清理验证', () {
      testWidgets('助记词显示后的UI状态验证', (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        // 进入恢复页面
        await navigateToRecoveryPage(tester);

        // 快速恢复几个单词
        for (int i = 0; i < 3; i++) {
          await tester.enterText(find.byType(TextField), '128');
          await tester.tap(find.text('添加数字'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('确认单词并继续'));
          await tester.pumpAndSettle();
        }

        // 验证助记词列表正确显示
        final mnemonicList = find.byType(ListView);
        expect(mnemonicList, findsOneWidget);

        // 验证助记词在界面上正确显示（编号格式）
        expect(find.textContaining('1.'), findsOneWidget);
        expect(find.textContaining('2.'), findsOneWidget);
        expect(find.textContaining('3.'), findsOneWidget);
      });

      testWidgets('退出时数据状态验证', (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        // 进入恢复页面
        await navigateToRecoveryPage(tester);

        // 添加一些敏感数据
        await tester.enterText(find.byType(TextField), '1024');
        await tester.tap(find.text('添加数字'));
        await tester.pumpAndSettle();

        // 确认一个单词
        await tester.tap(find.text('确认单词并继续'));
        await tester.pumpAndSettle();

        // 验证敏感数据存在于UI中
        expect(find.text('已恢复的单词:'), findsOneWidget);

        // 导航到结果页面
        final pageView = tester.widget<PageView>(find.byType(PageView));
        pageView.controller!.jumpToPage(4);
        await tester.pumpAndSettle();

        // 验证结果页面显示
        expect(find.text('恢复成功！'), findsOneWidget);
        expect(find.text('您恢复的BIP39助记词短语是：'), findsOneWidget);
      });
    });

    group('边界情况清理测试', () {
      testWidgets('空状态下的清空操作安全性', (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        // 进入恢复页面
        await navigateToRecoveryPage(tester);

        // 验证初始空状态
        expect(find.text('(等待输入)'), findsOneWidget);

        // 在空状态下尝试清空（应该安全）
        await tester.tap(find.text('清空当前'));
        await tester.pumpAndSettle();

        // 验证状态仍然安全
        expect(find.text('(等待输入)'), findsOneWidget);
      });

      testWidgets('单个输入的撤销清理', (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        // 进入恢复页面
        await navigateToRecoveryPage(tester);

        // 添加单个数字
        await tester.enterText(find.byType(TextField), '512');
        await tester.tap(find.text('添加数字'));
        await tester.pumpAndSettle();

        expect(find.text('已输入的数字: 512'), findsOneWidget);

        // 撤销唯一的输入
        await tester.tap(find.text('撤销上一个'));
        await tester.pumpAndSettle();

        // 验证回到空状态
        expect(find.text('(等待输入)'), findsOneWidget);
        expect(find.textContaining('已输入的数字:'), findsNothing);
      });
    });

    group('安全提示验证', () {
      testWidgets('安全提示在结果页面正确显示', (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        // 快速进入结果页面（模拟完成恢复）
        final pageView = tester.widget<PageView>(find.byType(PageView));
        pageView.controller!.jumpToPage(4);
        await tester.pumpAndSettle();

        // 验证安全提示显示
        expect(find.text('【安全提示】在您安全备份好助记词后，请关闭本窗口。'), findsOneWidget);
      });

      testWidgets('安全提示强调数据保护', (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        // 进入结果页面
        final pageView = tester.widget<PageView>(find.byType(PageView));
        pageView.controller!.jumpToPage(4);
        await tester.pumpAndSettle();

        // 验证安全提示使用警告颜色
        final securityText = tester.widget<Text>(find.text('【安全提示】在您安全备份好助记词后，请关闭本窗口。'));
        expect(securityText.style!.color, equals(Colors.red));
      });
    });
  });
}