import 'package:flutter/material.dart';

/// A reusable logo widget for the Athena app that handles different sizes and contexts
class AthenaLogo extends StatelessWidget {
  final AthenaLogoSize size;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final bool showBackground;

  const AthenaLogo({
    super.key,
    this.size = AthenaLogoSize.medium,
    this.backgroundColor,
    this.padding,
    this.showBackground = true,
  });

  /// Small logo for app bar and tight spaces
  const AthenaLogo.small({
    super.key,
    this.backgroundColor,
    this.padding,
    this.showBackground = true,
  }) : size = AthenaLogoSize.small;

  /// Medium logo for general use
  const AthenaLogo.medium({
    super.key,
    this.backgroundColor,
    this.padding,
    this.showBackground = true,
  }) : size = AthenaLogoSize.medium;

  /// Large logo for welcome screens and prominent displays
  const AthenaLogo.large({
    super.key,
    this.backgroundColor,
    this.padding,
    this.showBackground = true,
  }) : size = AthenaLogoSize.large;

  /// Extra large logo for splash screens and main branding
  const AthenaLogo.extraLarge({
    super.key,
    this.backgroundColor,
    this.padding,
    this.showBackground = true,
  }) : size = AthenaLogoSize.extraLarge;

  @override
  Widget build(BuildContext context) {
    final logoConfig = _getLogoConfig();

    Widget logoImage = Image.asset(
      'assets/images/logo.png',
      width: logoConfig.imageSize,
      height: logoConfig.imageSize,
      fit: BoxFit.contain,
    );

    if (padding != null) {
      logoImage = Padding(padding: padding!, child: logoImage);
    } else if (logoConfig.defaultPadding != null) {
      logoImage = Padding(
        padding: logoConfig.defaultPadding!,
        child: logoImage,
      );
    }

    if (!showBackground) {
      return logoImage;
    }

    return Container(
      width: logoConfig.containerSize,
      height: logoConfig.containerSize,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: logoConfig.isCircular ? BoxShape.circle : BoxShape.rectangle,
        borderRadius:
            logoConfig.isCircular
                ? null
                : BorderRadius.circular(logoConfig.borderRadius),
      ),
      child: logoImage,
    );
  }

  _LogoConfig _getLogoConfig() {
    switch (size) {
      case AthenaLogoSize.small:
        return _LogoConfig(
          containerSize: 32.0,
          imageSize: 20.0,
          defaultPadding: const EdgeInsets.all(4.0),
          borderRadius: 8.0,
          isCircular: false,
        );
      case AthenaLogoSize.medium:
        return _LogoConfig(
          containerSize: 48.0,
          imageSize: 32.0,
          defaultPadding: const EdgeInsets.all(6.0),
          borderRadius: 12.0,
          isCircular: false,
        );
      case AthenaLogoSize.large:
        return _LogoConfig(
          containerSize: 80.0,
          imageSize: 56.0,
          defaultPadding: const EdgeInsets.all(8.0),
          borderRadius: 16.0,
          isCircular: true,
        );
      case AthenaLogoSize.extraLarge:
        return _LogoConfig(
          containerSize: 120.0,
          imageSize: 88.0,
          defaultPadding: const EdgeInsets.all(12.0),
          borderRadius: 24.0,
          isCircular: true,
        );
    }
  }
}

enum AthenaLogoSize { small, medium, large, extraLarge }

class _LogoConfig {
  final double containerSize;
  final double imageSize;
  final EdgeInsets? defaultPadding;
  final double borderRadius;
  final bool isCircular;

  _LogoConfig({
    required this.containerSize,
    required this.imageSize,
    this.defaultPadding,
    required this.borderRadius,
    required this.isCircular,
  });
}
