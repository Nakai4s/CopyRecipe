import 'dart:core';

class TextExtractUtils {
  
  // 抽出したレシピの文字列を返却する
  static String extractRecipe(String description) {
    // 正規化
    final lines = description.replaceAll('\r\n', '\n').split('\n');

    // find start index of recipe section (first heading occurrence)
    int start = -1;
    for (int i = 0; i < lines.length; i++) {
      if (_sectionStartPattern.hasMatch(lines[i])) {
        start = i;
        break;
      }
    }

    // 関係ない動画の概要欄も拾うから一旦辞める
    if (start == -1) {
      return '';
    }

    // from start, gather until a footer-like section (SNS / Links / 提供 / 協賛) or long URL block
    final sectionLines = <String>[];
    for (int i = start; i < lines.length; i++) {
      if (_footerPattern.hasMatch(lines[i])) break;
      sectionLines.add(lines[i].trim());
    }

    return sectionLines.join('\n');
  }
}

final _sectionStartPattern = RegExp(
  r'今回のレシピはこちら|材料'
);

final _footerPattern = RegExp(
  r'(?:SNS|Instagram|Twitter|LINE|提供|協賛|スポンサー|https?:\/\/|bit\.ly|@)'
);