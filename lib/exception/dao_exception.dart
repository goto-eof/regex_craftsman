class DaoException implements Exception {
  DaoException({required this.cause});
  String cause;

  @override
  String toString() {
    return cause;
  }
}
