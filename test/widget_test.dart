import 'package:flutter_test/flutter_test.dart';
import 'package:giftswale/app.dart';

void main() {
  testWidgets('App renders home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const GiftsWaleApp());
    expect(find.text('GiftsWale'), findsOneWidget);
  });
}
