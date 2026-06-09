import 'package:flutter/material.dart';
import 'package:spendly/services/storage_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Text('Profile',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1F2937))),
              const SizedBox(height: 28),

              // Avatar
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Center(
                  child: Text('馃懁', style: TextStyle(fontSize: 36)),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Your Account',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937))),
              const SizedBox(height: 28),

              // Settings List
              _SettingsTile(
                icon: '馃敂',
                title: 'Notifications',
                subtitle: 'Daily spending alerts',
                onTap: () {},
              ),
              _SettingsTile(
                icon: '馃挵',
                title: 'Currency',
                subtitle: 'Indian Rupee (鈧�)',
                onTap: () {},
              ),
              _SettingsTile(
                icon: '馃搳',
                title: 'Export Data',
                subtitle: 'Download as CSV',
                onTap: () {},
              ),
              _SettingsTile(
                icon: '馃敀',
                title: 'Privacy & Security',
                subtitle: 'Biometric lock, data',
                onTap: () {},
              ),
              _SettingsTile(
                icon: '猸�',
                title: 'Rate Spendly',
                subtitle: 'Love the app? Rate us!',
                onTap: () {},
              ),
              _SettingsTile(
                icon: '馃棏锔�',
                title: 'Clear All Data',
                subtitle: 'Delete all transactions',
                isDestructive: true,
                onTap: () async {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      title: const Text('Clear all data?'),
                      content: const Text(
                          'This will delete all your transactions permanently.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            await StorageService.saveBudgets({});
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('All data cleared')),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red),
                          child: const Text('Delete',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 28),
              const Text('Spendly v1.0.0',
                  style: TextStyle(
                      fontSize: 12, color: Color(0xFF9CA3AF))),
              const Text('Made with 鉂わ笍 in India',
                  style: TextStyle(
                      fontSize: 12, color: Color(0xFF9CA3AF))),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04), blurRadius: 8)
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: isDestructive
                    ? Colors.red.withOpacity(0.1)
                    : const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDestructive
                              ? Colors.red
                              : const Color(0xFF1F2937))),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF9CA3AF))),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: Colors.grey.shade300),
          ],
        ),
      ),
    );
  }
}
