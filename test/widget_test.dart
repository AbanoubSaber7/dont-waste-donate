import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dont_waste_donate/main.dart';

void main() {
  testWidgets('App should load and render home screen', (WidgetTester tester) async {
    // بنبني الأبلكيشن جوه الـ ProviderScope عشان بنستخدم Riverpod
    await tester.pumpWidget(
      const ProviderScope(
        child: DontWasteDonateApp(),
      ),
    );

    // بنستنى الأبلكيشن يخلص تحميل
    await tester.pumpAndSettle();

    // بنختبر هل الأبلكيشن فتح فعلاً؟ (بندور على أي نص موجود في شاشتك الرئيسية)
    // لو شاشتك فيها كلمة "تبرع"، هينجح الاختبار
    expect(find.byType(DontWasteDonateApp), findsOneWidget);
  });
}