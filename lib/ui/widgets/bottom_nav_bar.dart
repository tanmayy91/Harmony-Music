import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/ui/screens/Home/home_screen_controller.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final homeScreenController = Get.find<HomeScreenController>();
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.75),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withOpacity(0.08),
                width: 1,
              ),
            ),
            child: Obx(() {
              final selected = homeScreenController.tabIndex.toInt();
              return NavigationBar(
                onDestinationSelected:
                    homeScreenController.onBottonBarTabSelected,
                selectedIndex: selected,
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                height: 64,
                labelBehavior:
                    NavigationDestinationLabelBehavior.alwaysShow,
                animationDuration: const Duration(milliseconds: 400),
                destinations: [
                  _bouncyDest(
                    context,
                    selectedIcon: Icons.home_rounded,
                    unselectedIcon: Icons.home_outlined,
                    label: modifyNgetlabel('home'.tr),
                    isSelected: selected == 0,
                  ),
                  _bouncyDest(
                    context,
                    selectedIcon: Icons.search_rounded,
                    unselectedIcon: Icons.search_rounded,
                    label: modifyNgetlabel('search'.tr),
                    isSelected: selected == 1,
                  ),
                  _bouncyDest(
                    context,
                    selectedIcon: Icons.library_music_rounded,
                    unselectedIcon: Icons.library_music_outlined,
                    label: modifyNgetlabel('library'.tr),
                    isSelected: selected == 2,
                  ),
                  _bouncyDest(
                    context,
                    selectedIcon: Icons.settings_rounded,
                    unselectedIcon: Icons.settings_outlined,
                    label: modifyNgetlabel('settings'.tr),
                    isSelected: selected == 3,
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  NavigationDestination _bouncyDest(
    BuildContext context, {
    required IconData selectedIcon,
    required IconData unselectedIcon,
    required String label,
    required bool isSelected,
  }) {
    return NavigationDestination(
      selectedIcon: _BouncyIcon(
        icon: selectedIcon,
        size: 26,
        isSelected: true,
      ),
      icon: _BouncyIcon(
        icon: unselectedIcon,
        size: 24,
        isSelected: false,
      ),
      label: label,
    );
  }

  String modifyNgetlabel(String label) {
    if (label.length > 9) {
      return "${label.substring(0, 8)}..";
    }
    return label;
  }
}

/// Icon that pops with a springy scale animation when [isSelected] becomes true.
class _BouncyIcon extends StatefulWidget {
  const _BouncyIcon({
    required this.icon,
    required this.size,
    required this.isSelected,
  });

  final IconData icon;
  final double size;
  final bool isSelected;

  @override
  State<_BouncyIcon> createState() => _BouncyIconState();
}

class _BouncyIconState extends State<_BouncyIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  bool _prevSelected = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.4), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 0.88), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.88, end: 1.0), weight: 35),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(_BouncyIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !_prevSelected) {
      _ctrl.forward(from: 0);
    }
    _prevSelected = widget.isSelected;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scale,
      builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
      child: Icon(widget.icon, size: widget.size),
    );
  }
}
