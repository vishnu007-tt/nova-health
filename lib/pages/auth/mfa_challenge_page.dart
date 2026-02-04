import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../config/routes.dart';

class MfaChallengePage extends StatefulWidget {
  final FirebaseAuthMultiFactorException exception;

  const MfaChallengePage({super.key, required this.exception});

  @override
  State<MfaChallengePage> createState() => _MfaChallengePageState();
}

class _MfaChallengePageState extends State<MfaChallengePage> {
  final _codeController = TextEditingController();
  String? _verificationId;
  bool _isLoading = false;
  String? _error;

  PhoneMultiFactorInfo? _phoneInfo;

  @override
  void initState() {
    super.initState();
    _prepareChallenge();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _prepareChallenge() async {
    // Find phone factor hint safely
    final hints = widget.exception.resolver.hints;

    final phoneHints = hints.whereType<PhoneMultiFactorInfo>().toList();
    if (phoneHints.isEmpty) {
      setState(() {
        _error = 'No phone-based MFA factor available for this account.';
      });
      return;
    }

    _phoneInfo = phoneHints.first;

    // Trigger sending SMS for sign-in using the multi-factor session
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        multiFactorSession: widget.exception.resolver.session,
        multiFactorInfo: _phoneInfo!,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto verification (Android) — resolve sign-in and navigate to Home.
          try {
            final assertion = PhoneMultiFactorGenerator.getAssertion(credential);
            await widget.exception.resolver.resolveSignIn(assertion);

            if (!mounted) return;
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.home,
              (route) => false,
            );
          } catch (_) {
            // If resolution fails, show an error silently; user can enter code manually.
          }
        },
        verificationFailed: (e) {
          setState(() {
            _error = e.toString();
          });
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      setState(() {
        _error = 'Failed to send verification code: $e';
      });
    }
  }

  Future<void> _verifyCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty || _verificationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the SMS code')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: code,
      );

      final assertion = PhoneMultiFactorGenerator.getAssertion(credential);

      // Resolve the sign-in using the resolver from the original exception
      await widget.exception.resolver.resolveSignIn(assertion);

      if (!mounted) return;

      // On success, navigate to Home (only after verification)
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = e.message ?? e.toString();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MFA Verification')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            const Text(
              'Multi-Factor Authentication Required',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            const Text(
              'Enter the SMS code sent to your phone to complete sign-in.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            if (_phoneInfo != null)
              Text('Sending code to ${_phoneInfo!.phoneNumber ?? 'your phone'}'),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'SMS Code',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isLoading ? null : _verifyCode,
              child: _isLoading
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Verify'),
            ),
          ],
        ),
      ),
    );
  }
}
