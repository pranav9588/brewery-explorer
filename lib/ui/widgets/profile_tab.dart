import 'package:brewery/ui/widgets/profile_header.dart';
import 'package:flutter/material.dart';
import 'package:brewery/core/utils/utilities.dart';

class ProfileTab extends StatelessWidget {
  final void Function(String text) onShare;
  final Future<void> Function(String url) onOpenUrl;

  const ProfileTab({super.key, required this.onShare, required this.onOpenUrl});

  @override
  Widget build(BuildContext context) {
    const String devName = 'Pranav Patel';
    const String role = 'Mobile App Developer';
    const String email = 'pranav.patel2001@gmail.com';
    const String medium = 'https://medium.com/@pranav.patel2001';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileHeader(
            name: devName,
            role: role,
            onEdit: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit profile not implemented')),
              );
            },
          ),

          const SizedBox(height: 20),

          const Text('About Me', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
            '''Dynamic Mobile App Developer with over 3.8 years of experience specializing in Flutter and Kotlin for
innovative healthcare and fintech applications. Proven expertise in integrating BLE technology,
implementing real-time data visualization, and designing robust architectures that enhance user experience.
Collaborated with UNICEF to ensure compliance with Digital Public Goods standards for open-source
healthcare initiatives, demonstrating a commitment to impactful solutions. Proficient in developing scalable,
testable, and production-ready mobile systems utilizing Cubit/BLoC and MVVM design patterns, ensuring
high-quality deliverables that meet industry demands.''',
          ),

          const SizedBox(height: 24),

          Card(
            child: ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Email'),
              subtitle: const Text(email),
              trailing: IconButton(
                icon: const Icon(Icons.open_in_new),
                onPressed: () => Utilities.launchURL('mailto:$email'),
              ),
            ),
          ),

          const SizedBox(height: 8),

          Card(
            child: ListTile(
              leading: const Icon(Icons.article),
              title: const Text('Medium'),
              subtitle: const Text('Tech blogs & tutorials'),
              trailing: IconButton(
                icon: const Icon(Icons.open_in_new),
                onPressed: () => Utilities.launchURL(medium),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
