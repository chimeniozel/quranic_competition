import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:quranic_competition/auth/login_screen.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/firebase_options.dart';
import 'package:quranic_competition/providers/auth_provider.dart'
    as auth_provider;
import 'package:quranic_competition/providers/auth_provider.dart';
import 'package:quranic_competition/providers/competion_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => auth_provider.AuthProvider()..getUsers()),
        ChangeNotifierProvider(
            create: (_) => CompetitionProvider()..getCurrentCompetition()),
      ],
      child: MaterialApp(
        title: 'Quranic Competition App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: "Tajawal",
          colorScheme: const ColorScheme.light(
            surface: AppColors.whiteColor,
          ),
          useMaterial3: true,
        ),
        locale: const Locale("ar", "AR"),
        supportedLocales: const [
          Locale("ar", "AR"),
        ],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate
        ],
        home: Consumer2<CompetitionProvider, AuthProvider>(
            builder: (context, competitionProvider, authProvider, child) {
          if (competitionProvider.isLoading || authProvider.isLoading) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          return const LoginScreen();
        }),
      ),
    );
  }
}
