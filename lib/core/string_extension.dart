extension StringX on String {
  bool get isBlank => trim().isEmpty; // 只包含空白也算空
  String? nullIfBlank() => isBlank ? null : this; // 空白 -> null
  String capitalize() => isEmpty
      ? this
      : // Hello
        this[0].toUpperCase() + substring(1);
  String toSnakeCase() => // veryBasicExample -> very_basic_example
  replaceAllMapped(
    RegExp(r'([a-z0-9])([A-Z])'),
    (m) => '${m[1]}_${m[2]}',
  ).toLowerCase();
}

extension NullableStringX on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
  bool get isNullOrBlank => this == null || this!.trim().isEmpty;
  bool get isNullOrBlankOrEmpty =>
      this == null || this!.isEmpty || this!.trim().isEmpty;
  String orEmpty() => this ?? '';
}
