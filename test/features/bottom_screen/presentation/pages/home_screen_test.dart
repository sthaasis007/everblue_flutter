import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:everblue/features/bottom_screen/presentation/pages/home_screen.dart';

// Fake asset bundle so Image.asset doesn't fail in tests
class TestAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    // If an image is requested, return a tiny valid 1x1 PNG so decoding succeeds.
    if (key.endsWith('.png') || key.endsWith('.jpg') || key.endsWith('.jpeg')) {
      const String k1x1PngBase64 =
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR4nGNgYAAAAAMAASsJTYQAAAAASUVORK5CYII=';
      final bytes = base64Decode(k1x1PngBase64);
      return ByteData.view(Uint8List.fromList(bytes).buffer);
    }
    return ByteData.view(Uint8List(1).buffer); // 1 dummy byte for non-image assets
  }

  @override
  Future<T> loadStructuredBinaryData<T>(String key, FutureOr<T> Function(ByteData) parser) async {
    // Provide an empty asset manifest so image decoding doesn't try to parse a null value.
    if (key.contains('AssetManifest')) {
      // Encode an empty manifest using StandardMessageCodec so the parser
      // (which expects a codec message) returns a proper AssetManifest.
      final codec = StandardMessageCodec();
      final Object? encoded = codec.encodeMessage(<String, List<String>>{});
      ByteData data;
      if (encoded is ByteData) {
        data = encoded;
      } else if (encoded is Uint8List) {
        data = ByteData.view(encoded.buffer);
      } else {
        data = ByteData(0);
      }
      final result = parser(data);
      return result as T;
    }
    return super.loadStructuredBinaryData<T>(key, parser);
  }
}

void main() {
  testWidgets('HomeScreen shows headings and lists', (WidgetTester tester) async {
    await tester.pumpWidget(
      DefaultAssetBundle(
        bundle: TestAssetBundle(),
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    // check headings
    expect(find.text('Top Seller'), findsOneWidget);
    expect(find.text('Browse more'), findsOneWidget);

    // ListView.builder itemCount = 10 => should render some circles
    // It may not build all 10 at once depending on viewport, so we check ListView exists.
    expect(find.byType(ListView), findsOneWidget);

    // GridView.count with 10 Containers
    expect(find.byType(GridView), findsOneWidget);

    // Because each grid cell is Container(color: Colors.red)
    // we can check at least one red container exists.
    expect(find.byWidgetPredicate((w) {
      return w is Container && w.color == Colors.red;
    }), findsWidgets);
  });
}
