import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../config/theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _usernameController;
  late TextEditingController _phoneController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  late TextEditingController _targetWeightController;
  late TextEditingController _dailyCaloriesController;
  late TextEditingController _waterGoalController;

  String? _selectedGender;
  String? _selectedActivityLevel;
  DateTime? _selectedDateOfBirth;
  bool _isLoading = false;
  String? _profilePicturePath;
  final ImagePicker _picker = ImagePicker();

  final List<String> _genderOptions = ['Male', 'Female', 'Other'];
  final List<String> _activityLevels = [
    'Sedentary',
    'Lightly Active',
    'Moderately Active',
    'Very Active',
    'Extra Active'
  ];

  // Helper methods to convert between display and storage formats
  String _activityLevelToDisplay(String storageValue) {
    const mapping = {
      'sedentary': 'Sedentary',
      'lightly_active': 'Lightly Active',
      'moderately_active': 'Moderately Active',
      'very_active': 'Very Active',
      'extra_active': 'Extra Active',
    };
    return mapping[storageValue] ?? 'Sedentary';
  }

  String _activityLevelToStorage(String displayValue) {
    const mapping = {
      'Sedentary': 'sedentary',
      'Lightly Active': 'lightly_active',
      'Moderately Active': 'moderately_active',
      'Very Active': 'very_active',
      'Extra Active': 'extra_active',
    };
    return mapping[displayValue] ?? 'sedentary';
  }

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);

    _fullNameController = TextEditingController(text: user?.fullName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _usernameController = TextEditingController(text: user?.username ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _weightController = TextEditingController(
      text: user?.weight != null ? user!.weight.toString() : '',
    );
    _heightController = TextEditingController(
      text: user?.height != null ? user!.height.toString() : '',
    );
    _targetWeightController = TextEditingController(
      text: user?.targetWeight != null ? user!.targetWeight.toString() : '',
    );
    _dailyCaloriesController = TextEditingController(
      text: user?.dailyCalorieGoal.toString() ?? '2000',
    );
    _waterGoalController = TextEditingController(
      text: user?.dailyWaterGoalMl.toString() ?? '2000',
    );

    _selectedGender = user?.gender;
    _selectedActivityLevel = user?.activityLevel != null 
        ? _activityLevelToDisplay(user!.activityLevel) 
        : null;
    _selectedDateOfBirth = user?.dateOfBirth;
    _profilePicturePath = user?.profilePictureUrl;
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _profilePicturePath = image.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppTheme.primaryGreen),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppTheme.primaryGreen),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _targetWeightController.dispose();
    _dailyCaloriesController.dispose();
    _waterGoalController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = ref.read(currentUserProvider);
      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      final updatedUser = UserModel(
        id: currentUser.id,
        email: _emailController.text.trim().toLowerCase(),
        username: _usernameController.text.trim(),
        fullName: _fullNameController.text.trim().isEmpty
            ? null
            : _fullNameController.text.trim(),
        gender: _selectedGender,
        dateOfBirth: _selectedDateOfBirth,
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        profilePictureUrl: _profilePicturePath,
        weight: _weightController.text.isEmpty
            ? null
            : double.tryParse(_weightController.text),
        height: _heightController.text.isEmpty
            ? null
            : double.tryParse(_heightController.text),
        targetWeight: _targetWeightController.text.isEmpty
            ? null
            : double.tryParse(_targetWeightController.text),
        activityLevel: _selectedActivityLevel != null 
            ? _activityLevelToStorage(_selectedActivityLevel!) 
            : 'sedentary',
        dailyCalorieGoal: _dailyCaloriesController.text.isEmpty
            ? 2000
            : int.tryParse(_dailyCaloriesController.text) ?? 2000,
        dailyWaterGoalMl: _waterGoalController.text.isEmpty
            ? 2000
            : int.tryParse(_waterGoalController.text) ?? 2000,
        createdAt: currentUser.createdAt,
        updatedAt: DateTime.now(),
        notificationPreferences: currentUser.notificationPreferences,
      );

      await ref.read(currentUserProvider.notifier).updateUser(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightPeach,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryGreen,
        title: const Text('Edit Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profile Picture Section
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
                        backgroundImage: _profilePicturePath != null && _profilePicturePath!.isNotEmpty
                            ? (_profilePicturePath!.startsWith('http')
                                ? NetworkImage(_profilePicturePath!)
                                : FileImage(File(_profilePicturePath!)) as ImageProvider)
                            : null,
                        child: _profilePicturePath == null || _profilePicturePath!.isEmpty
                            ? Icon(
                                Icons.person,
                                size: 60,
                                color: AppTheme.primaryGreen.withOpacity(0.5),
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: _showImageSourceDialog,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryGreen,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Personal Information Section
                Text(
                  'Personal Information',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _fullNameController,
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  validator: Validators.validateName,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _usernameController,
                  label: 'Username',
                  hint: 'Enter your username',
                  validator: (value) => Validators.validateRequired(value, 'Username'),
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'Enter your email',
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  hint: 'Enter your phone number',
                  keyboardType: TextInputType.phone,
                  validator: Validators.validatePhone,
                ),
                const SizedBox(height: 16),

                // Gender Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: const InputDecoration(
                    labelText: 'Gender',
                  ),
                  items: _genderOptions.map((gender) {
                    return DropdownMenuItem(
                      value: gender,
                      child: Text(gender),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Date of Birth
                InkWell(
                  onTap: _selectDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date of Birth',
                    ),
                    child: Text(
                      _selectedDateOfBirth != null
                          ? '${_selectedDateOfBirth!.day}/${_selectedDateOfBirth!.month}/${_selectedDateOfBirth!.year}'
                          : 'Select your date of birth',
                      style: TextStyle(
                        color: _selectedDateOfBirth != null
                            ? Colors.black87
                            : Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Health Metrics Section
                Text(
                  'Health Metrics',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _weightController,
                  label: 'Current Weight (kg)',
                  hint: 'Enter your weight',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) return null;
                    final weight = double.tryParse(value);
                    return Validators.validateWeight(weight);
                  },
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _heightController,
                  label: 'Height (cm)',
                  hint: 'Enter your height',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) return null;
                    final height = double.tryParse(value);
                    return Validators.validateHeight(height);
                  },
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _targetWeightController,
                  label: 'Target Weight (kg)',
                  hint: 'Enter your target weight',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) return null;
                    final weight = double.tryParse(value);
                    return Validators.validateWeight(weight);
                  },
                ),
                const SizedBox(height: 16),

                // Activity Level Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedActivityLevel,
                  decoration: const InputDecoration(
                    labelText: 'Activity Level',
                  ),
                  items: _activityLevels.map((level) {
                    return DropdownMenuItem(
                      value: level,
                      child: Text(level),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedActivityLevel = value;
                    });
                  },
                ),
                const SizedBox(height: 32),

                // Goals Section
                Text(
                  'Daily Goals',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _dailyCaloriesController,
                  label: 'Daily Calories Goal',
                  hint: 'Enter your daily calorie goal',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _waterGoalController,
                  label: 'Daily Water Goal (ml)',
                  hint: 'Enter your daily water goal',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 32),

                // Save Button
                Center(
                  child: CustomButton(
                    text: 'SAVE CHANGES',
                    onPressed: _handleSave,
                    isLoading: _isLoading,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
