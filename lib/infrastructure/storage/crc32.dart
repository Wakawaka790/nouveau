/// CRC-32 (polynôme IEEE 802.3, 0xEDB88320), calculé octet par octet.
///
/// Utilisé pour détecter la corruption de l'état persistant (REQ-040,
/// Tableau A.3 #4 : codes de détection d'erreurs).
abstract final class Crc32 {
  static final List<int> _table = _buildTable();

  static List<int> _buildTable() {
    final table = List<int>.filled(256, 0);
    for (var i = 0; i < 256; i++) {
      var value = i;
      for (var bit = 0; bit < 8; bit++) {
        value = (value & 1) != 0 ? 0xEDB88320 ^ (value >> 1) : value >> 1;
      }
      table[i] = value & 0xFFFFFFFF;
    }
    return table;
  }

  /// CRC-32 de [bytes], rendu sous forme de 8 caractères hexadécimaux.
  static String hex(List<int> bytes) {
    var crc = 0xFFFFFFFF;
    for (final byte in bytes) {
      crc = _table[(crc ^ byte) & 0xFF] ^ (crc >> 8);
    }
    final value = (crc ^ 0xFFFFFFFF) & 0xFFFFFFFF;
    return value.toRadixString(16).padLeft(8, '0');
  }
}
