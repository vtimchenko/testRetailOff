import 'package:flutter/widgets.dart';
import 'package:google_sign_in_web/web_only.dart';

/// Google Identity Services button. Web does not allow a custom sign-in button.
Widget buildPlatformSignInButton() {
  return renderButton(
    configuration: GSIButtonConfiguration(
      type: GSIButtonType.standard,
      theme: GSIButtonTheme.filledBlack,
      size: GSIButtonSize.large,
      text: GSIButtonText.signinWith,
      shape: GSIButtonShape.rectangular,
      minimumWidth: 280,
      locale: 'en',
    ),
  );
}
