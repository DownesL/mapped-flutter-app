import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapped/models/event.dart';
import 'package:mapped/pages/make_event_page.dart';

main() {
  testWidgets("submit empty form test", (WidgetTester tester) async {
    var nameError = find.text("Please enter a title");
    var descriptionError = find.text("Please enter a description");
    var addressError = find.text('Please enter an address');
    var numberError = find.text('Please enter a number');

    var submitBtn = find.byKey(const Key("submit-btn"));

    await tester.pumpWidget(const MakeEventPage(eventType: EventType.public));
    await tester.tap(submitBtn);

    expect(nameError, findsOneWidget);
    expect(descriptionError, findsOneWidget);
    expect(addressError, findsOneWidget);
    expect(numberError, findsOneWidget);
  });
  testWidgets("submit empty field test", (WidgetTester tester) async {
    var nameField = find.text("Title:");
    var descriptionField = find.text("Description:");
    var numberField = find.text('Number: ');

    var nameError = find.text("Please enter a title");
    var descriptionError = find.text("Please enter a description");
    var numberError = find.text('Please enter a number');

    var fieldList = [nameField, descriptionField, numberField];
    var errorList = [nameError, descriptionError, numberError];

    var submitBtn = find.byKey(const Key("submit-btn"));

    await tester.pumpWidget(const MakeEventPage(eventType: EventType.public));

    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        if (j == i) {
          await tester.enterText(fieldList[j], "");
        } else {
          await tester.enterText(fieldList[j], "Ok");
        }
      }
      await tester.tap(submitBtn);
      for (int j = 0; j < 4; j++) {
        if (j == i) {
          expect(errorList[j], findsNothing);
        } else {
          expect(errorList[j], findsOneWidget);
        }
      }
    }
  });
  testWidgets("Enter address test", (WidgetTester tester) async {
    /* Niet interessant verder uit te werken want static methodes kunnen niet
    * gemocked worden.
    *
    * */
    var addressField = find.text('Address: ');
    var addressError = find.text('Please enter an address');

    var submitBtn = find.byKey(const Key("submit-btn"));

    await tester.tap(submitBtn);

    expect(addressError, findsOneWidget);

    await tester.enterText(addressField, "Gent, 9000");

    var possibleAddresses = find.byType(ListTile);

    expect(possibleAddresses, findsAtLeastNWidgets(1));

    await tester.tap(possibleAddresses.first);

    await tester.tap(submitBtn);

    expect(addressError, findsNothing);

  });
}
