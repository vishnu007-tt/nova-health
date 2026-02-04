import 'package:flutter/material.dart';
import '../../config/theme.dart';

class LanguagePage extends StatelessWidget {
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGreen,
      appBar: AppBar(
        title: const Text('Language Support'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Your Language',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            Text(
              'Popular Languages',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            const _LanguageOption(name: 'English (US)'),
            const _LanguageOption(name: 'English (UK)'),
            const SizedBox(height: 20),
            Text(
              'Other Languages',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            const _LanguageOption(name: 'Mandarin'),
            const _LanguageOption(name: 'Spanish'),
            const _LanguageOption(name: 'Arabic'),
            const _LanguageOption(name: 'Hindi'),
            const _LanguageOption(name: 'French'),
            const _LanguageOption(name: 'Russian'),
            const _LanguageOption(name: 'Vietnamese'),
            const SizedBox(height: 20),
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Full multi-language support will be added in Stage 2',
                        style: TextStyle(color: Colors.blue.shade900),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String name;

  const _LanguageOption({required this.name});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(
          name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppTheme.darkGreen,
          ),
        ),
        trailing: const Icon(
          Icons.radio_button_unchecked,
          size: 24,
          color: Colors.green,
        ),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$name selected (functionality coming in Stage 2)')),
          );
        },
      ),
    );
  }
}
