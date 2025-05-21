import 'package:athena/features/auth/presentation/views/login_screen.dart'; // Uses LoginMethod from login_screen.dart
import 'package:flutter/material.dart';

// enum LoginMethod { emailPasswordSocial, magicLink } // Removed: Enum will be used from login_screen.dart

class LoginMethodToggle extends StatelessWidget {
  final LoginMethod
  selectedMethod; // This will now correctly refer to LoginMethod from login_screen.dart
  final ValueChanged<LoginMethod> onMethodSelected;

  const LoginMethodToggle({
    super.key,
    required this.selectedMethod,
    required this.onMethodSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Using ToggleButtons for a standard tab-like feel
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ToggleButtons(
        isSelected: [
          selectedMethod == LoginMethod.emailPasswordSocial,
          selectedMethod == LoginMethod.magicLink,
        ],
        onPressed: (int index) {
          if (index == 0) {
            onMethodSelected(LoginMethod.emailPasswordSocial);
          } else {
            onMethodSelected(LoginMethod.magicLink);
          }
        },
        borderRadius: BorderRadius.circular(8.0),
        selectedBorderColor: Theme.of(context).primaryColor,
        selectedColor: Colors.white,
        fillColor: Theme.of(context).primaryColor.withValues(alpha: 0.8),
        color: Theme.of(context).primaryColor,
        constraints: BoxConstraints(
          minHeight: 40.0,
          minWidth:
              (MediaQuery.of(context).size.width - 40 - 48 - 16) /
              2, // Approximation for width based on card padding
        ),
        children: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('Credentials & Social'),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('Magic Link'),
          ),
        ],
      ),
    );
  }
}
