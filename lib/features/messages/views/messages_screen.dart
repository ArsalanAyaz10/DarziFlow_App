import 'package:dariziflow_app/core/widgets/bottom_nav_bar.dart';
import 'package:dariziflow_app/core/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';

class MessagesComingSoonScreen extends StatelessWidget {
  const MessagesComingSoonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const CustomAppBar(
        title: "Messages",
        centerTitle: true,
        showBackButton: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.message_outlined,
                  size: 80,
                  color: colors.primary,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                "Coming Soon!",
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "The Messages feature is currently under development. Stay tuned for real-time updates and communication!",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: 200,
                child: LinearProgressIndicator(
                  backgroundColor: colors.primary.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
    );
  }
}
