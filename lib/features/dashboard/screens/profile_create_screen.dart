import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart
import '../providers/profile_provider.dart';
import '../models/social_link.dart';
import '../../../shared/widgets/loading_overlay.dart';

class CreateProfileScreen extends ConsumerStatefulWidget {
  const CreateProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends ConsumerState<CreateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _aboutController = TextEditingController();
  final List<SocialLink> _links = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^\+?[\d\s-]{10,}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  void _showPlatformSelectionDialog() {
    final platforms = {
      'WhatsApp': FontAwesomeIcons.whatsapp,
      'Instagram': FontAwesomeIcons.instagram,
      'Twitter/X': FontAwesomeIcons.twitter,
      'LinkedIn': FontAwesomeIcons.linkedin,
      'Email': FontAwesomeIcons.envelope,
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Social Link'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: platforms.entries.map((entry) {
              final isAlreadyAdded = _links.any(
                (link) => link.platform == entry.key.toLowerCase()
              );

              return ListTile(
                leading: FaIcon(entry.value),
                title: Text(entry.key),
                enabled: !isAlreadyAdded,
                onTap: isAlreadyAdded 
                  ? null 
                  : () {
                      Navigator.pop(context);
                      _showSocialLinkDialog(entry.key.toLowerCase());
                    },
                trailing: isAlreadyAdded 
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _showSocialLinkDialog(String platform) async {
    final TextEditingController linkController = TextEditingController();
    final existingLink = _links.firstWhere(
      (link) => link.platform == platform,
      orElse: () => SocialLink(platform: platform, url: ''),
    );
    
    linkController.text = existingLink.url;

    String hint = '';
    String? Function(String?)? validator;

    switch (platform) {
      case 'whatsapp':
        hint = 'Enter your phone number with country code';
        validator = (value) {
          if (value?.isEmpty ?? true) return null;
          if (!RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(value!)) {
            return 'Please enter a valid phone number';
          }
          return null;
        };
        break;
      case 'instagram':
        hint = 'Enter your Instagram username';
        validator = (value) {
          if (value?.isEmpty ?? true) return null;
          if (!RegExp(r'^[a-zA-Z0-9._]{1,30}$').hasMatch(value!)) {
            return 'Please enter a valid Instagram username';
          }
          return null;
        };
        break;
      case 'twitter':
        hint = 'Enter your Twitter/X username';
        validator = (value) {
          if (value?.isEmpty ?? true) return null;
          if (!RegExp(r'^[a-zA-Z0-9_]{1,15}$').hasMatch(value!)) {
            return 'Please enter a valid Twitter username';
          }
          return null;
        };
        break;
      case 'linkedin':
        hint = 'Enter your LinkedIn profile URL or username';
        validator = (value) {
          if (value?.isEmpty ?? true) return null;
          if (!value!.contains('linkedin.com/in/') && 
              !RegExp(r'^[a-zA-Z0-9-]{3,100}$').hasMatch(value)) {
            return 'Please enter a valid LinkedIn URL or username';
          }
          return null;
        };
        break;
      case 'email':
        hint = 'Enter your email address';
        validator = (value) {
          if (value?.isEmpty ?? true) return null;
          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
            return 'Please enter a valid email address';
          }
          return null;
        };
        break;
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            FaIcon(_getIconForPlatform(platform)),
            const SizedBox(width: 8),
            Text('Add $platform'),
          ],
        ),
        content: Form(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: linkController,
                decoration: InputDecoration(
                  hintText: hint,
                  helperText: hint,
                  helperMaxLines: 2,
                ),
                validator: validator,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _links.removeWhere((link) => link.platform == platform);
              Navigator.of(context).pop();
              setState(() {});
            },
            child: const Text('Remove'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (linkController.text.isNotEmpty) {
                String url = linkController.text;
                
                switch (platform) {
                  case 'whatsapp':
                    url = 'https://wa.me/${url.replaceAll(RegExp(r'[^0-9]'), '')}';
                    break;
                  case 'instagram':
                    url = 'https://instagram.com/${url.replaceAll('@', '')}';
                    break;
                  case 'twitter':
                    url = 'https://twitter.com/${url.replaceAll('@', '')}';
                    break;
                  case 'linkedin':
                    if (!url.contains('linkedin.com')) {
                      url = 'https://linkedin.com/in/$url';
                    }
                    break;
                  case 'email':
                    url = 'mailto:$url';
                    break;
                }

                final existingIndex = _links.indexWhere(
                  (link) => link.platform == platform
                );
                
                if (existingIndex >= 0) {
                  _links[existingIndex] = SocialLink(
                    platform: platform,
                    url: url,
                  );
                } else {
                  _links.add(SocialLink(
                    platform: platform,
                    url: url,
                  ));
                }

                setState(() {});
                Navigator.of(context).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields correctly'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await ref.read(profileServiceProvider).createProfile(
        name: _nameController.text,
        phoneNo: _phoneController.text,
        about: _aboutController.text,
        links: _links.map((link) => link.toJson()).toList(),
      );

      if (!mounted) return;


      await Future.wait([
        ref.read(profileProvider.notifier).loadProfiles(),
        ref.read(profileProvider.notifier).loadActiveProfile(),
      ]);

      Navigator.of(context).pop();

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  IconData _getIconForPlatform(String platform) {
    switch (platform.toLowerCase()) {
      case 'whatsapp':
        return FontAwesomeIcons.whatsapp;
      case 'instagram':
        return FontAwesomeIcons.instagram;
      case 'twitter':
        return FontAwesomeIcons.twitter;
      case 'linkedin':
        return FontAwesomeIcons.linkedin;
      case 'email':
        return FontAwesomeIcons.envelope;
      default:
        return FontAwesomeIcons.link;
    }
  }

  String _getPlatformDisplayName(String platform) {
    switch (platform.toLowerCase()) {
      case 'twitter':
        return 'Twitter/X';
      default:
        return platform[0].toUpperCase() + platform.substring(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('Create New Profile'),
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Basic Information',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Profile Name',
                            hintText: 'Enter your profile name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => 
                            value?.isEmpty ?? true ? 'Name is required' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            hintText: '+1234567890',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.phone,
                          validator: _validatePhone,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _aboutController,
                          decoration: const InputDecoration(
                            labelText: 'About',
                            hintText: 'Tell us about yourself',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                          validator: (value) => 
                            value?.isEmpty ?? true ? 'About is required' : null,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Social Links',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: _links.length >= 5 
                                ? null 
                                : _showPlatformSelectionDialog,
                              tooltip: _links.length >= 5 
                                ? 'Maximum 5 links allowed'
                                : 'Add social link',
                            ),
                          ],
                        ),
                        if (_links.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Text(
                                'Click the + button to add your social media profiles',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _links.length,
                            itemBuilder: (context, index) {
                              final link = _links[index];
                              return ListTile(
                                leading: FaIcon(_getIconForPlatform(link.platform)),
                                title: Text(
                                  _getPlatformDisplayName(link.platform),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(link.url),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () => _showSocialLinkDialog(link.platform),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        setState(() {
                                          _links.removeAt(index);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: Text(
                    _isLoading ? 'Creating Profile...' : 'Create Profile',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        if (_isLoading)
          const LoadingOverlay(),
      ],
    );
  }
}

// Add other utility functions if not already present
IconData _getIconForPlatform(String platform) {
  switch (platform.toLowerCase()) {
    case 'whatsapp':
      return FontAwesomeIcons.whatsapp;
    case 'instagram':
      return FontAwesomeIcons.instagram;
    case 'twitter':
      return FontAwesomeIcons.twitter;
    case 'linkedin':
      return FontAwesomeIcons.linkedin;
    case 'email':
      return FontAwesomeIcons.envelope;
    default:
      return FontAwesomeIcons.link;
  }
}
