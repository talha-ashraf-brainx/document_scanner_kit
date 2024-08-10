import 'package:document_scanner_kit_android/document_scanner_kit_android.dart';
import 'package:document_scanner_kit_platform_interface/document_scanner_kit_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DocumentScannerKitAndroid', () {
    const kPlatformName = 'Android';
    late DocumentScannerKitAndroid documentScannerKit;
    late List<MethodCall> log;

    setUp(() async {
      documentScannerKit = DocumentScannerKitAndroid();

      log = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(documentScannerKit.methodChannel, (methodCall) async {
        log.add(methodCall);
        switch (methodCall.method) {
          case 'getPlatformName':
            return kPlatformName;
          default:
            return null;
        }
      });
    });

    test('can be registered', () {
      DocumentScannerKitAndroid.registerWith();
      expect(DocumentScannerKitPlatform.instance, isA<DocumentScannerKitAndroid>());
    });

    test('getPlatformName returns correct name', () async {
      final name = await documentScannerKit.getPlatformName();
      expect(
        log,
        <Matcher>[isMethodCall('getPlatformName', arguments: null)],
      );
      expect(name, equals(kPlatformName));
    });
  });
}
