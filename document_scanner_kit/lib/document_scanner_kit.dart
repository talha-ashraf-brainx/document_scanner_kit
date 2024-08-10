import 'package:document_scanner_kit_platform_interface/document_scanner_kit_platform_interface.dart';

DocumentScannerKitPlatform get _platform => DocumentScannerKitPlatform.instance;

/// Returns the name of the current platform.
Future<String> getPlatformName() async {
  final platformName = await _platform.getPlatformName();
  if (platformName == null) throw Exception('Unable to get platform name.');
  return platformName;
}

/// Starts the document scanner.
Future<List<String>?> scan() async {
  final scannedDocuments = await _platform.scan();
  return scannedDocuments;
}
