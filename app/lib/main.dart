import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'constants/app_constants.dart';
import 'providers/app_provider.dart';
import 'screens/home_screen.dart';
import 'screens/vip_screen.dart';
import 'screens/results_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    navigationBarColor: Colors.white,
    navigationBarIconBrightness: Brightness.dark,
  ));
  runApp(ChangeNotifierProvider(
    create: (_) => AppProvider()..init(),
    child: const TeerApp(),
  ));
}

class TeerApp extends StatelessWidget {
  const TeerApp({super.key});
  @override Widget build(BuildContext context) => MaterialApp(
    title: 'Shillong Teer',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.bgPage,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.gold,
        surface: AppColors.bgCard,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bgHeader,
        foregroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
    ),
    home: const MainNav(),
  );
}

class MainNav extends StatefulWidget {
  const MainNav({super.key});
  @override State<MainNav> createState() => _MainNavState();
}

class _MainNavState extends State<MainNav> {
  int _i = 0;
  // IndexedStack keeps screens alive — no rebuild on tab switch
  static const _screens = [HomeScreen(), VipScreen(), ResultsScreen()];

  void _go(int i) { setState(() => _i = i); HapticFeedback.selectionClick(); }

  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.bgPage,
    body: IndexedStack(index: _i, children: _screens),
    bottomNavigationBar: _nav(),
  );

  Widget _nav() => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      border: const Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0,-3))],
    ),
    child: SafeArea(top: false, child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        _item(0, Icons.home_rounded,          Icons.home_outlined,           'Home'),
        _item(1, Icons.emoji_events_rounded,  Icons.emoji_events_outlined,   'VIP'),
        _item(2, Icons.history_rounded,       Icons.history_outlined,        'Results'),
      ]),
    )),
  );

  Widget _item(int idx, IconData active, IconData inactive, String label) {
    final sel = _i == idx;
    return Expanded(child: GestureDetector(
      onTap: () => _go(idx),
      behavior: HitTestBehavior.opaque,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.all(sel ? 8 : 6),
          decoration: BoxDecoration(
            color: sel ? AppColors.primaryL : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(sel ? active : inactive, color: sel ? AppColors.primary : AppColors.textMut, size: 22),
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: sel ? AppColors.primary : AppColors.textMut, fontSize: 10, fontWeight: sel ? FontWeight.w700 : FontWeight.w500)),
      ]),
    ));
  }
}
