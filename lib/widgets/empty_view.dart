import 'package:flutter/material.dart';

class EmptyView extends StatelessWidget {
  final String message;
  final IconData icon;
  final VoidCallback? onRefresh;

  const EmptyView({
    super.key,
    required this.message,
    this.icon = Icons.photo_library,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 100, color: Colors.grey),
            const SizedBox(height: 20),
            // Title message
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 28),

            // Modern refresh button
            /*ElevatedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                elevation: 3,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),*/
          ],
        ),
      ),
    );
  }
}
