#!/bin/bash

# BIP39恢复工具测试运行脚本
# 此脚本运行完整的测试套件

echo "🧪 开始BIP39恢复工具测试套件..."
echo "========================================"

# 检查Flutter是否安装
if ! command -v flutter &> /dev/null; then
    echo "❌ 错误: Flutter未安装或未在PATH中找到"
    exit 1
fi

# 检查项目依赖
echo "📦 检查项目依赖..."
flutter pub get

if [ $? -ne 0 ]; then
    echo "❌ 依赖安装失败"
    exit 1
fi

echo "✅ 依赖检查完成"
echo ""

# 运行代码分析
echo "🔍 运行代码分析..."
flutter analyze

if [ $? -ne 0 ]; then
    echo "⚠️  代码分析发现问题，但继续运行测试"
fi

echo ""

# 运行单元测试
echo "🧪 运行单元测试..."
echo "----------------------------------------"

echo "测试核心逻辑..."
flutter test test/bip39_logic_test.dart

echo ""
echo "测试UI组件..."
flutter test test/bip39_ui_test.dart

echo ""
echo "测试错误处理..."
flutter test test/error_handling_test.dart

echo ""
echo "测试内存安全..."
flutter test test/memory_security_test.dart

echo ""

# 运行集成测试
echo "🔗 运行集成测试..."
echo "----------------------------------------"

# 检查是否有可用的测试设备
DEVICES=$(flutter devices --machine | jq length)

if [ "$DEVICES" -eq 0 ]; then
    echo "⚠️  未找到可用设备，跳过集成测试"
    echo "   如需运行集成测试，请连接设备或启动模拟器"
else
    echo "找到 $DEVICES 个可用设备"
    
    # 获取第一个可用设备ID
    DEVICE_ID=$(flutter devices --machine | jq -r '.[0].id')
    echo "使用设备: $DEVICE_ID"
    
    echo ""
    echo "运行应用集成测试..."
    flutter test integration_test/app_test.dart -d $DEVICE_ID
    
    echo ""
    echo "运行完整工作流测试..."
    flutter test integration_test/complete_workflow_test.dart -d $DEVICE_ID
    
    echo ""
    echo "运行内存清理测试..."
    flutter test integration_test/memory_cleanup_test.dart -d $DEVICE_ID
fi

echo ""
echo "🎯 测试覆盖率报告..."
flutter test --coverage

if [ -f "coverage/lcov.info" ]; then
    echo "✅ 覆盖率报告已生成: coverage/lcov.info"
    echo "   查看详细报告: genhtml coverage/lcov.info -o coverage/html"
fi

echo ""
echo "========================================"
echo "🎉 测试套件执行完成！"
echo ""
echo "📊 测试结果总结:"
echo "   - 单元测试: 检查 test/ 目录下的 .dart 文件"
echo "   - 集成测试: 检查 integration_test/ 目录"
echo "   - 覆盖率: 查看 coverage/ 目录"
echo ""
echo "💡 提示:"
echo "   - 如有测试失败，请查看具体错误信息"
echo "   - 集成测试需要真实设备或模拟器"
echo "   - 运行 'flutter doctor' 检查开发环境"
echo "   - 查看 TESTING.md 获取详细测试指南"

# 可选：生成HTML覆盖率报告
if command -v genhtml &> /dev/null && [ -f "coverage/lcov.info" ]; then
    echo ""
    read -p "🌐 是否生成HTML覆盖率报告? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        mkdir -p coverage/html
        genhtml coverage/lcov.info -o coverage/html
        echo "✅ HTML覆盖率报告已生成: coverage/html/index.html"
    fi
fi