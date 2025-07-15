import 'package:flutter/material.dart';
import 'package:password_strength_checker/password_strength_checker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:zxcvbn/zxcvbn.dart';

class PasswordStrengthChecker extends StatefulWidget {
  const PasswordStrengthChecker({super.key});

  @override
  State<PasswordStrengthChecker> createState() => _PasswordStrengthCheckerState();
}

class _PasswordStrengthCheckerState extends State<PasswordStrengthChecker> {
  final TextEditingController _passwordController = TextEditingController();
  PasswordStrength _strength = PasswordStrength.weak;
  String _feedbackMessage = '';

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_checkPasswordStrength);
    _checkPasswordStrength();
  }

  @override
  void dispose() {
    _passwordController.removeListener(_checkPasswordStrength);
    _passwordController.dispose();
    super.dispose();
  }

  void _checkPasswordStrength() {
    final password = _passwordController.text;
    if (password.isEmpty) {
      setState(() {
        _strength = PasswordStrength.weak;
        _feedbackMessage = 'Enter a password to check its strength.'.tr();
      });
      return;
    }

    final zxcvbn = Zxcvbn();
    final result = zxcvbn.evaluate(password);
    PasswordStrength newStrength;
    switch (result.score) {
      case 0:
      case 1:
        newStrength = PasswordStrength.weak;
        break;
      case 2:
        newStrength = PasswordStrength.medium;
        break;
      case 3:
        newStrength = PasswordStrength.strong;
        break;
      case 4:
        newStrength = PasswordStrength.secure;
        break;
      default:
        newStrength = PasswordStrength.weak;
    }

    setState(() {
      _strength = newStrength;
      _feedbackMessage = _getFeedbackMessage(newStrength, result.feedback?.suggestions ?? []);
    });
  }

  String _getFeedbackMessage(PasswordStrength strength, List<String> suggestions) {
    if (_passwordController.text.isEmpty) {
      return 'Enter a password to check its strength.'.tr();
    }

    String baseMessage;
    switch (strength) {
      case PasswordStrength.alreadyExposed:
        baseMessage = 'Warning: This password has been exposed in a data breach. Do NOT use it!'.tr();
        break;
      case PasswordStrength.weak:
        baseMessage = 'Weak: Too short or too simple. Avoid using common words. Needs more complexity.'.tr();
        break;
      case PasswordStrength.medium:
        baseMessage = 'Medium: Good start! Consider making it longer and more diverse.'.tr();
        break;
      case PasswordStrength.strong:
        baseMessage = 'Strong: Excellent! This password is hard to guess.'.tr();
        break;
      case PasswordStrength.secure:
        baseMessage = 'Secure: Superb! This password offers maximum protection.'.tr();
        break;
    }

    if (suggestions.isNotEmpty) {
      baseMessage += '\nSuggestions: ${suggestions.join(', ')}';
    }
    return baseMessage;
  }

  Color _getStrengthColor(PasswordStrength strength) {
    if (_passwordController.text.isEmpty) {
      return Colors.grey;
    }

    switch (strength) {
      case PasswordStrength.alreadyExposed:
        return Colors.deepPurple;
      case PasswordStrength.weak:
        return Colors.red;
      case PasswordStrength.medium:
        return Colors.orange;
      case PasswordStrength.strong:
        return Colors.lightGreen;
      case PasswordStrength.secure:
        return Colors.green;
    }
  }

  double _getStrengthValue(PasswordStrength strength) {
    if (_passwordController.text.isEmpty) {
      return 0.0;
    }

    switch (strength) {
      case PasswordStrength.alreadyExposed:
        return 0.1;
      case PasswordStrength.weak:
        return 0.25;
      case PasswordStrength.medium:
        return 0.5;
      case PasswordStrength.strong:
        return 0.75;
      case PasswordStrength.secure:
        return 1.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Password Strength Checker'.tr(),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Enter Password'.tr(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _getStrengthValue(_strength),
              valueColor: AlwaysStoppedAnimation<Color>(_getStrengthColor(_strength)),
              backgroundColor: Colors.grey[300],
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
            ),
            const SizedBox(height: 8),
            Text(
              _feedbackMessage,
              style: TextStyle(
                color: _getStrengthColor(_strength),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Tips for Strong Passwords:'.tr(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _buildTipItem('Use a mix of uppercase and lowercase letters.'.tr()),
            _buildTipItem('Include numbers and symbols.'.tr()),
            _buildTipItem('Make it at least 12 characters long.'.tr()),
            _buildTipItem('Avoid personal information or common words.'.tr()),
            _buildTipItem('Use a unique password for each account.'.tr()),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline, color: Theme.of(context).primaryColor, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}