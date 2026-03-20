
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/design_system.dart';
import '../services/network/license_service.dart';
import '../viewmodels/mentor_view_model.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final licenseService = LicenseService();
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(decoration: const BoxDecoration(gradient: DesignSystem.mainGradient)),
          
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _buildProfileCard(licenseService),
                        const SizedBox(height: 24),
                        _buildLicenseSection(context, licenseService),
                        const SizedBox(height: 24),
                        _buildInfoSection(),
                        const Spacer(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Center(
              child: Text(
                "ЛИЧНЫЙ КАБИНЕТ",
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
              ),
            ),
          ),
          const SizedBox(width: 48), // Spacer
        ],
      ),
    );
  }

  Widget _buildProfileCard(LicenseService service) {
    return DesignSystem.glassCard(
      radius: 24,
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: DesignSystem.emerald, width: 2)),
            child: const CircleAvatar(
              radius: 30,
              backgroundColor: DesignSystem.obsidianBlack,
              child: Icon(Icons.person, color: DesignSystem.emerald, size: 40),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Пользователь J.A.R.V.I.S.", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  service.isActivated ? "Статус: Активен" : "Статус: Не активирован",
                  style: TextStyle(color: service.isActivated ? DesignSystem.emerald : Colors.redAccent, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLicenseSection(BuildContext context, LicenseService service) {
    String keyDisplay = service.currentKey ?? "Нет ключа";
    if (keyDisplay.length > 8) {
      keyDisplay = "${keyDisplay.substring(0, 4)}...${keyDisplay.substring(keyDisplay.length - 4)}";
    }

    return DesignSystem.glassCard(
      radius: 24,
      child: Column(
        children: [
          _buildDetailRow(Icons.vpn_key, "ЛИЦЕНЗИОННЫЙ КЛЮЧ", keyDisplay),
          const Divider(color: Colors.white10),
          _buildDetailRow(Icons.account_balance_wallet, "БАЛАНС", "${service.balance} CREDITS"),
          const Divider(color: Colors.white10),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent, size: 20),
            title: const Text("Выйти", style: TextStyle(color: Colors.redAccent, fontSize: 14)),
            onTap: () {
              service.logout();
              context.read<MentorViewModel>().notifyListeners(); // Force UI update
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, color: Colors.white54, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return DesignSystem.glassCard(
      radius: 24,
      child: Column(
        children: [
          _buildDetailRow(Icons.info_outline, "ВЕРСИЯ", "1.0.0 (Phoenix)"),
          const Divider(color: Colors.white10),
          _buildDetailRow(Icons.support_agent, "ПОДДЕРЖКА", "@jarvis_support_bot"),
        ],
      ),
    );
  }
}
