class RecyclingClassification {
  final String objectName;
  final String recyclingBin;
  final String matchedLabel;
  final String reason;
  final bool isKnown;
  final double confidenceScore;

  const RecyclingClassification({
    required this.objectName,
    required this.recyclingBin,
    required this.matchedLabel,
    required this.reason,
    required this.isKnown,
    required this.confidenceScore,
  });
}

class RecyclingClassifier {
  static const String yellowBin =
      'Ecoponto amarelo (plástico/metal/embalagens)';
  static const String blueBin = 'Ecoponto azul (papel/cartão)';
  static const String greenBin = 'Ecoponto verde (vidro)';
  static const String organicBin = 'Lixo orgânico/indiferenciado';
  static const String unknownBin = 'Objeto não identificado';

  static const List<String> _genericLabels = [
    'product',
    'object',
    'material',
    'item',
    'goods',
    'thing',
    'brand',
    'font',
    'graphics',
    'label',
    'design',
    'rectangle',
    'circle',
    'snapshot',
    'photograph',
    'image',
  ];

  static const Map<String, List<String>> _highPriorityYellow = {
    yellowBin: [
      'plastic bottle',
      'water bottle',
      'bottle',
      'plastic container',
      'food container',
      'container',
      'packaging',
      'food packaging',
      'plastic packaging',
      'wrapper',
      'packet',
      'package',
      'carton packaging',
      'yogurt cup',
      'gelatin cup',
      'dessert cup',
      'cup',
      'tray',
      'plastic tray',
      'bowl',
      'tableware',
      'can',
      'tin can',
      'aluminum can',
      'metal can',
      'beverage can',
      'soda can',
      'drink can',
      'milk carton',
      'juice carton',
      'tetra pak',
      'tetrapak',
      'brick',
      'shampoo bottle',
      'detergent bottle',
      'cleaning product',
      'spray bottle',
      'tube',
      'plastic bag',
      'bag',
      'sachet',
      'lid',
      'cap',
      'plastic cap',
    ],
  };

  static const Map<String, List<String>> _highPriorityGreen = {
    greenBin: [
      'glass bottle',
      'wine bottle',
      'beer bottle',
      'glass jar',
      'jar',
      'glass container',
      'glass',
    ],
  };

  static const Map<String, List<String>> _highPriorityBlue = {
    blueBin: [
      'cardboard box',
      'cardboard',
      'paper bag',
      'paper',
      'newspaper',
      'magazine',
      'book',
      'notebook',
      'envelope',
      'sheet of paper',
      'document',
      'paperboard',
      'box',
    ],
  };

  static const Map<String, List<String>> _organicOrGeneralWaste = {
    organicBin: [
      'food',
      'fruit',
      'vegetable',
      'banana',
      'apple',
      'orange',
      'meat',
      'fish',
      'bread',
      'cake',
      'leftovers',
      'napkin',
      'tissue',
      'paper towel',
      'ceramic',
      'plate',
      'broken glass',
      'mirror',
      'window',
      'lamp',
      'battery',
      'medicine',
      'clothes',
      'shoe',
      'toy',
      'wood',
      'diaper',
    ],
  };

  static RecyclingClassification classify(List<String> labels) {
    final normalizedLabels = labels
        .map((label) => label.toLowerCase().trim())
        .where((label) => label.isNotEmpty)
        .toList();

    if (normalizedLabels.isEmpty) {
      return const RecyclingClassification(
        objectName: 'unknown',
        recyclingBin: unknownBin,
        matchedLabel: '',
        reason: 'No labels were detected.',
        isKnown: false,
        confidenceScore: 0,
      );
    }

    final yellowMatch = _findMatch(normalizedLabels, _highPriorityYellow);
    final greenMatch = _findMatch(normalizedLabels, _highPriorityGreen);
    final blueMatch = _findMatch(normalizedLabels, _highPriorityBlue);
    final wasteMatch = _findMatch(normalizedLabels, _organicOrGeneralWaste);

    final matches = [?yellowMatch, ?greenMatch, ?blueMatch, ?wasteMatch]
      ..sort((a, b) => b.score.compareTo(a.score));

    if (matches.isNotEmpty) {
      final best = matches.first;

      return RecyclingClassification(
        objectName: best.detectedLabel,
        recyclingBin: best.bin,
        matchedLabel: best.keyword,
        reason: 'Matched "$best.detectedLabel" with keyword "${best.keyword}".',
        isKnown: best.bin != organicBin,
        confidenceScore: best.score,
      );
    }

    final fallbackLabel = normalizedLabels.firstWhere(
      (label) => !_genericLabels.contains(label),
      orElse: () => normalizedLabels.first,
    );

    return RecyclingClassification(
      objectName: fallbackLabel,
      recyclingBin: unknownBin,
      matchedLabel: '',
      reason: 'No reliable recycling category was matched.',
      isKnown: false,
      confidenceScore: 0,
    );
  }

  static _ClassifierMatch? _findMatch(
    List<String> labels,
    Map<String, List<String>> binKeywords,
  ) {
    _ClassifierMatch? bestMatch;

    for (final entry in binKeywords.entries) {
      final bin = entry.key;
      final keywords = entry.value;

      for (final label in labels) {
        for (final keyword in keywords) {
          final score = _calculateScore(label, keyword);

          if (score > 0 && (bestMatch == null || score > bestMatch.score)) {
            bestMatch = _ClassifierMatch(
              bin: bin,
              detectedLabel: label,
              keyword: keyword,
              score: score,
            );
          }
        }
      }
    }

    return bestMatch;
  }

  static double _calculateScore(String label, String keyword) {
    if (label == keyword) return 1.0;

    if (label.contains(keyword)) return 0.9;

    if (keyword.contains(label) && !_genericLabels.contains(label)) {
      return 0.75;
    }

    final labelWords = label.split(RegExp(r'\s+'));
    final keywordWords = keyword.split(RegExp(r'\s+'));

    final sharedWords = labelWords
        .where((word) => keywordWords.contains(word) && word.length > 2)
        .length;

    if (sharedWords == 0) return 0;

    return 0.45 + (sharedWords * 0.1).clamp(0, 0.35);
  }
}

class _ClassifierMatch {
  final String bin;
  final String detectedLabel;
  final String keyword;
  final double score;

  const _ClassifierMatch({
    required this.bin,
    required this.detectedLabel,
    required this.keyword,
    required this.score,
  });
}
