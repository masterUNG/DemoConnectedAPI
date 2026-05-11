import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:connectedapi/main.dart';

void main() {
  testWidgets('shows Thai login page', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('เข้าสู่ระบบ'), findsWidgets);
    expect(find.text('สมัครสมาชิก'), findsOneWidget);
    expect(find.text('อีเมล'), findsOneWidget);
    expect(find.text('รหัสผ่าน'), findsOneWidget);
    expect(find.text('Connected API'), findsOneWidget);
  });

  testWidgets('validates empty login form in Thai', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.ensureVisible(find.byType(FilledButton));
    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(find.text('กรุณากรอกอีเมล'), findsOneWidget);
    expect(find.text('กรุณากรอกรหัสผ่าน'), findsOneWidget);
  });
}
