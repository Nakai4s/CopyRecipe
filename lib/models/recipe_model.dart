import 'dart:core';

class RecipeParts {
  final String ingredients;
  final String steps;
  RecipeParts({required this.ingredients, required this.steps});

  factory RecipeParts.extractRecipe(String description) {
    // normalize line endings and split
    final lines = description.replaceAll('\r\n', '\n').split('\n');

    // find start index of recipe section (first heading occurrence)
    int start = -1;
    for (int i = 0; i < lines.length; i++) {
      if (_sectionStartPattern.hasMatch(lines[i])) {
        start = i;
        break;
      }
    }

    if (start == -1) {
      // 見出しが見つからない場合は、キーワード＆材料っぽい行のまとまりを探す
      final candidates = <String>[];
      for (var line in lines) {
        if (_ingredientLine.hasMatch(line) || _stepLine.hasMatch(line)) {
          candidates.add(line);
        }
      }
      
      return RecipeParts(
        ingredients: '',
        steps: candidates.join('\n'),
      );
    }

    // from start, gather until a footer-like section (SNS / Links / 提供 / 協賛) or long URL block
    final sectionLines = <String>[];
    for (int i = start; i < lines.length; i++) {
      if (_footerPattern.hasMatch(lines[i])) break;
      sectionLines.add(lines[i]);
    }

    // split sectionLines into ingredients and steps by scanning for lines matching ingredient regex then step regex
    final ingredients = <String>[];
    final steps = <String>[];

    for (var line in sectionLines) {
      if (line.trim().isEmpty) continue;
      steps.add(line.trim());
    }

    return RecipeParts(
      ingredients: ingredients.join('\n'),
      steps: steps.join('\n'),
    );
  }
}

final _sectionStartPattern = RegExp(
  r'今回のレシピはこちら|【チャプター】|材料'
);

final _ingredientLine = RegExp(
  r'^(?:[-・\u2022\*\dⅠⅡⅢ④⑤⑥⑦⑧⑨⑩\(\)\.]\s*)?.{2,50}(\d+(\.\d+)?\s?(g|kg|ml|cc|個|本|枚|tbsp|tsp|大さじ|小さじ|cup|cups))'
);

final _stepLine = RegExp(
  r'^(?:\d+\.|①|②|1\)|\d+\)|\d+：)?\s*.*(する|炒める|煮る|混ぜる|切る|焼く|加える|戻す|冷ます|盛り付け)'
);

final _footerPattern = RegExp(
  r'(?:SNS|Instagram|Twitter|LINE|提供|協賛|スポンサー|https?:\/\/|bit\.ly|@)'
);