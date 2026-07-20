// A small, self-contained widget test that does not touch network or
// database code (those require platform plugins that aren't available in
// the plain widget-test environment). It verifies the StarRating widget —
// one of the app's core reusable components — renders and responds to taps.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soundscout/widgets/star_rating.dart';

void main() {
  testWidgets('StarRating shows the correct number of filled stars', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: StarRating(rating: 3)),
      ),
    );

    expect(find.byIcon(Icons.star), findsNWidgets(3));
    expect(find.byIcon(Icons.star_border), findsNWidgets(2));
  });

  testWidgets('Editable StarRating calls onChanged when a star is tapped', (tester) async {
    int? tapped;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StarRating(
            rating: 0,
            editable: true,
            onChanged: (value) => tapped = value,
          ),
        ),
      ),
    );

    // Tap the 4th star icon.
    final stars = find.byIcon(Icons.star_border);
    await tester.tap(stars.at(3));
    await tester.pump();

    expect(tapped, 4);
  });
}
