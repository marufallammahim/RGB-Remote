extension StringExtensions on String {
  String formatName() {
    return replaceAll('_', ' ').capitalize();
  }

  String capitalize() {
    final words = trim().split(RegExp(r'\s+')).where((word) => word.isNotEmpty);
    return words
        .map((word) =>
            '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ');
  }
}
