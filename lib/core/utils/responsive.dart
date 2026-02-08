import 'package:flutter/material.dart';

class Responsive {
  // Keeping these for backward compatibility if used as static methods elsewhere
  static double width(BuildContext context, double percentage) =>
      MediaQuery.of(context).size.width * (percentage / 100);

  static double height(BuildContext context, double percentage) =>
      MediaQuery.of(context).size.height * (percentage / 100);

  static double sp(BuildContext context, double fontSize) =>
      fontSize * (MediaQuery.of(context).size.width / 375);
}

extension ResponsiveContext on BuildContext {
  MediaQueryData get _mq => MediaQuery.of(this);

  double get screenWidth => _mq.size.width;
  double get screenHeight => _mq.size.height;

  double wp(double p) => screenWidth * (p / 100);
  double hp(double p) => screenHeight * (p / 100);

  double w(double p) => screenWidth * (p / 100);
  double h(double p) => screenHeight * (p / 100);
  double s(double size) => size * (screenWidth / 375);

  EdgeInsets get screenPadding => EdgeInsets.symmetric(
    horizontal: screenWidth * 0.05,
    vertical: screenHeight * 0.01,
  );
}
