import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/firebase_options.dart';
import 'package:quranic_competition/providers/auth_provider.dart';
import 'package:quranic_competition/providers/competion_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:quranic_competition/screens/admin/admin_home_screen.dart';
import 'package:quranic_competition/screens/client/home_screen.dart';
import 'package:quranic_competition/screens/jury/jury_home_screen.dart';
import 'package:quranic_competition/utils/utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  performExternalStorageTask();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => AuthProviders()
              ..getUser()
              ..getJurys()),
        ChangeNotifierProvider(
            create: (_) => CompetitionProvider()..getCurrentCompetition()),
      ],
      child: MaterialApp(
        title: 'Quranic Competition App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: "Tajawal",
          appBarTheme: const AppBarTheme(
              titleTextStyle: TextStyle(
                color: AppColors.whiteColor,
                fontWeight: FontWeight.w700,
                fontSize: 18.0,
                fontFamily: "Tajawal",
              ),
              iconTheme: IconThemeData(
                color: AppColors.whiteColor,
              )),
          colorScheme: const ColorScheme.light(
            surface: AppColors.whiteColor,
          ),
          useMaterial3: true,
        ),
        locale: const Locale("ar", "AR"),
        supportedLocales: const [
          Locale("ar", "AR"),
          Locale("en", "AR"),
        ],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate
        ],
        home: Consumer2<CompetitionProvider, AuthProviders>(
            builder: (context, competitionProvider, authProviders, child) {
          if (competitionProvider.isLoading || authProviders.isLoading) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (authProviders.user != null) {
            if (authProviders.user!.role == "إداري") {
              authProviders.setCurrentUser(authProviders.user!.userID!);
              return const AdminHomeScreen();
            } else {
              return const JuryHomeScreen();
            }
          }
          return const HomeScreen();
        }),
      ),
    );
  }
}
