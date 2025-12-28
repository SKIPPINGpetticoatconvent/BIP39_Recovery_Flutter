// BIP39逻辑类的单元测试
import 'package:flutter_test/flutter_test.dart';
import 'package:bip39_recovery_flutter/bip39_recovery/bip39_logic.dart';

void main() {
  group('Bip39Logic 单元测试', () {
    late Bip39Logic logic;

    setUp(() {
      logic = Bip39Logic();
    });

    test('初始状态测试', () {
      expect(logic.is2048Mode, false);
      expect(logic.wordlist, isNull);
    });

    test('模式切换测试', () {
      // 默认1024模式
      expect(logic.is2048Mode, false);
      expect(logic.validInputNumbers, equals(Bip39Logic.validInputNumbers1024));
      expect(logic.maxSum, equals(1023));

      // 切换到2048模式
      logic.setMode(true);
      expect(logic.is2048Mode, true);
      expect(logic.validInputNumbers, equals(Bip39Logic.validInputNumbers2048));
      expect(logic.maxSum, equals(4095));

      // 切换回1024模式
      logic.setMode(false);
      expect(logic.is2048Mode, false);
      expect(logic.validInputNumbers, equals(Bip39Logic.validInputNumbers1024));
      expect(logic.maxSum, equals(1023));
    });

    test('有效输入数字验证测试', () {
      // 1024模式的有效输入
      logic.setMode(false);
      
      // 有效的2的幂
      expect(logic.isValidInputNumber(1), true);
      expect(logic.isValidInputNumber(2), true);
      expect(logic.isValidInputNumber(4), true);
      expect(logic.isValidInputNumber(8), true);
      expect(logic.isValidInputNumber(16), true);
      expect(logic.isValidInputNumber(32), true);
      expect(logic.isValidInputNumber(64), true);
      expect(logic.isValidInputNumber(128), true);
      expect(logic.isValidInputNumber(256), true);
      expect(logic.isValidInputNumber(512), true);
      expect(logic.isValidInputNumber(1024), true);

      // 无效输入
      expect(logic.isValidInputNumber(0), false);
      expect(logic.isValidInputNumber(3), false);
      expect(logic.isValidInputNumber(6), false);
      expect(logic.isValidInputNumber(7), false);
      expect(logic.isValidInputNumber(2048), false);
    });

    test('2048模式有效输入数字验证测试', () {
      logic.setMode(true);
      
      // 1024模式的所有有效输入在2048模式中也应该有效
      expect(logic.isValidInputNumber(1), true);
      expect(logic.isValidInputNumber(2), true);
      expect(logic.isValidInputNumber(4), true);
      expect(logic.isValidInputNumber(8), true);
      expect(logic.isValidInputNumber(16), true);
      expect(logic.isValidInputNumber(32), true);
      expect(logic.isValidInputNumber(64), true);
      expect(logic.isValidInputNumber(128), true);
      expect(logic.isValidInputNumber(256), true);
      expect(logic.isValidInputNumber(512), true);
      expect(logic.isValidInputNumber(1024), true);
      
      // 2048模式独有的输入
      expect(logic.isValidInputNumber(2048), true);
    });

    test('词表加载测试', () async {
      // 初始状态词表为null
      expect(logic.wordlist, isNull);

      // 加载词表
      final wordlist = await logic.loadWordlist();
      
      // 验证词表加载成功
      expect(wordlist, isNotNull);
      expect(wordlist, isA<List<String>>());
      expect(wordlist!.length, equals(2048));

      // 验证逻辑类中的词表也已更新
      expect(logic.wordlist, isNotNull);
      expect(logic.wordlist!.length, equals(2048));

      // 验证第一次单词（索引0）
      final firstWord = logic.getWord(0);
      expect(firstWord, isNotNull);
      expect(firstWord, isA<String>());

      // 验证最后一个单词（索引2047）
      final lastWord = logic.getWord(2047);
      expect(lastWord, isNotNull);
      expect(lastWord, isA<String>());

      // 验证超出范围的索引
      final invalidWord1 = logic.getWord(-1);
      expect(invalidWord1, isNull);

      final invalidWord2 = logic.getWord(2048);
      expect(invalidWord2, isNull);

      final invalidWord3 = logic.getWord(9999);
      expect(invalidWord3, isNull);
    });

    test('词表缓存测试', () async {
      // 第一次加载
      final wordlist1 = await logic.loadWordlist();
      expect(wordlist1, isNotNull);

      // 第二次加载应该返回相同的实例（缓存）
      final wordlist2 = await logic.loadWordlist();
      expect(wordlist2, equals(wordlist1));
    });

    test('获取单词功能测试', () async {
      await logic.loadWordlist();
      
      if (logic.wordlist != null && logic.wordlist!.isNotEmpty) {
        // 测试几个有效的索引
        final word0 = logic.getWord(0);
        final word100 = logic.getWord(100);
        final word1000 = logic.getWord(1000);
        final word2047 = logic.getWord(2047);

        expect(word0, isNotNull);
        expect(word100, isNotNull);
        expect(word1000, isNotNull);
        expect(word2047, isNotNull);

        // 验证所有返回的都是字符串
        expect(word0, isA<String>());
        expect(word100, isA<String>());
        expect(word1000, isA<String>());
        expect(word2047, isA<String>());

        // 验证无效索引返回null
        expect(logic.getWord(-1), isNull);
        expect(logic.getWord(2048), isNull);
        expect(logic.getWord(99999), isNull);
      }
    });

    test('边界条件测试', () {
      // 测试极端值
      expect(logic.isValidInputNumber(-1), false);
      expect(logic.isValidInputNumber(0), false);
      expect(logic.isValidInputNumber(999999), false);
    });

    test('模式一致性测试', () {
      // 确保模式设置后各种属性保持一致
      logic.setMode(false);
      expect(logic.is2048Mode, false);
      expect(logic.validInputNumbers, equals(Bip39Logic.validInputNumbers1024));
      expect(logic.maxSum, equals(1023));

      logic.setMode(true);
      expect(logic.is2048Mode, true);
      expect(logic.validInputNumbers, equals(Bip39Logic.validInputNumbers2048));
      expect(logic.maxSum, equals(4095));

      // 多次切换应该保持一致
      logic.setMode(false);
      logic.setMode(false);
      expect(logic.is2048Mode, false);

      logic.setMode(true);
      logic.setMode(true);
      expect(logic.is2048Mode, true);
    });
  });
}