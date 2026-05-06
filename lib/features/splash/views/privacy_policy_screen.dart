import 'package:dariziflow_app/core/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: "Privacy Policy",
        subtitle: "Last Updated: April 22, 2026",
        isTransparent: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              context,
              "1. Data We Collect",
              null,
              bullets: [
                "Account Data: Name, email address, and business contact details.",
                "Customer Data: Names, phone numbers, and physical measurements of your clients.",
                "Usage Data: Information on how you interact with the app to help us improve performance.",
              ],
            ),
            _buildSection(
              context,
              "2. How We Use Your Data",
              "We use the information collected to:",
              bullets: [
                "Enable core features (order tracking, measurement storage).",
                "Send automated notifications to you or your customers.",
                "Provide technical support and security updates.",
              ],
            ),
            _buildSection(
              context,
              "3. Data Storage and Security",
              "We implement industry-standard encryption to protect your data. While we strive to use commercially acceptable means to protect your personal information, we cannot guarantee its absolute security.",
            ),
            _buildSection(
              context,
              "4. Third-Party Services",
              "We do not sell your data to third parties. We may use third-party providers (such as cloud hosting or payment processors) to facilitate our service, only to the extent necessary for them to perform their functions.",
            ),
            _buildSection(
              context,
              "5. Data Ownership and Deletion",
              null,
              bullets: [
                "You own your data. You may export or delete your customer records at any time.",
                "Upon account deletion, all personal data associated with your account will be permanently removed from our active databases within 30 days.",
              ],
            ),
            _buildSection(
              context,
              "6. Contact Us",
              "If you have any questions regarding these policies, please contact us at:\nsupport@darziflow.com",
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String? content,
      {List<String>? bullets}) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: colors.primary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Outfit',
            ),
          ),
          const SizedBox(height: 12),
          if (content != null)
            Text(
              content,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 14,
                height: 1.6,
                fontFamily: 'Outfit',
              ),
            ),
          if (bullets != null) ...[
            const SizedBox(height: 8),
            ...bullets.map((bullet) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0, left: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "• ",
                        style: TextStyle(
                          color: colors.primary,
                          fontSize: 14,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          bullet,
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: 14,
                            height: 1.6,
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }
}
