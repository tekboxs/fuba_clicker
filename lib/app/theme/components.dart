import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'tokens.dart';

class GlassCard extends StatelessWidget {
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final Color? borderColor;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.borderColor,
    this.boxShadow,
    this.gradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedPadding = padding ?? const EdgeInsets.all(16);
    final resolvedMargin = margin ?? EdgeInsets.zero;
    final resolvedRadius = borderRadius ?? AppRadii.lg;

    return Padding(
      padding: resolvedMargin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(resolvedRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: resolvedPadding,
            decoration: BoxDecoration(
              gradient: gradient ??
                  LinearGradient(
                    colors: [
                      AppColors.card.withOpacity(0.6),
                      AppColors.card.withOpacity(0.4),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
              borderRadius: BorderRadius.circular(resolvedRadius),
              border: Border.all(
                color: borderColor ?? AppColors.border,
                width: 1.5,
              ),
              boxShadow: boxShadow ?? AppShadows.level2,
            ),
            child: onTap != null
                ? InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(resolvedRadius),
                    child: child,
                  )
                : child,
          ),
        ),
      ),
    );
  }
}

class GradientText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Gradient gradient;

  const GradientText(
    this.text, {
    super.key,
    this.style,
    this.gradient = AppGradients.purpleCyan,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        text,
        style: (style ?? Theme.of(context).textTheme.headlineMedium)!.copyWith(
          color: Colors.white,
        ),
      ),
    );
  }
}

class GlowOrb extends StatelessWidget {
  final double size;
  final Color color;
  final double blur;

  const GlowOrb({
    super.key,
    required this.size,
    required this.color,
    this.blur = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withOpacity(0.3),
            color.withOpacity(0.1),
            Colors.transparent,
          ],
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(),
      ),
    );
  }
}

class AppCard extends StatefulWidget {
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final GestureTapCallback? onTap;

  const AppCard({super.key, this.child, this.padding, this.margin, this.onTap});

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final EdgeInsetsGeometry resolvedPadding =
        widget.padding ?? const EdgeInsets.all(16);
    final EdgeInsetsGeometry resolvedMargin = widget.margin ?? EdgeInsets.zero;

