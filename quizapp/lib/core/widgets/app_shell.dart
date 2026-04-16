import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/theme_controller.dart';

class AppShell extends StatefulWidget {
  final ThemeController themeController;
  final Widget child;

  const AppShell({
    super.key,
    required this.themeController,
    required this.child,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  double fabTop = 620;
  double fabLeft = 300;

  bool showThemeMenu = false;
  bool isFabHidden = false;
  bool isDockedLeft = false;

  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _startHideTimer();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      if (!showThemeMenu) {
        _hideToNearestEdge();
      }
    });
  }

  void _hideToNearestEdge() {
    final size = MediaQuery.of(context).size;
    final centerX = fabLeft + 29;
    final isLeft = centerX < size.width / 2;

    setState(() {
      isFabHidden = true;
      isDockedLeft = isLeft;
      fabLeft = isLeft ? -18 : size.width - 40;
    });
  }

  void _showFabAgain() {
    final size = MediaQuery.of(context).size;

    setState(() {
      isFabHidden = false;
      fabLeft = isDockedLeft ? 8 : size.width - 66;
    });

    _startHideTimer();
  }

  void _toggleThemeMenu() {
    if (isFabHidden) {
      _showFabAgain();
      return;
    }

    setState(() {
      showThemeMenu = !showThemeMenu;
    });

    if (showThemeMenu) {
      _hideTimer?.cancel();
    } else {
      _startHideTimer();
    }
  }

  void _selectTheme(int index) {
    widget.themeController.setTheme(index);
    setState(() {
      showThemeMenu = false;
      isFabHidden = false;
    });
    _startHideTimer();
  }

  void _snapToNearestEdge() {
    final size = MediaQuery.of(context).size;
    final isLeft = fabLeft + 29 < size.width / 2;

    setState(() {
      isDockedLeft = isLeft;
      fabLeft = isLeft ? 8 : size.width - 66;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final size = MediaQuery.of(context).size;
    final safeHeight = size.height - 140;

    if (fabTop > safeHeight) fabTop = safeHeight;
    if (fabTop <= 0) fabTop = size.height - 180;

    if (!isFabHidden) {
      fabLeft = isDockedLeft ? 8 : size.width - 66;
    }
  }

  Widget _buildAnimatedThemeButton({
    required Color color,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return AnimatedScale(
      scale: showThemeMenu ? 1 : 0.7,
      duration: const Duration(milliseconds: 180),
      child: AnimatedOpacity(
        opacity: showThemeMenu ? 1 : 0,
        duration: const Duration(milliseconds: 180),
        child: _ThemeCircleButton(
          color: color,
          icon: icon,
          selected: selected,
          onTap: onTap,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.themeController.palette;
    final size = MediaQuery.of(context).size;

    final double visibleLeft = isFabHidden
        ? (isDockedLeft ? -18.0 : size.width - 40.0)
        : fabLeft;

    return GestureDetector(
      onTap: () {
        if (showThemeMenu) {
          setState(() {
            showThemeMenu = false;
          });
          _startHideTimer();
        }
      },
      child: Stack(
        children: [
          Container(color: palette.background),
          Positioned(
            top: -70,
            right: -30,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: palette.backgroundAccent.withOpacity(0.22),
                borderRadius: BorderRadius.circular(140),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -30,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: palette.primary.withOpacity(0.14),
                borderRadius: BorderRadius.circular(120),
              ),
            ),
          ),
          SafeArea(child: widget.child),

          if (showThemeMenu && !isFabHidden) ...[
            if (isDockedLeft) ...[
              Positioned(
                left: fabLeft + 62,
                top: fabTop - 64,
                child: _buildAnimatedThemeButton(
                  color: const Color(0xFF8A6DFF),
                  icon: Icons.auto_awesome_rounded,
                  selected: widget.themeController.themeIndex == 0,
                  onTap: () => _selectTheme(0),
                ),
              ),
              Positioned(
                left: fabLeft + 70,
                top: fabTop,
                child: _buildAnimatedThemeButton(
                  color: const Color(0xFFFF8BC2),
                  icon: Icons.favorite_rounded,
                  selected: widget.themeController.themeIndex == 1,
                  onTap: () => _selectTheme(1),
                ),
              ),
              Positioned(
                left: fabLeft + 62,
                top: fabTop + 64,
                child: _buildAnimatedThemeButton(
                  color: const Color(0xFF72D7C8),
                  icon: Icons.eco_rounded,
                  selected: widget.themeController.themeIndex == 2,
                  onTap: () => _selectTheme(2),
                ),
              ),
            ] else ...[
              Positioned(
                left: fabLeft - 52,
                top: fabTop - 64,
                child: _buildAnimatedThemeButton(
                  color: const Color(0xFF8A6DFF),
                  icon: Icons.auto_awesome_rounded,
                  selected: widget.themeController.themeIndex == 0,
                  onTap: () => _selectTheme(0),
                ),
              ),
              Positioned(
                left: fabLeft - 60,
                top: fabTop,
                child: _buildAnimatedThemeButton(
                  color: const Color(0xFFFF8BC2),
                  icon: Icons.favorite_rounded,
                  selected: widget.themeController.themeIndex == 1,
                  onTap: () => _selectTheme(1),
                ),
              ),
              Positioned(
                left: fabLeft - 52,
                top: fabTop + 64,
                child: _buildAnimatedThemeButton(
                  color: const Color(0xFF72D7C8),
                  icon: Icons.eco_rounded,
                  selected: widget.themeController.themeIndex == 2,
                  onTap: () => _selectTheme(2),
                ),
              ),
            ],
          ],

          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            left: visibleLeft,
            top: fabTop,
            child: GestureDetector(
              onPanStart: (_) {
                _hideTimer?.cancel();
                if (isFabHidden) {
                  _showFabAgain();
                }
              },
              onPanUpdate: (details) {
                setState(() {
                  fabLeft += details.delta.dx;
                  fabTop += details.delta.dy;

                  if (fabLeft < 8) fabLeft = 8;
                  if (fabTop < 8) fabTop = 8;
                  if (fabLeft > size.width - 66) fabLeft = size.width - 66;
                  if (fabTop > size.height - 120) fabTop = size.height - 120;
                });
              },
              onPanEnd: (_) {
                _snapToNearestEdge();
                _startHideTimer();
              },
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: _toggleThemeMenu,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: palette.secondary,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: palette.secondary.withOpacity(0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      isFabHidden
                          ? (isDockedLeft
                              ? Icons.chevron_right_rounded
                              : Icons.chevron_left_rounded)
                          : (showThemeMenu
                              ? Icons.close_rounded
                              : Icons.palette_rounded),
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeCircleButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeCircleButton({
    required this.color,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? Colors.white : Colors.transparent,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.35),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}