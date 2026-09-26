import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class RegionInfo {
  const RegionInfo({
    required this.name,
    required this.generation,
    required this.color,
    required this.starterIds,
  });

  final String name;
  final String generation;
  final Color color;
  final List<int> starterIds;
}

const regions = [
  RegionInfo(
    name: 'Kanto',
    generation: '1st generation',
    color: Color(0xFF74CB48),
    starterIds: [1, 4, 7],
  ),
  RegionInfo(
    name: 'Johto',
    generation: '2nd generation',
    color: Color(0xFFF57D31),
    starterIds: [152, 155, 158],
  ),
  RegionInfo(
    name: 'Hoenn',
    generation: '3rd generation',
    color: Color(0xFF6493EB),
    starterIds: [252, 255, 258],
  ),
  RegionInfo(
    name: 'Sinnoh',
    generation: '4th generation',
    color: Color(0xFFA43E9E),
    starterIds: [387, 390, 393],
  ),
  RegionInfo(
    name: 'Unova',
    generation: '5th generation',
    color: Color(0xFF70559B),
    starterIds: [495, 498, 501],
  ),
  RegionInfo(
    name: 'Kalos',
    generation: '6th generation',
    color: Color(0xFFFB5584),
    starterIds: [650, 653, 656],
  ),
  RegionInfo(
    name: 'Alola',
    generation: '7th generation',
    color: Color(0xFFF9CF30),
    starterIds: [722, 725, 728],
  ),
  RegionInfo(
    name: 'Galar',
    generation: '8th generation',
    color: Color(0xFF173EA5),
    starterIds: [810, 813, 816],
  ),
];

class RegionsScreen extends StatelessWidget {
  const RegionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                'Regions',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: regions.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final region = regions[index];
                  return _RegionCard(region: region);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RegionCard extends StatelessWidget {
  const _RegionCard({required this.region});

  final RegionInfo region;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1D1D1D),
            region.color.withValues(alpha: 0.85),
          ],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  region.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  region.generation,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          for (final id in region.starterIds)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Image.network(
                'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png',
                width: 52,
                height: 52,
                errorBuilder: (_, _, _) => const SizedBox(width: 52),
              ),
            ),
        ],
      ),
    );
  }
}
