import 'package:flutter/material.dart';
import '../models/profile.dart';

class ProfileCard extends StatelessWidget {
  final Profile profile;
  final bool isActive;
  final VoidCallback onSetActive;

  const ProfileCard({
    Key? key,
    required this.profile,
    required this.isActive,
    required this.onSetActive,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  profile.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                if (isActive)
                  Chip(
                    label: const Text('Active'),
                    backgroundColor: Colors.green,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(profile.about),
            const SizedBox(height: 8),
            Text('Links: ${profile.links.length}'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (!isActive)
                  ElevatedButton(
                    onPressed: onSetActive,
                    child: const Text('Set as Active'),
                  ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // Navigate to edit profile
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {
                    // Share profile URL
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}