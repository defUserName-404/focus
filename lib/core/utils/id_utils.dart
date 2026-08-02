import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Generates a random UUID v4 string for sync identity and device provenance.
String generateUuid() => _uuid.v4();
