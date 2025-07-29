// Run this file to generate mocks: dart run build_runner build
import 'package:mockito/annotations.dart';
import 'package:stashcard/providers/db.dart';

@GenerateMocks([DatabaseHelper])
void main() {}