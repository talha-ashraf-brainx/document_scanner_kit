import 'package:document_scanner_kit_ios/document_scanner_kit_ios.dart';
import 'package:document_scanner_kit_platform_interface/document_scanner_kit_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DocumentScannerKitIOS', () {
    const kPlatformName = 'iOS';
    const kScanResult = ['path1', 'path2'];
    late DocumentScannerKitIOS documentScannerKit;
    late List<MethodCall> log;

    setUp(() async {
      documentScannerKit = DocumentScannerKitIOS();

      log = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(documentScannerKit.methodChannel,
              (methodCall) async {
        log.add(methodCall);
        switch (methodCall.method) {
          case 'getPlatformName':
            return kPlatformName;
          case 'scan':
            return kScanResult;
          default:
            return null;
        }
      });
    });

    test('can be registered', () {
      DocumentScannerKitIOS.registerWith();
      expect(DocumentScannerKitPlatform.instance, isA<DocumentScannerKitIOS>());
    });

    test('getPlatformName returns correct name', () async {
      final name = await documentScannerKit.getPlatformName();
      expect(
        log,
        <Matcher>[isMethodCall('getPlatformName', arguments: null)],
      );
      expect(name, equals(kPlatformName));
    });

    test('scan returns correct paths', () async {
      final result = await documentScannerKit.scan();
      expect(
        log,
        <Matcher>[isMethodCall('scan', arguments: null)],
      );
      expect(result, equals(kScanResult));
    });
  });
}
