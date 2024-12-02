import 'package:flutter/material.dart';
import '../models/social_link.dart';

class SocialLinkForm extends StatefulWidget {
  final Function(SocialLink) onSaved;
  final VoidCallback onRemove;
  final SocialLink? initialValue;

  const SocialLinkForm({
    Key? key,
    required this.onSaved,
    required this.onRemove,
    this.initialValue,
  }) : super(key: key);

  @override
  State<SocialLinkForm> createState() => _SocialLinkFormState();
}

class _SocialLinkFormState extends State<SocialLinkForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _urlController;
  late TextEditingController _customTitleController;
  String _selectedPlatform = 'website';
  bool _isCustom = false;

  final List<String> _platforms = [
    'instagram',
    'twitter',
    'linkedin',
    'whatsapp',
    'email',
    'website',
    'custom'
  ];

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: widget.initialValue?.url ?? '');
    _customTitleController = TextEditingController(text: widget.initialValue?.customTitle ?? '');
    if (widget.initialValue != null) {
      _selectedPlatform = widget.initialValue!.platform;
      _isCustom = widget.initialValue!.isCustom;
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    _customTitleController.dispose();
    super.dispose();
  }

  String? _validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a URL';
    }

    switch (_selectedPlatform) {
      case 'email':
        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
        if (!emailRegex.hasMatch(value)) {
          return 'Invalid email address';
        }
        break;
      case 'whatsapp':
        final phoneRegex = RegExp(r'^\+?[\d\s-]+$');
        if (!phoneRegex.hasMatch(value)) {
          return 'Invalid phone number';
        }
        break;
      case 'website':
      case 'custom':
        try {
          final uri = Uri.parse(value);
          if (!uri.hasScheme || !uri.hasAuthority) {
            return 'Invalid URL format';
          }
        } catch (_) {
          return 'Invalid URL format';
        }
        break;
    }
    return null;
  }

  void _handleSave() {
    if (_formKey.currentState?.validate() ?? false) {
      final url = SocialLink.formatUrl(_selectedPlatform, _urlController.text);
      widget.onSaved(SocialLink(
        platform: _selectedPlatform,
        url: url,
        isCustom: _isCustom,
        customTitle: _isCustom ? _customTitleController.text : null,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedPlatform,
                      decoration: const InputDecoration(
                        labelText: 'Platform',
                        border: OutlineInputBorder(),
                      ),
                      items: _platforms.map((platform) {
                        return DropdownMenuItem(
                          value: platform,
                          child: Text(platform.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedPlatform = value;
                            _isCustom = value == 'custom';
                            _handleSave();
                          });
                        }
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: widget.onRemove,
                    color: Colors.red,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_isCustom) ...[
                TextFormField(
                  controller: _customTitleController,
                  decoration: const InputDecoration(
                    labelText: 'Custom Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (_isCustom && (value?.isEmpty ?? true)) {
                      return 'Please enter a title for custom link';
                    }
                    return null;
                  },
                  onChanged: (_) => _handleSave(),
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _urlController,
                decoration: InputDecoration(
                  labelText: _getLabelText(),
                  hintText: _getHintText(),
                  border: const OutlineInputBorder(),
                ),
                validator: _validateUrl,
                onChanged: (_) => _handleSave(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getLabelText() {
    switch (_selectedPlatform) {
      case 'instagram':
      case 'twitter':
        return 'Username';
      case 'whatsapp':
        return 'Phone Number';
      case 'email':
        return 'Email Address';
      default:
        return 'URL';
    }
  }

  String _getHintText() {
    switch (_selectedPlatform) {
      case 'instagram':
        return 'username (without @)';
      case 'twitter':
        return '@username or username';
      case 'whatsapp':
        return '+1234567890';
      case 'linkedin':
        return 'username or full profile URL';
      case 'email':
        return 'email@example.com';
      case 'website':
      case 'custom':
        return 'https://example.com';
      default:
        return '';
    }
  }
}