import 'package:flutter/material.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/homeCard.dart';

class MyAccountsOverview extends StatelessWidget {
  const MyAccountsOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'எனது கணக்கு விபரங்கள்',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Topup பதிவுகள் மற்றும் கட்டண விவரங்கள்',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 16),
          HomeCard(context: context),
        ],
      ),
    );
  }
}
