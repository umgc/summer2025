import 'dart:html' as html;
import 'dart:typed_data';

// Web-specific utilities for file downloads
void downloadFile(String fileName, dynamic bytes) {
  final Uint8List data;
  if (bytes is Uint8List) {
    data = bytes;
  } else if (bytes is List<int>) {
    data = Uint8List.fromList(bytes);
  } else {
    throw ArgumentError('Unsupported bytes type: ${bytes.runtimeType}');
  }

  final blob = html.Blob([data]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.document.createElement('a') as html.AnchorElement
    ..href = url
    ..style.display = 'none'
    ..download = fileName;
  html.document.body!.children.add(anchor);
  anchor.click();
  html.document.body!.children.remove(anchor);
  html.Url.revokeObjectUrl(url);
}
