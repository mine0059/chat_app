import 'package:flutter/material.dart';

enum IconPosition { left, right }

/// Custom Filled Button with Gradient Support
class CustomFilledButton extends StatelessWidget {
  const CustomFilledButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isFullWidth = false,
    // this.height = 56,
    this.height = 48,
    this.width = 150,
    this.borderRadius = 24,
    this.useGradient = true,
    this.gradientColors,
    this.gradientBegin = Alignment.topLeft,
    this.gradientEnd = Alignment.bottomRight,
    this.isEnabled = true,
    this.isLoading = false,
    this.icon,
    this.iconPosition = IconPosition.left,
    this.backgroundColor,
    this.labelColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isFullWidth;
  final double height;
  final double width;
  final double borderRadius;
  final bool useGradient;
  final List<Color>? gradientColors;
  final AlignmentGeometry gradientBegin;
  final AlignmentGeometry gradientEnd;
  final bool isEnabled;
  final bool isLoading;
  final Widget? icon;
  final IconPosition iconPosition;
  final Color? backgroundColor;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    // If gradient is enabled, wrap FilledButton in gradient container
    if (useGradient) {
      return _buildGradientButton(context);
    }

    // Standard FilledButton without gradient
    return _buildStandardButton(context);
  }

  /// Builds standard FilledButton
  Widget _buildStandardButton(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : width,
      height: height,
      child: FilledButton(
        onPressed: (isEnabled && !isLoading) ? onPressed : null,
        style: FilledButton.styleFrom(
          backgroundColor: backgroundColor ?? Colors.blueAccent,
          disabledBackgroundColor: Colors.grey,
          disabledForegroundColor: Colors.white.withOpacity(0.5),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: _buildButtonContent(context),
      ),
    );
  }

  /// Builds gradient FilledButton
  Widget _buildGradientButton(BuildContext context) {
    final colors = gradientColors ?? [Colors.blue, Colors.blueAccent];

    final isDisabled = !isEnabled || onPressed == null;

    return Container(
      width: isFullWidth ? double.infinity : width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: (isLoading || isDisabled) ? [Colors.grey, Colors.grey.shade700] : colors,
          begin: gradientBegin,
          end: gradientEnd,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: FilledButton(
        onPressed: (isEnabled && !isLoading) ? onPressed : null,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          disabledForegroundColor: Colors.white.withOpacity(0.5),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
        ),
        child: _buildButtonContent(context),
      ),
    );
  }

  /// Builds button content (label + loading indicator)
  Widget _buildButtonContent(BuildContext context) {
    if (isLoading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Text(label),
        ],
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon!,
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: labelColor ?? Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    return Text(
      label,
      style: TextStyle(
        fontSize: 14,
        color: labelColor ?? Colors.white,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
