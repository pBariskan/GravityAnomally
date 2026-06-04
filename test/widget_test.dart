import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:strain/main.dart';
import 'package:strain/services/achievement_service.dart';
import 'package:strain/services/persistence_service.dart';

void main() {
  testWidgets('Strain app loads main menu', (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});

    final persistence = PersistenceService();
    final achievements = AchievementService(persistence);
    await achievements.load();

    await tester.pumpWidget(StrainApp(achievementService: achievements));
    await tester.pump();

    expect(find.text('STRAIN'), findsOneWidget);
    expect(find.text('START / CONTINUE'), findsOneWidget);
  });
}
