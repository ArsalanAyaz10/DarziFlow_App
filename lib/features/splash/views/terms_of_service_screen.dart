import 'package:dariziflow_app/core/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: "Terms of Service",
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
              "1. Acceptance of Terms",
              "By accessing or using Darziflow (the \"Service\"), you agree to be bound by these Terms of Service. If you do not agree, please do not use the application.",
            ),
            _buildSection(
              context,
              "2. Description of Service",
              "Darziflow provides a digital management platform for tailoring businesses. We act solely as a software provider; we are not responsible for the quality of physical tailoring services, fabric handling, or transactions between tailors and their clients.",
            ),
            _buildSection(
              context,
              "3. User Accounts",
              null,
              bullets: [
                "You must provide accurate and complete information during registration.",
                "You are responsible for maintaining the security of your account and password.",
                "Darziflow is not liable for any loss or damage arising from your failure to protect your login credentials.",
              ],
            ),
            _buildSection(
              context,
              "4. Payments and Subscriptions",
              null,
              bullets: [
                "Certain features require a paid subscription. All fees are non-refundable unless required by law.",
                "Failure to pay subscription fees may result in the suspension of access to your data.",
              ],
            ),
            _buildSection(
              context,
              "5. Prohibited Use",
              "You agree not to:",
              bullets: [
                "Use the Service for any illegal activities.",
                "Attempt to hack, reverse-engineer, or disrupt the Service.",
                "Store sensitive data that violates the privacy of your customers without their consent.",
              ],
            ),
            _buildSection(
              context,
              "6. Limitation of Liability",
              "Darziflow is provided \"as is.\" We are not liable for any business interruptions, loss of customer data, or financial losses resulting from the use or inability to use the app.",
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
