// BIP39恢复工具UI组件测试
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bip39_recovery_flutter/main.dart';
import 'package:bip39_recovery_flutter/bip39_recovery/bip39_ui.dart';
import 'package:bip39_recovery_flutter/bip39_recovery/bip39_logic.dart';

void main() {
  group('BIP39 UI组件测试', () {
    testWidgets('应用启动测试', (WidgetTester tester) async {
      // 构建应用
      await tester.pumpWidget(const MyApp());

      // 验证应用标题
      expect(find.text('BIP39 Recovery Tool'), findsOneWidget);
      
      // 验证主屏幕存在
      expect(find.byType(Bip39RecoveryScreen), findsOneWidget);
    });

    testWidgets('欢迎页面UI测试', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // 验证欢迎页面元素
      expect(find.text('BIP39 助记词恢复'), findsOneWidget);
      expect(find.text('本工具为100%离线工具，绝不发送任何数据。'), findsOneWidget);
      expect(find.text('开始恢复 / Start Recovery'), findsOneWidget);
      
      // 验证语言切换按钮
      expect(find.text('English'), findsOneWidget);
      expect(find.text('中文'), findsOneWidget);
    });

    testWidgets('模式选择页面UI测试', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // 点击开始恢复按钮进入模式选择页面
      await tester.tap(find.text('开始恢复 / Start Recovery'));
      await tester.pumpAndSettle();

      // 验证模式选择页面元素
      expect(find.text('请选择恢复模式：'), findsOneWidget);
      expect(find.text('1024模式'), findsOneWidget);
      expect(find.text('2048模式'), findsOneWidget);
      expect(find.text('返回 / Back'), findsOneWidget);
    });

    testWidgets('长度选择页面UI测试', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // 进入模式选择页面
      await tester.tap(find.text('开始恢复 / Start Recovery'));
      await tester.pumpAndSettle();

      // 选择1024模式进入长度选择页面
      await tester.tap(find.text('1024模式'));
      await tester.pumpAndSettle();

      // 验证长度选择页面元素
      expect(find.text('请选择您的助记词短语长度：'), findsOneWidget);
      expect(find.text('12个单词'), findsOneWidget);
      expect(find.text('18个单词'), findsOneWidget);
      expect(find.text('24个单词'), findsOneWidget);
      expect(find.text('返回 / Back'), findsOneWidget);
    });

    testWidgets('恢复页面UI测试', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // 进入恢复页面
      await tester.tap(find.text('开始恢复 / Start Recovery'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('1024模式'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('12个单词'));
      await tester.pumpAndSettle();

      // 验证恢复页面元素
      expect(find.text('正在恢复第 1 / 12 个单词'), findsOneWidget);
      expect(find.text('输入数字 (例如 2, 4, 256):'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('添加数字'), findsOneWidget);
      expect(find.text('确认单词并继续'), findsOneWidget);
      expect(find.text('已恢复的单词:'), findsOneWidget);

      // 验证操作按钮
      expect(find.text('撤销上一个'), findsOneWidget);
      expect(find.text('清空当前'), findsOneWidget);
      expect(find.text('回退上一个单词'), findsOneWidget);
    });

    testWidgets('结果页面UI测试', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // 通过PageView导航到结果页面（模拟完成恢复流程）
      final pageView = tester.widget<PageView>(find.byType(PageView));
      pageView.controller!.jumpToPage(4);
      await tester.pumpAndSettle();

      // 验证结果页面元素
      expect(find.text('恢复成功！'), findsOneWidget);
      expect(find.text('您恢复的BIP39助记词短语是：'), findsOneWidget);
      expect(find.text('【安全提示】在您安全备份好助记词后，请关闭本窗口。'), findsOneWidget);
      expect(find.text('重新开始'), findsOneWidget);
      expect(find.text('退出'), findsOneWidget);
    });

    testWidgets('语言切换UI测试', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // 验证默认中文显示
      expect(find.text('BIP39 助记词恢复'), findsOneWidget);

      // 切换到英文
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      // 验证英文显示
      expect(find.text('BIP39 Mnemonic Recovery'), findsOneWidget);
      expect(find.text('Please select the recovery mode:'), findsOneWidget);

      // 切换回中文
      await tester.tap(find.text('中文'));
      await tester.pumpAndSettle();

      // 验证中文显示
      expect(find.text('BIP39 助记词恢复'), findsOneWidget);
      expect(find.text('本工具为100%离线工具，绝不发送任何数据。'), findsOneWidget);
    });

    testWidgets('输入框和按钮交互测试', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // 进入恢复页面
      await tester.tap(find.text('开始恢复 / Start Recovery'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('1024模式'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('12个单词'));
      await tester.pumpAndSettle();

      // 测试文本输入
      await tester.enterText(find.byType(TextField), '256');
      await tester.pumpAndSettle();

      // 验证输入内容
      expect(find.text('256'), findsOneWidget);

      // 测试添加数字按钮
      await tester.tap(find.text('添加数字'));
      await tester.pumpAndSettle();

      // 验证数字已添加的提示
      expect(find.textContaining('已输入的数字'), findsOneWidget);
    });

    testWidgets('错误状态UI测试', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // 进入恢复页面
      await tester.tap(find.text('开始恢复 / Start Recovery'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('1024模式'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('12个单词'));
      await tester.pumpAndSettle();

      // 输入无效数字
      await tester.enterText(find.byType(TextField), '3');
      await tester.pumpAndSettle();
      await tester.tap(find.text('添加数字'));
      await tester.pumpAndSettle();

      // 验证错误提示显示
      expect(find.textContaining('请输入一个有效的2的幂'), findsOneWidget);

      // 清空输入并测试空输入确认
      await tester.tap(find.text('确认单词并继续'));
      await tester.pumpAndSettle();

      // 验证空输入警告
      expect(find.textContaining('请至少为这个单词添加一个数字'), findsOneWidget);
    });

    testWidgets('页面导航测试', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // 测试从欢迎页面到模式选择页面的导航
      await tester.tap(find.text('开始恢复 / Start Recovery'));
      await tester.pumpAndSettle();
      expect(find.text('请选择恢复模式：'), findsOneWidget);

      // 测试返回导航
      await tester.tap(find.text('返回 / Back'));
      await tester.pumpAndSettle();
      expect(find.text('BIP39 助记词恢复'), findsOneWidget);
    });

    testWidgets('主题和样式测试', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // 验证Material 3主题
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme, isNotNull);

      // 验证AppBar存在且有正确的颜色
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.title, isNotNull);
      expect(appBar.backgroundColor, isNotNull);
    });

    testWidgets('响应式布局测试', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // 验证Card组件用于页面布局
      expect(find.byType(Card), findsAtLeastNWidgets(1));

      // 验证容器约束
      final card = tester.widget<Card>(find.byType(Card));
      expect(card.elevation, equals(4.0));
      expect(card.shape, isNotNull);
    });
  });
}