    return Padding(
      padding: resolvedMargin,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        child: AnimatedContainer(
          duration: AppDurations.fast,
          curve: AppCurves.standard,
          padding: resolvedPadding,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            boxShadow: _pressed ? [] : AppShadows.level1,
            border: Border.all(color: AppColors.border),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadii.lg),
              onTap: widget.onTap,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

class AppButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Gradient? gradient;
  final Color? borderColor;
  final List<BoxShadow>? boxShadow;
  final EdgeInsetsGeometry? padding;

  const AppButton.primary({
    super.key,
    required this.child,
    this.onPressed,
    this.padding,
  })  : gradient = AppGradients.purpleFuchsia,
        borderColor = AppColors.purple400,
        boxShadow = AppShadows.glowPurple;

  const AppButton.secondary({
    super.key,
    required this.child,
    this.onPressed,
    this.padding,
  })  : gradient = null,
        borderColor = AppColors.border,
        boxShadow = null;

  const AppButton.success({
    super.key,
    required this.child,
    this.onPressed,
    this.padding,
  })  : gradient = AppGradients.emeraldGreen,
        borderColor = AppColors.emerald400,
        boxShadow = AppShadows.glowEmerald;

  const AppButton.warning({
    super.key,
    required this.child,
    this.onPressed,
    this.padding,
  })  : gradient = AppGradients.amberYellow,
        borderColor = AppColors.amber400,
        boxShadow = AppShadows.glowAmber;

  const AppButton.text({
    super.key,
    required this.child,
    this.onPressed,
    this.padding,
  })  : gradient = null,
        borderColor = null,
        boxShadow = null;

  @override
  Widget build(BuildContext context) {
    final resolvedPadding =
        padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 12);

    if (gradient == null && borderColor == null) {
      return TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: resolvedPadding,
          foregroundColor: AppColors.purple400,
        ),
        child: child,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(AppRadii.md),
            child: Container(
              padding: resolvedPadding,
              decoration: BoxDecoration(
                gradient: gradient ??
                    LinearGradient(
                      colors: [
                        AppColors.secondary.withOpacity(0.6),
                        AppColors.secondary.withOpacity(0.4),
                      ],
                    ),
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(
                  color: borderColor ?? AppColors.border,
                  width: 1.5,
                ),
                boxShadow: boxShadow,
              ),
              child: DefaultTextStyle(
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final List<Widget>? actions;
  final bool center;

  const AppAppBar({super.key, this.title, this.actions, this.center = true});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) => AppBar(
        centerTitle: center,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: title,
        actions: actions,
      );
}

class AppSectionTitle extends StatelessWidget {
  final String text;
  final EdgeInsetsGeometry? padding;

  const AppSectionTitle(this.text, {super.key, this.padding});

  @override
  Widget build(BuildContext context) {
    final EdgeInsetsGeometry resolvedPadding =
        padding ?? const EdgeInsets.fromLTRB(8, 8, 8, 12);
    return Padding(
      padding: resolvedPadding,
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }
}

class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;

  const AnimatedGradientBackground({super.key, required this.child});

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState
    extends State<AnimatedGradientBackground> {
  Timer? _hourCheckTimer;
  int _currentHour = DateTime.now().hour;

  @override
  void initState() {
    super.initState();
    _currentHour = DateTime.now().hour;
    _startHourCheckTimer();
  }

  @override
  void dispose() {
    _hourCheckTimer?.cancel();
    super.dispose();
  }

  void _startHourCheckTimer() {
    _hourCheckTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      final newHour = DateTime.now().hour;
      if (newHour != _currentHour) {
        setState(() {
          _currentHour = newHour;
        });
      }
    });
  }

  String _getBackgroundAsset() {
    if (_currentHour >= 6 && _currentHour < 12) {
      return 'assets/images/background_morning.png';
    } else if (_currentHour >= 12 && _currentHour < 17) {
      return 'assets/images/background_afternoon.png';
    } else if (_currentHour >= 17 && _currentHour < 19) {
      return 'assets/images/background_late_afternoon.png';
    } else {
      return 'assets/images/background_night.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
            child: Image.asset(
              _getBackgroundAsset(),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: const BoxDecoration(
                    gradient: AppGradients.backgroundGradient,
                  ),
                );
              },
            ),
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.6),
                  Colors.black.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class CategoryBadge extends StatelessWidget {
  final String category;
  final String label;

  const CategoryBadge({
    super.key,
    required this.category,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getCategoryColors(category);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: colors['gradient'] as LinearGradient,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(
          color: colors['border'] as Color,
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colors['text'] as Color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Map<String, dynamic> _getCategoryColors(String category) {
    switch (category) {
      case 'green':
        return {
          'gradient': AppGradients.emeraldGreen,
          'border': AppColors.emerald400.withOpacity(0.4),
          'text': AppColors.emerald400,
        };
      case 'blue':
        return {
          'gradient': AppGradients.blueCyan,
          'border': AppColors.blue400.withOpacity(0.4),
          'text': AppColors.blue400,
        };
      case 'purple':
        return {
          'gradient': AppGradients.purpleFuchsia,
          'border': AppColors.purple400.withOpacity(0.4),
          'text': AppColors.purple400,
        };
      case 'gold':
        return {
          'gradient': AppGradients.amberYellow,
          'border': AppColors.amber400.withOpacity(0.4),
          'text': AppColors.amber400,
        };
      case 'pink':
        return {
          'gradient': AppGradients.pinkFuchsia,
          'border': AppColors.pink400.withOpacity(0.4),
          'text': AppColors.pink400,
        };
      case 'red':
        return {
          'gradient': AppGradients.redRose,
          'border': AppColors.red400.withOpacity(0.4),
          'text': AppColors.red400,
        };
      default:
        return {
          'gradient': AppGradients.purpleCyan,
          'border': AppColors.purple400.withOpacity(0.4),
          'text': AppColors.purple400,
        };
    }
  }
}

class ModernHeaderBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;

  const ModernHeaderBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(AppRadii.xl),
        bottomRight: Radius.circular(AppRadii.xl),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.purple900.withOpacity(0.6),
                AppColors.fuchsia900.withOpacity(0.6),
                AppColors.purple900.withOpacity(0.6),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            border: const Border(
              bottom: BorderSide(
                color: AppColors.border,
                width: 1.5,
              ),
            ),
            boxShadow: AppShadows.level2,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  gradient: AppGradients.purpleFuchsia,
                  boxShadow: AppShadows.glowPurple,
                ),
                child: const Center(
                  child: Text(
                    '🌽',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          AppGradients.purpleCyan.createShader(
                        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                      ),
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.purple400.withOpacity(0.6),
                          letterSpacing: 1.2,
                        ),
                      ),
                  ],
                ),
              ),
              if (actions != null) ...actions!,
            ],
          ),
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Gradient gradient;
  final Color iconColor;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.gradient,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(
              color: iconColor.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: iconColor.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 16,
              ),
              const SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 9,
                      color: iconColor.withOpacity(0.7),
                    ),
                  ),
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [iconColor, iconColor.withOpacity(0.8)],
                    ).createShader(bounds),
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


