import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../services/database_service.dart';
import '../../providers/auth_provider.dart';

/// Health data consent screen
/// - Shown ONCE per user
/// - During signup OR first login after patch
class HealthDataConsentPage extends ConsumerStatefulWidget {
  /// If true: user came from signup flow
  /// If false: user came from login flow
  final bool fromSignup;

  const HealthDataConsentPage({super.key, this.fromSignup = false});

  @override
  ConsumerState<HealthDataConsentPage> createState() => _HealthDataConsentPageState();
}

class _HealthDataConsentPageState extends ConsumerState<HealthDataConsentPage> {
  bool _consentChecked = false;
  bool _isSaving = false;

  Future<void> _handleAccept() async {
    final currentUser = ref.read(currentUserProvider);
    if (!_consentChecked || currentUser == null) return;

    setState(() => _isSaving = true);

    final db = DatabaseService();

    // ✅ Store consent PER USER (ONCE)
    await db.saveSetting('consent_${currentUser.id}', true);

    if (!mounted) return;

    // ✅ Route correctly depending on flow
    if (widget.fromSignup) {
      // Return to signup → next step (gender)
      Navigator.pop(context);
    } else {
      // From login → go directly to home
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightPeach,
      appBar: AppBar(
        backgroundColor: AppTheme.lightPeach,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Health Data Consent',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.health_and_safety,
                size: 64,
                color: AppTheme.primaryGreen,
              ),
              const SizedBox(height: 20),

              Text(
                'Your Privacy Matters',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 12),

              Text(
                'To provide personalized health insights, NovaHealth needs your consent to securely store and process your health data.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),

              _infoPoint('Your data is stored securely'),
              _infoPoint('Used only to provide insights to you'),
              _infoPoint('Never sold or shared without permission'),
              _infoPoint('You can revoke consent anytime from Settings'),

              const SizedBox(height: 32),

              Row(
                children: [
                  Checkbox(
                    value: _consentChecked,
                    activeColor: AppTheme.primaryGreen,
                    onChanged: (value) {
                      setState(() {
                        _consentChecked = value ?? false;
                      });
                    },
                  ),
                  const Expanded(
                    child: Text(
                      'I agree to the collection and processing of my health data as described above.',
                    ),
                  ),
                ],
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      _consentChecked && !_isSaving ? _handleAccept : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppTheme.primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      _isSaving
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : const Text(
                            'Accept and Continue',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            size: 18,
            color: AppTheme.primaryGreen,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
