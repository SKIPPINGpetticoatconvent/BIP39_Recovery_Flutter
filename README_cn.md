# BIP39 助记词恢复工具

> **[English Version](README.md)**

一个安全、离线的 BIP39 助记词恢复工具。本应用程序帮助用户使用“点图（Dotmap）”方法（通过累加2的幂）来重构单词，从而恢复 BIP39 种子短语，确保在最后一步之前绝不以明文形式直接输入完整的种子短语。

## 功能特性

- **100% 离线**: 无需网络连接。
- **安全输入**: 使用2的幂（例如 1, 2, 4, 8...）重构单词。
- **双模式**:
  - **1024 模式**: 使用最大到 1024 的幂。
  - **2048 模式**: 使用最大到 2048 的幂。
- **多平台支持**:
  - **Flutter 应用**: 支持 Android, iOS, Windows, Linux, macOS。
  - **Python 演示**: 用于桌面的独立脚本。
- **包含资源**: 包含适用于 1024 和 2048 模式的点图（Dotmap）PDF 文件。

## 项目结构

- `lib/`: Flutter 应用程序源代码。
- `Demo/`: Python 实现代码 (`bip39_recovery.py`)。
- `1024/`: 包含 1024 模式的点图 PDF。
- `2048/`: 包含 2048 模式的点图 PDF。

## Flutter 应用程序

### 前置要求
- Flutter SDK
- Dart SDK

### 安装与运行
1. 克隆仓库。
2. 安装依赖：
   ```bash
   flutter pub get
   ```
3. 运行应用：
   ```bash
   flutter run
   ```

### 构建
- **Android**: `flutter build apk --release`
- **Windows**: `flutter build windows --release`
- **Linux**: `flutter build linux --release`
- **macOS**: `flutter build macos --release`

## Python 演示版

`Demo/` 目录下提供了一个 Python 版本。

### 前置要求
- Python 3.x
- PySide6

### 使用方法
```bash
pip install PySide6
python Demo/bip39_recovery.py
```

## 使用指南

1.  **选择模式**: 根据您的点图或偏好，选择 **1024 模式** 或 **2048 模式**。
2.  **选择长度**: 选择 12、18 或 24 个单词。
3.  **恢复单词**:
    *   对于每个单词，输入对应于该单词索引的数字（2的幂）。
    *   示例：如果单词索引源自 `4 + 8 + 32`，则输入这些数字。
    *   工具将显示与总和对应的单词。
4.  **完成**: 输入所有单词后，将显示完整的短语。

> **注意**: 本工具使用标准的 BIP39 英文词表。

![截图](image/README_cn/1755951444380.png)

## 安全性

- 请在 **离线** 设备上运行此工具。
- 使用后请清空剪贴板并关闭应用程序。
- 如果您非常谨慎（在处理加密货币时应该如此），请验证源代码。

## 许可证

MIT
