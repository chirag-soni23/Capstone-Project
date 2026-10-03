import 'package:client/widgets/best_sellers.dart';
import 'package:client/widgets/bottom_nav.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hi, beautiful 👋', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(
                'Your personalized skin ritual awaits',
                style: theme.textTheme.bodyMedium,
              ),

              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  hintText: "Search serums, cleansers, SPF...",
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: Icon(Icons.tune),
                ),
              ),

              const SizedBox(height: 12),
              SizedBox(
                height: 34,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _chip(context, '✨ Dewy Glow', true),
                    _chip(context, '💧 Deep Hydration', false),
                    _chip(context, '🌿 Calm & Care', false),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Container(
                height: 200,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withOpacity(.35),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Summer Essential",
                            style: theme.textTheme.labelSmall,
                          ),

                          const SizedBox(height: 8),

                          Text(
                            'Healthy Skin Starts Here',
                            style: theme.textTheme.titleLarge,
                          ),

                          const SizedBox(height: 4),

                          Text(
                            'Discover clean botanical formulas for luminous glass skin.',
                            style: theme.textTheme.bodySmall,
                          ),

                          const Spacer(),

                          ElevatedButton(
                            onPressed: () {},
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text("Shop Daily Rituals"),
                                SizedBox(width: 8),
                                Icon(Icons.chevron_right),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 10),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(
                        'assets/images/skincare_banner.png',
                        width: 105,
                        height: 105,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const BestSellers(),

            ],

          ),
        ),
      ),
    );
  }
}

Widget _chip(BuildContext context, String text, bool selected) {
  final theme = Theme.of(context);

  return Container(
    margin: const EdgeInsets.only(right: 8),
    padding: const EdgeInsets.symmetric(horizontal: 13),
    decoration: BoxDecoration(
      color: selected ? theme.colorScheme.primary : theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
    ),
    alignment: Alignment.center,
    child: Text(
      text,
      style: theme.textTheme.labelMedium?.copyWith(
        color: selected
            ? theme.colorScheme.onPrimary
            : theme.colorScheme.onSurface,
      ),
    ),
  );
}
