import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../providers/auth_provider.dart';
import '../../utils/helpers.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppTheme.lightGreen,
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.editProfile);
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.settings);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );

              if (confirmed == true && context.mounted) {
                await ref.read(authStateProvider.notifier).logout(ref);
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.landing,
                    (route) => false,
                  );
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Profile header
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppTheme.primaryGreen,
                    backgroundImage: user?.profilePictureUrl != null && user!.profilePictureUrl!.isNotEmpty
                        ? (user.profilePictureUrl!.startsWith('http')
                            ? NetworkImage(user.profilePictureUrl!)
                            : FileImage(File(user.profilePictureUrl!)) as ImageProvider)
                        : null,
                    child: user?.profilePictureUrl == null || user!.profilePictureUrl!.isEmpty
                        ? Text(
                            (user?.username ?? 'U').substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.fullName ?? user?.username ?? 'User',
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 20),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? '',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        if (user?.age != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            '${user!.age} years old • ${user.gender ?? "Not specified"}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Health stats
            if (user?.weight != null || user?.height != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Health Stats',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          if (user?.weight != null)
                            _StatItem(
                              label: 'Weight',
                              value: Helpers.formatWeight(user!.weight!),
                            ),
                          if (user?.height != null)
                            _StatItem(
                              label: 'Height',
                              value: Helpers.formatHeight(user!.height!),
                            ),
                          if (user?.bmi != null)
                            _StatItem(
                              label: 'BMI',
                              value: user!.bmi!.toStringAsFixed(1),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Feature grid
            Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _FeatureCard(label: 'Meal Timer', icon: Icons.timer),
                  _FeatureCard(label: 'Stay Mindful', icon: Icons.self_improvement),
                  _FeatureCard(label: 'Your Workout', icon: Icons.fitness_center),
                  _FeatureCard(label: 'Your Diet', icon: Icons.restaurant_menu),
                  _FeatureCard(label: 'Habit Tracker', icon: Icons.check_circle),
                  _FeatureCard(label: 'Period Tracker', icon: Icons.calendar_today),
                  _FeatureCard(label: 'Stress Help', icon: Icons.spa),
                  _FeatureCard(label: 'Hydration', icon: Icons.water_drop),
                  _FeatureCard(label: 'AI Chatbot', icon: Icons.chat_bubble),
                  _FeatureCard(label: 'Security (MFA)', icon: Icons.security),
                ],
              ),
            ),

            // SOS button
            Container(
              margin: const EdgeInsets.all(16),
              width: double.infinity,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red, width: 2),
              ),
              child: Center(
                child: Text(
                  'SOS',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 20),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String label;
  final IconData icon;

  const _FeatureCard({required this.label, required this.icon});

  String? _getRoute(String label) {
    switch (label) {
      case 'Meal Timer':
        return AppRoutes.nutrition;
      case 'Stay Mindful':
        return AppRoutes.meditation;
      case 'Your Workout':
        return AppRoutes.workoutLog;
      case 'Your Diet':
        return AppRoutes.nutrition;
      case 'Habit Tracker':
        return null; // Coming soon
      case 'Period Tracker':
        return AppRoutes.periodTracker;
      case 'Stress Help':
        return AppRoutes.meditation;
      case 'Hydration':
        return AppRoutes.hydration;
      case 'AI Chatbot':
        return AppRoutes.chatbot;
      case 'Security (MFA)':
        return AppRoutes.mfaSettings;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final route = _getRoute(label);
    
    return InkWell(
      onTap: route != null
          ? () => Navigator.pushNamed(context, route)
          : () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$label coming soon!')),
              );
            },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: (MediaQuery.of(context).size.width - 56) / 2,
        height: 100,
        decoration: BoxDecoration(
          color: AppTheme.primaryGreen,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
