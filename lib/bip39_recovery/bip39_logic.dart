import 'package:flutter/services.dart' show rootBundle;

class Bip39Logic {
  static const String wordlistPath = 'lib/bip39_recovery/wordlists/english.txt';
  static const Set<int> validInputNumbers1024 = {
    1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024
  };
  static const Set<int> validInputNumbers2048 = {
    1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048
  };

  List<String>? _wordlist;
  List<String>? get wordlist => _wordlist; // Public getter for _wordlist
  bool _is2048Mode = false;
  bool get is2048Mode => _is2048Mode;

  void setMode(bool is2048Mode) {
    _is2048Mode = is2048Mode;
  }

  Set<int> get validInputNumbers => _is2048Mode ? validInputNumbers2048 : validInputNumbers1024;

  Future<List<String>?> loadWordlist() async {
    if (_wordlist != null) {
      return _wordlist;
    }
    try {
      String content = await rootBundle.loadString(wordlistPath);
      List<String> words = content
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList();

      if (words.length != 2048) {
        // TODO: Handle error - invalid wordlist length
        return null;
      }
      _wordlist = words;
      return _wordlist;
    } catch (e) {
      // TODO: Handle error - file read error
      return null;
    }
  }

  String? getWord(int index) {
    if (_wordlist == null || index < 0 || index >= _wordlist!.length) {
      return null;
    }
    return _wordlist![index];
  }

  bool isValidInputNumber(int number) {
    return validInputNumbers.contains(number);
  }
}