import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile_card.dart';
import '../../nfc/services/nfc_service.dart';
import '../../nfc/widgets/nfc_write_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../config/api_config.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/auth_screen.dart';
import './profile_create_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_handlePageChange);

    // Load profiles
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileProvider.notifier).loadActiveProfile();
      ref.read(profileProvider.notifier).loadProfiles();
    });
  }

  @override
  void dispose() {
    _pageController.removeListener(_handlePageChange);
    _pageController.dispose();
    super.dispose();
  }

  void _handlePageChange() {
    setState(() {
      _currentPageIndex = _pageController.page?.round() ?? 0;
    });
  }

  Future<void> _handleLogout() async {
    final navigator = Navigator.of(context);

    final shouldLogout = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.red,
                ),
                child: const Text('Logout'),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldLogout || !mounted) return;

    try {
      await ref.read(authProvider.notifier).logout();

      if (!mounted) return;
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AuthScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleNFCWrite(String profileUrl) async {
    bool isAvailable = await NFCService.isNFCAvailable();

    if (!isAvailable) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('NFC is not available on this device'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => NFCWriteDialog(url: profileUrl),
    );
  }

  Future<void> _previewProfile(String urlSlug) async {
    final url = APIConfig.getPublicProfileUrl(urlSlug);
    final uri = Uri.parse(url);

    try {
      // Try to launch URL
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          webViewConfiguration: const WebViewConfiguration(
            enableJavaScript: true,
            enableDomStorage: true,
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open profile preview'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('URL Launch error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening URL: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentPageIndex == 0 ? 'Dashboard' : 'Manage Profiles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentPageIndex = index;
          });
        },
        children: [
          _buildMainDashboard(profileState),
          _buildProfileManagement(profileState),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentPageIndex,
        onTap: (index) => _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Profiles',
          ),
        ],
      ),
    );
  }

  Widget _buildMainDashboard(ProfileState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.activeProfile == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No active profile'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _pageController.animateToPage(
                1,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              ),
              child: const Text('Manage Profiles'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      // Added ScrollView
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Active Profile',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                state.activeProfile!.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                overflow: TextOverflow
                                    .ellipsis, // Added overflow handling
                              ),
                            ],
                          ),
                        ),
                        const Chip(
                          label: Text('Active'),
                          backgroundColor: Colors.green,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.activeProfile!.about,
                      overflow:
                          TextOverflow.ellipsis, // Added overflow handling
                      maxLines: 3, // Limit lines
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      // Make buttons scrollable if needed
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _ActionButton(
                            icon: Icons.nfc,
                            label: 'Write to NFC',
                            onPressed: () => _handleNFCWrite(
                              APIConfig.getPublicProfileUrl(
                                  state.activeProfile!.urlSlug),
                            ),
                          ),
                          const SizedBox(width: 8), // Added spacing
                          _ActionButton(
                            icon: Icons.preview,
                            label: 'Preview',
                            onPressed: () =>
                                _previewProfile(state.activeProfile!.urlSlug),
                          ),
                          const SizedBox(width: 8), // Added spacing
                          _ActionButton(
                            icon: Icons.share,
                            label: 'Share',
                            onPressed: () {
                              // Implement share functionality
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Quick Stats',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Total Profiles',
                    value: state.profiles.length.toString(),
                    icon: Icons.people,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    title: 'Total Links',
                    value: state.activeProfile!.links.length.toString(),
                    icon: Icons.link,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16), // Added bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildProfileManagement(ProfileState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your Profiles',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (state.profiles.length < 5)
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CreateProfileScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('New Profile'),
              ),
          ],
        ),
        const SizedBox(height: 16),
        ...state.profiles
            .map((profile) => ProfileCard(
                  profile: profile,
                  isActive: state.activeProfile?.id == profile.id,
                  onSetActive: () {
                    ref.read(profileProvider.notifier).switchProfile(
                          state.profiles.indexOf(profile),
                        );
                  },
                ))
            .toList(),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          const SizedBox(height: 4),
          Text(label),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
