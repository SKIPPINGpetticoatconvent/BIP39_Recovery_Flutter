# BIP39 Recovery Tool

> **[中文版 (Chinese Version)](README_cn.md)**

A secure, offline BIP39 mnemonic recovery tool. This application helps users recover their BIP39 seed phrases using a "Dotmap" approach (summing powers of 2) to reconstruct words, ensuring the full seed phrase is never typed directly in plain text until the final step.

## Features

- **100% Offline**: No internet connection required.
- **Secure Input**: Reconstruct words using powers of 2 (e.g., 1, 2, 4, 8...).
- **Dual Modes**:
  - **1024 Mode**: Uses powers up to 1024.
  - **2048 Mode**: Uses powers up to 2048.
- **Multi-Platform**:
  - **Flutter App**: Android, iOS, Windows, Linux, macOS.
  - **Python Demo**: A standalone script for desktop use.
- **Resources Included**: PDF Dotmaps for 1024 and 2048 modes.

## Project Structure

- `lib/`: Flutter application source code.
- `Demo/`: Python implementation (`bip39_recovery.py`).
- `1024/`: Contains the Dotmap PDF for 1024 mode.
- `2048/`: Contains the Dotmap PDF for 2048 mode.

## Flutter Application

### Prerequisites
- Flutter SDK
- Dart SDK

### Installation & Run
1. Clone the repository.
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

### Building
- **Android**: `flutter build apk --release`
- **Windows**: `flutter build windows --release`
- **Linux**: `flutter build linux --release`
- **macOS**: `flutter build macos --release`

## Python Demo

A Python version is available in the `Demo/` directory.

### Prerequisites
- Python 3.x
- PySide6

### Usage
```bash
pip install PySide6
python Demo/bip39_recovery.py
```

## Usage Guide

1.  **Select Mode**: Choose between **1024 Mode** or **2048 Mode** based on your Dotmap or preference.
2.  **Select Length**: Choose 12, 18, or 24 words.
3.  **Recover Words**:
    *   For each word, enter the numbers (powers of 2) that correspond to the word's index.
    *   Example: If the word index is derived from `4 + 8 + 32`, enter these numbers.
    *   The tool will display the word corresponding to the sum.
4.  **Complete**: Once all words are entered, the full phrase is displayed.

> **Note**: The tool uses the standard BIP39 English wordlist.

![Screenshot](image/README/1755951640025.png)

## Security

- Run this tool on an **offline** machine.
- Clear your clipboard and close the app after use.
- Verify the source code if you are paranoid (as you should be with crypto).

## License

[MIT](LICENSE)
