import 'package:flutter_test/flutter_test.dart';
import 'package:roadside_x_pro/app.dart';

void main() {
  testWidgets('Roadside X Pro starts', (tester) async {
    await tester.pumpWidget(const RoadsideXApp());
    await tester.pump();

    expect(find.byType(RoadsideXApp), findsOneWidget);
  });
}
