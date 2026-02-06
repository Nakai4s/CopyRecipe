import 'dart:core';

/// テキスト抽出クラス
class TextExtractUtils {
  // 抽出したレシピの文字列を返却する
  static String extractRecipe(String description) {
    final lines = description.replaceAll('\r\n', '\n').split('\n');

    int start = -1;
    for (int i = 0; i < lines.length; i++) {
      if (_sectionStartPattern.hasMatch(lines[i])) {
        start = i;
        break;
      }
    }

    if (start == -1) return '';

    final sectionLines = <String>[];
    int consecutiveEmpty = 0;

    for (int i = start; i < lines.length; i++) {
      final line = lines[i].trim();

      // フッターパターンは行頭のみチェック（本文中のURLは許容）
      if (_footerPattern.hasMatch(line) && _isFooterLine(line)) break;

      // 連続空行は3行以上でセクション終了とみなす
      if (line.isEmpty) {
        consecutiveEmpty++;
        if (consecutiveEmpty >= 3) break;
        continue;
      }

      consecutiveEmpty = 0;
      sectionLines.add(line);
    }

    return sectionLines.join('\n');
  }

  // フッター行かどうかをより厳密に判定
  static bool _isFooterLine(String line) {
    return RegExp(r'^(SNS|Instagram|Twitter|LINE|提供|協賛|■|【|━|─|https?://)').hasMatch(line);
  }
}

// より多くの料理動画フォーマットに対応
final _sectionStartPattern = RegExp(
  r'(?:今回の)?レシピ(?:はこちら)?|材料|'
  r'(?:【|■|━).*(?:材料|レシピ)|'
  r'(?:◆|●|▼).*材料|'
  r'^\d+人分',
  caseSensitive: false,
);

final _footerPattern = RegExp(
  r'SNS|Instagram|Twitter|LINE|提供|協賛|スポンサー|'
  r'チャンネル登録|お仕事の依頼|コラボ|'
  r'^https?://|^#\w+\s*$',
);