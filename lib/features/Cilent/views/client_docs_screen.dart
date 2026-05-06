import 'package:dariziflow_app/core/widgets/bottom_nav_bar.dart';
import 'package:dariziflow_app/core/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ClientDocsScreen extends StatelessWidget {
  const ClientDocsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: const CustomAppBar(
        title: "Documents",
        subtitle: "Invoices & Measurements",
        showBackButton: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description_outlined, size: 80, color: colors.primary.withValues(alpha: 0.5)),
            const SizedBox(height: 20),
            Text(
              "No Documents Yet",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Your invoices and measurement sheets\nwill appear here.",
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }
}
