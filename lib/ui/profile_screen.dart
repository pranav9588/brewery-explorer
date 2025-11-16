import 'package:brewery/ui/widgets/about_tab.dart';
import 'package:brewery/ui/widgets/profile_tab.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileAboutScreen extends StatefulWidget {
  const ProfileAboutScreen({super.key});

  @override
  State<ProfileAboutScreen> createState() => _ProfileAboutScreenState();
}

class _ProfileAboutScreenState extends State<ProfileAboutScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      setState(() => _packageInfo = info);
    } catch (_) {
      // ignore
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Cannot open link')));
      }
    } catch (_) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error opening link')));
    }
  }

  Future<void> _openSource() async {
    const repo = 'https://github.com/pranav9588/GraphQL-with-Apollo';
    await _launchUrl(repo);
  }

  Future<void> _contactAuthor() async {
    const email =
        'mailto:pranav.patel2001@gmail.com?subject=Brewery%20App%20Feedback';
    await _launchUrl(email);
  }

  void _shareText(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share not implemented — integrate share_plus'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & About'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Profile'),
            Tab(text: 'About'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ProfileTab(onShare: _shareText, onOpenUrl: _launchUrl),
          AboutTab(
            packageInfo: _packageInfo,
            onOpenSource: _openSource,
            onContact: _contactAuthor,
          ),
        ],
      ),
    );
  }
}
