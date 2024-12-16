import 'package:flutter/material.dart';
import 'package:kalori/entry_point.dart';
import 'screen_export.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case logInScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      );
    case signUpScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const SignUpScreen(),
      );
    case entryPointScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const EntryPoint(),
      );
    case setUsernameScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const SetUsernameScreen(),
      );
    case passwordRecoveryScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const PasswordRecoveryScreen(),
      );
    case termsOfServicesScreenRoute:
      return MaterialPageRoute(builder: (_) => const TermsOfServiceScreen());
    default:
      return MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      );
  }

}