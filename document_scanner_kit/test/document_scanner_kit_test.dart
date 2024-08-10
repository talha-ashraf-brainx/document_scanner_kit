import 'package:document_scanner_kit/document_scanner_kit.dart';
import 'package:document_scanner_kit_platform_interface/document_scanner_kit_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockDocumentScannerKitPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements DocumentScannerKitPlatform {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DocumentScannerKit', () {
    late DocumentScannerKitPlatform documentScannerKitPlatform;

    setUp(() {
      documentScannerKitPlatform = MockDocumentScannerKitPlatform();
      DocumentScannerKitPlatform.instance = documentScannerKitPlatform;
    });

    group('getPlatformName', () {
      test('returns correct name when platform implementation exists',
          () async {
        const platformName = '__test_platform__';
        when(
          () => documentScannerKitPlatform.getPlatformName(),
        ).thenAnswer((_) async => platformName);

        final actualPlatformName = await getPlatformName();
        expect(actualPlatformName, equals(platformName));
      });

      test('throws exception when platform implementation is missing',
          () async {
        when(
          () => documentScannerKitPlatform.getPlatformName(),
        ).thenAnswer((_) async => null);

        expect(getPlatformName, throwsException);
      });
    });
  });
}
