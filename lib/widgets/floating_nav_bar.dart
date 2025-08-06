import 'package:flutter/material.dart';
import 'dart:ui';

class FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onIndexChanged;

  const FloatingNavBar({
    super.key,
    required this.currentIndex,
    required this.onIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A).withOpacity(0.8),
        borderRadius: BorderRadius.circular(35),
        border: Border.all(
          color: const Color(0xFF2A2A2A),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A).withOpacity(0.7),
              borderRadius: BorderRadius.circular(35),
            ),
            child: Row(
              children: [
                // Profile picture (left side)
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: GestureDetector(
                    onTap: () {
                      // TODO: Open sidebar
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Sidebar coming soon!'),
                          backgroundColor: Color(0xFF6366F1),
                        ),
                      );
                    },
                    child: Stack(
                      children: [
                        const CircleAvatar(
                          radius: 20,
                          backgroundColor: Color(0xFF6366F1),
                          child: Text(
                            'U',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFF1A1A1A),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Navigation items
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNavItem(
                        icon: Icons.home_outlined,
                        activeIcon: Icons.home,
                        label: 'Feed',
                        index: 0,
                      ),
                      _buildNavItem(
                        icon: Icons.message_outlined,
                        activeIcon: Icons.message,
                        label: 'Messages',
                        index: 1,
                      ),
                      _buildNavItem(
                        icon: Icons.person_outline,
                        activeIcon: Icons.person,
                        label: 'Profile',
                        index: 2,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Menu button (right side)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: IconButton(
                    onPressed: () {
                      // TODO: Show menu
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Menu coming soon!'),
                          backgroundColor: Color(0xFF6366F1),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.menu,
                      color: Color(0xFF9CA3AF),
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final isActive = currentIndex == index;
    
    return GestureDetector(
      onTap: () => onIndexChanged(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive 
              ? const Color(0xFF6366F1).withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive 
                  ? const Color(0xFF6366F1)
                  : const Color(0xFF9CA3AF),
              size: 20,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isActive 
                    ? const Color(0xFF6366F1)
                    : const Color(0xFF9CA3AF),
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 