
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/auth_provider.dart';
import '../models/signup_data.dart';
import '../models/social_link.dart';
import '../../dashboard/screens/dashboard_screen.dart';

const Color _primaryBlue = Color(0xFF3B82F6);
const Color _cardBackground = Color(0xFF1E2230);
const Color _textGrey = Color(0xFFADB5BD);

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool isLogin = true;
  final _loginFormKey = GlobalKey<FormState>();
  final _signupFormKey = GlobalKey<FormState>();
  
  // Controllers for login
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  
  // Controllers for signup step 1
  final _signupEmailController = TextEditingController();
  final _signupPasswordController = TextEditingController();
  final _signupNameController = TextEditingController();
  final _signupPhoneController = TextEditingController();
  final _signupAboutController = TextEditingController();
  
  // Social links for step 2
  final List<SocialLink> socialLinks = [];
  bool isSecondStep = false;

  @override
Widget build(BuildContext context) {
  // Watch auth state
  final authState = ref.watch(authProvider);

  // Auto-navigate when authenticated
  if (authState.isAuthenticated) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    });
  }

  return Scaffold(
    body: Stack(
      children: [
        Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo and Title
                const Text(
                  'EasyNFC',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color:  _primaryBlue, // Using the blue from our theme
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Share Your Digital Identity',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 48),

                // Auth Card
                Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  decoration: BoxDecoration(
                    color: _cardBackground, 
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => setState(() {
                                isLogin = true;
                                isSecondStep = false;
                              }),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: isLogin
                                          ? _primaryBlue
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'LOGIN',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isLogin
                                        ? _primaryBlue
                                        : Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () => setState(() {
                                isLogin = false;
                                isSecondStep = false;
                              }),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: !isLogin
                                          ? _primaryBlue
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'SIGN UP',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: !isLogin
                                        ? _primaryBlue
                                        : Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Form content
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: isLogin
                            ? _buildLoginForm()
                            : (isSecondStep
                                ? _buildSignupStep2()
                                : _buildSignupStep1()),
                      ),
                    ],
                  ),
                ),

                // Help text
                if (!isSecondStep) ...[
                  const SizedBox(height: 24),
                  Text(
                    isLogin
                        ? 'Need an account?'
                        : 'Already have an account?',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        isLogin = !isLogin;
                        isSecondStep = false;
                      });
                    },
                    child: Text(
                      isLogin ? 'Sign up' : 'Login',
                      style: const TextStyle(
                        color: Color(0xFF3B82F6),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        // Loading overlay
        if (authState.isLoading)
          Container(
            color: Colors.black54,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        // Error snackbar
        if (authState.error != null)
          SnackBar(
            content: Text(authState.error!),
            backgroundColor: Colors.red,
          ),
      ],
    ),
  );
}

  Widget _buildLoginForm() {
    return Form(
      key: _loginFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _loginEmailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email),
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter your email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _loginPasswordController,
            decoration: const InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock),
            ),
            obscureText: true,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter your password';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _handleLogin,
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  Widget _buildSignupStep1() {
    return Form(
      key: _signupFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _signupNameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _signupEmailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email),
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter your email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _signupPasswordController,
            decoration: const InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock),
            ),
            obscureText: true,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter a password';
              }
              if (value!.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _signupPhoneController,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              prefixIcon: Icon(Icons.phone),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter your phone number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _signupAboutController,
            decoration: const InputDecoration(
              labelText: 'About',
              prefixIcon: Icon(Icons.info),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (_signupFormKey.currentState!.validate()) {
                setState(() {
                  isSecondStep = true;
                });
              }
            },
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }

  Widget _buildSignupStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Add Your Social Links',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        _buildSocialLinkButton(
          icon: FontAwesomeIcons.whatsapp,
          label: 'WhatsApp',
          onAdd: () => _showSocialLinkDialog('whatsapp'),
        ),
        _buildSocialLinkButton(
          icon: FontAwesomeIcons.instagram,
          label: 'Instagram',
          onAdd: () => _showSocialLinkDialog('instagram'),
        ),
        _buildSocialLinkButton(
          icon: FontAwesomeIcons.twitter,
          label: 'Twitter/X',
          onAdd: () => _showSocialLinkDialog('twitter'),
        ),
        _buildSocialLinkButton(
          icon: FontAwesomeIcons.linkedin,
          label: 'LinkedIn',
          onAdd: () => _showSocialLinkDialog('linkedin'),
        ),
        _buildSocialLinkButton(
          icon: FontAwesomeIcons.envelope,
          label: 'Email',
          onAdd: () => _showSocialLinkDialog('email'),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            TextButton(
              onPressed: () {
                setState(() {
                  isSecondStep = false;
                });
              },
              child: const Text('Back'),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _handleSignup,
                child: const Text('Complete Signup'),
              ),
            ),
          ],
        ),
      ],
    );
  }


  Widget _buildSocialLinkButton({
    required IconData icon,
    required String label,
    required VoidCallback onAdd,
  }) {
    final hasLink = socialLinks.any((link) => link.platform == label.toLowerCase());
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: OutlinedButton.icon(
        icon: FaIcon(icon, size: 20),
        label: Text(hasLink ? 'Edit $label' : 'Add $label'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          side: BorderSide(color: hasLink ? Colors.blue : Colors.grey),
        ),
        onPressed: onAdd,
      ),
    );
  }

  Future<void> _showSocialLinkDialog(String platform) async {
    final TextEditingController linkController = TextEditingController();
    final existingLink = socialLinks.firstWhere(
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
          if (value?.isEmpty ?? true) return null; // Optional
          if (!RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(value!)) {
            return 'Please enter a valid phone number';
          }
          return null;
        };
        break;
      case 'instagram':
        hint = 'Enter your Instagram username';
        validator = (value) {
          if (value?.isEmpty ?? true) return null; // Optional
          if (!RegExp(r'^[a-zA-Z0-9._]{1,30}$').hasMatch(value!)) {
            return 'Please enter a valid Instagram username';
          }
          return null;
        };
        break;
      case 'twitter':
        hint = 'Enter your Twitter/X username';
        validator = (value) {
          if (value?.isEmpty ?? true) return null; // Optional
          if (!RegExp(r'^[a-zA-Z0-9_]{1,15}$').hasMatch(value!)) {
            return 'Please enter a valid Twitter username';
          }
          return null;
        };
        break;
      case 'linkedin':
        hint = 'Enter your LinkedIn profile URL or username';
        validator = (value) {
          if (value?.isEmpty ?? true) return null; // Optional
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
          if (value?.isEmpty ?? true) return null; // Optional
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
        title: Text('Add $platform'),
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
              // Remove the link if it exists
              socialLinks.removeWhere((link) => link.platform == platform);
              Navigator.of(context).pop();
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
                
                // Format URLs based on platform
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

                // Update or add the link
                final existingIndex = socialLinks.indexWhere(
                  (link) => link.platform == platform
                );
                
                if (existingIndex >= 0) {
                  socialLinks[existingIndex] = SocialLink(
                    platform: platform,
                    url: url,
                  );
                } else {
                  socialLinks.add(SocialLink(
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

  Future<void> _handleLogin() async {
    if (_loginFormKey.currentState!.validate()) {
      try {
    
        await ref.read(authProvider.notifier).login(
          _loginEmailController.text,
          _loginPasswordController.text,
        );
        
        if (mounted) {
          // Navigate to dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      }
    }
  }

  Future<void> _handleSignup() async {
    final signupData = SignupData(
      email: _signupEmailController.text,
      password: _signupPasswordController.text,
      name: _signupNameController.text,
      phoneNo: _signupPhoneController.text,
      about: _signupAboutController.text,
      links: socialLinks,
    );

    try {
  
      await ref.read(authProvider.notifier).register(signupData);
      
      if (mounted) {
        // Navigate to dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _signupEmailController.dispose();
    _signupPasswordController.dispose();
    _signupNameController.dispose();
    _signupPhoneController.dispose();
    _signupAboutController.dispose();
    super.dispose();
  }
}