# BIP39恢复工具测试指南

本文档描述了如何运行BIP39恢复工具的完整测试套件。

## 测试架构

测试套件采用分层架构，包括：

### 1. 单元测试 (`test/`)
- **bip39_logic_test.dart**: 测试核心业务逻辑
  - 模式切换逻辑
  - 数字验证算法
  - 词表加载和缓存
  - 边界条件处理

- **bip39_ui_test.dart**: 测试UI组件
  - 页面导航
  - 组件渲染
  - 用户交互
  - 主题和样式

- **error_handling_test.dart**: 测试错误处理
  - 无效输入处理
  - 重复输入检测
  - 边界条件验证
  - 用户操作反馈

### 2. 集成测试 (`integration_test/`)
- **app_test.dart**: 端到端功能测试
  - 完整用户流程
  - 多语言支持
  - 模式切换
  - 错误恢复

- **complete_workflow_test.dart**: 完整工作流测试
  - 12/18/24单词恢复流程
  - 1024/2048模式测试
  - 性能和稳定性测试
  - 边界条件测试

- **test_helpers.dart**: 测试辅助工具
  - 导航辅助函数
  - 数据输入助手
  - 验证工具
  - 测试数据生成器

## 运行测试

### 1. 安装依赖
```bash
flutter pub get
```

### 2. 运行单元测试
```bash
# 运行所有单元测试
flutter test

# 运行特定测试文件
flutter test test/bip39_logic_test.dart
flutter test test/bip39_ui_test.dart
flutter test test/error_handling_test.dart

# 运行测试并生成覆盖率报告
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### 3. 运行集成测试
```bash
# 运行所有集成测试
flutter test integration_test/

# 运行特定集成测试
flutter test integration_test/app_test.dart
flutter test integration_test/complete_workflow_test.dart
```

### 4. 在设备上运行集成测试
```bash
# Android设备
flutter test integration_test/ -d <device-id>

# iOS设备
flutter test integration_test/ -d <device-id>

# Chrome浏览器
flutter test integration_test/ -d chrome
```

## 测试用例覆盖

### 功能测试覆盖
- ✅ 欢迎页面和导航
- ✅ 模式选择（1024/2048）
- ✅ 长度选择（12/18/24单词）
- ✅ 数字输入和验证
- ✅ 单词恢复流程
- ✅ 结果显示
- ✅ 语言切换（中/英）
- ✅ 错误处理和用户反馈
- ✅ 操作功能（撤销/清空/回退）

### 边界条件测试
- ✅ 无效数字输入
- ✅ 重复数字检测
- ✅ 数字1重复限制
- ✅ 超出范围索引
- ✅ 空输入处理
- ✅ 长文本输入
- ✅ 特殊字符输入
- ✅ 页面导航边界

### 性能测试
- ✅ 快速导航压力测试
- ✅ 语言切换压力测试
- ✅ 大量输入累积测试
- ✅ 内存泄漏检测
- ✅ 响应时间验证

## 测试数据

### 有效输入数字
- **1024模式**: 1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024
- **2048模式**: 1024模式所有数字 + 2048

### 测试场景
- **正常流程**: 完整的助记词恢复
- **错误恢复**: 从错误中恢复正常操作
- **边界测试**: 最大/最小值输入
- **性能测试**: 快速连续操作
- **用户体验**: 错误提示和操作反馈

## 测试最佳实践

### 1. 测试命名
- 使用描述性的测试名称
- 遵循 `testWidgets('功能描述 测试场景', ...)` 格式
- 包含预期结果描述

### 2. 测试结构
```dart
testWidgets('功能描述', (WidgetTester tester) async {
  // 1. 设置测试环境
  await tester.pumpWidget(MyApp());
  
  // 2. 执行测试步骤
  // ...
  
  // 3. 验证结果
  expect(find.widget, findsOneWidget);
});
```

### 3. 辅助函数使用
- 使用 `TestHelpers` 类中的辅助函数
- 避免重复的导航逻辑
- 保持测试代码简洁

### 4. 异步测试
```dart
// 等待异步操作
await tester.pumpAndSettle();

// 等待特定条件
await tester.waitFor(find.text('expected text'));
```

## 故障排除

### 常见问题

1. **集成测试失败**
   ```bash
   # 确保设备连接
   flutter devices
   
   # 重启测试服务
   flutter clean
   flutter pub get
   ```

2. **测试超时**
   - 检查 `pumpAndSettle()` 调用
   - 增加超时时间
   - 验证异步操作完成

3. **依赖错误**
   ```bash
   # 更新依赖
   flutter pub upgrade
   
   # 清理缓存
   flutter clean
   flutter pub get
   ```

### 调试技巧

1. **可视化测试**
   ```dart
   // 在测试中添加延迟以便观察
   await Future.delayed(Duration(seconds: 2));
   ```

2. **日志输出**
   ```dart
   print('Debug: Current state: $state');
   ```

3. **截图保存**
   ```dart
   await tester.binding.setSurfaceSize(Size(400, 800));
   await tester.pumpAndSettle();
   ```

## 持续集成

### GitHub Actions配置示例
```yaml
name: Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.9.0'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Run unit tests
        run: flutter test --coverage
      
      - name: Run integration tests
        run: flutter test integration_test/ -d chrome
```

## 测试报告

### 覆盖率要求
- 单元测试覆盖率: > 90%
- 集成测试覆盖: 所有主要功能路径

### 质量标准
- 所有测试必须通过
- 无内存泄漏
- 响应时间 < 2秒
- 错误处理完整

## 维护

### 定期更新
- 每月运行完整测试套件
- 跟随Flutter版本更新
- 添加新功能测试

### 测试数据管理
- 保持测试数据同步
- 更新词表文件
- 验证测试有效性

---

**注意**: 集成测试需要在真实设备或模拟器上运行，确保测试环境的稳定性。