import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toastification/toastification.dart';
import 'package:zefyr/common/themes/app_themes.dart';
import 'package:zefyr/core/app/router/router.dart';
import 'package:zefyr/l10n/app_localizations.dart';
import 'package:zefyr/l10n/l10n.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return ToastificationWrapper(
      config: const ToastificationConfig(
        
       
      ),
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
        child: MaterialApp.router(
          title: 'Zefyr',
          debugShowCheckedModeBanner: false,
          locale: const Locale('ru'),
          theme: AppTheme.darkTheme,
          routerConfig: router,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: L10n.all,
        ),
      ),
    );
  }
}
