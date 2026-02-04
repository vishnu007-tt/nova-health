import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';

class InputPage extends StatefulWidget {
  const InputPage({super.key});

  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  String? _selectedType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGreen,
      appBar: AppBar(
        title: const Text('Daily Input'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s Input',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.primaryGreen,
                  width: 0.3,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedType,
                  isExpanded: true,
                  hint: const Text('Select an option'),
                  items: const [
                    DropdownMenuItem(value: 'WORKOUT', child: Text('WORKOUT')),
                    DropdownMenuItem(value: 'HYDRATION', child: Text('HYDRATION')),
                    DropdownMenuItem(value: 'FOOD', child: Text('FOOD')),
                    DropdownMenuItem(value: 'SYMPTOMS', child: Text('SYMPTOMS')),
                    DropdownMenuItem(value: 'PERIOD_TRACKER', child: Text('PERIOD TRACKER')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 30),
            if (_selectedType != null) ...[
              Center(
                child: ElevatedButton.icon(
                  onPressed: () => _navigateToInputPage(context),
                  icon: const Icon(Icons.arrow_forward),
                  label: Text('Go to $_selectedType'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _navigateToInputPage(BuildContext context) {
    String route;
    switch (_selectedType) {
      case 'WORKOUT':
        route = AppRoutes.workoutLog;
        break;
      case 'HYDRATION':
        route = AppRoutes.hydration;
        break;
      case 'FOOD':
        route = AppRoutes.nutrition;
        break;
      case 'SYMPTOMS':
        route = AppRoutes.symptoms;
        break;
      case 'PERIOD_TRACKER':
        route = AppRoutes.periodTracker;
        break;
      default:
        return;
    }
    Navigator.pushNamed(context, route);
  }
}
