import 'dart:math';

/// Service managing offline local search history and fuzzy query matching for PIchiPlayer
class SearchHistoryService {
  static final List<String> _history = [
    'Interstellar',
    'Dune',
    'Documentary',
    'Batman',
    '4K HDR',
  ];

  /// Get current recent searches (maximum 8 items)
  static List<String> getRecentSearches() {
    return List<String>.unmodifiable(_history);
  }

  /// Add a search term to history (deduplicated, newest first)
  static void addSearch(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    _history.removeWhere((item) => item.toLowerCase() == trimmed.toLowerCase());
    _history.insert(0, trimmed);
    if (_history.length > 8) {
      _history.removeLast();
    }
  }

  /// Remove a specific search term from history
  static void removeSearch(String query) {
    _history.removeWhere((item) => item.toLowerCase() == query.toLowerCase());
  }

  /// Clear all recent searches
  static void clearHistory() {
    _history.clear();
  }

  /// Reset to sample initial history (for testing/demo)
  static void resetToDefault() {
    _history
      ..clear()
      ..addAll(['Interstellar', 'Dune', 'Documentary', 'Batman', '4K HDR']);
  }

  /// Normalized local search matching.
  /// Matches title, filename, or directory path ignoring punctuation and case.
  static bool matches(String query, String textToSearch) {
    final q = normalize(query);
    final target = normalize(textToSearch);
    return target.contains(q);
  }

  /// Normalizes strings by replacing dots, hyphens, and underscores with spaces
  static String normalize(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[\._\-]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Lightweight fuzzy matching for typo detection (e.g. "interstelar" -> "Interstellar")
  /// Returns the closest matching candidate if similarity is high enough.
  static String? findFuzzySuggestion(String query, List<String> candidates) {
    final normalizedQuery = normalize(query);
    if (normalizedQuery.length < 3) return null;

    String? bestMatch;
    int lowestDistance = 999;

    for (final candidate in candidates) {
      final normalizedCandidate = normalize(candidate);

      // Direct exact match doesn't need a typo suggestion
      if (normalizedCandidate.contains(normalizedQuery)) {
        return null;
      }

      // Check distance against candidate words
      final words = normalizedCandidate.split(' ');
      for (final word in words) {
        if (word.length < 3) continue;
        final dist = _levenshtein(normalizedQuery, word);
        // If distance is 1 or 2 edits away
        if (dist <= 2 && dist < lowestDistance && dist > 0) {
          lowestDistance = dist;
          bestMatch = candidate;
        }
      }

      // Also check full candidate title distance if lengths are close
      if ((normalizedQuery.length - normalizedCandidate.length).abs() <= 3) {
        final dist = _levenshtein(normalizedQuery, normalizedCandidate);
        if (dist <= 2 && dist < lowestDistance && dist > 0) {
          lowestDistance = dist;
          bestMatch = candidate;
        }
      }
    }

    return bestMatch;
  }

  /// Computes Levenshtein distance between two strings
  static int _levenshtein(String s, String t) {
    if (s == t) return 0;
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;

    List<int> v0 = List<int>.filled(t.length + 1, 0);
    List<int> v1 = List<int>.filled(t.length + 1, 0);

    for (int i = 0; i < v0.length; i++) {
      v0[i] = i;
    }

    for (int i = 0; i < s.length; i++) {
      v1[0] = i + 1;
      for (int j = 0; j < t.length; j++) {
        final cost = (s[i] == t[j]) ? 0 : 1;
        v1[j + 1] = min(v1[j] + 1, min(v0[j + 1] + 1, v0[j] + cost));
      }
      for (int j = 0; j < v0.length; j++) {
        v0[j] = v1[j];
      }
    }

    return v1[t.length];
  }
}
