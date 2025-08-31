// import 'package:flutter/material.dart';

// @immutable
// class AppTheme extends ThemeExtension<AppTheme> {
//   final Gradient primaryGradient;
//   final Color cardBg;
//   final Color surfaceBorder;
//   final Color glowColor;
//   final Color safeBlue;

//   // Text styles
//   final TextStyle title;
//   final TextStyle body;
//   final TextStyle chip;
//   final TextStyle percent;

//   const AppTheme({
//     required this.primaryGradient,
//     required this.cardBg,
//     required this.surfaceBorder,
//     required this.glowColor,
//     required this.safeBlue,
//     required this.title,
//     required this.body,
//     required this.chip,
//     required this.percent,
//   });

//   static AppTheme dark() {
//     return AppTheme(
//       primaryGradient: const LinearGradient(
//         colors: [Color(0xFF0A84FF), Color(0xFF64D2FF)],
//         begin: Alignment.topLeft,
//         end: Alignment.bottomRight,
//       ),
//       cardBg: const Color(0xFF2C2C2E),
//       surfaceBorder: const Color(0xFF3A3A3C),
//       glowColor: const Color(0xFF0A84FF),
//       safeBlue: const Color(0xFF0A84FF),
//       title: const TextStyle(
//         color: Colors.white,
//         fontSize: 18,
//         fontWeight: FontWeight.w600,
//         fontFamily: 'SF Pro Display',
//       ),
//       body: const TextStyle(
//         color: Colors.white,
//         fontSize: 15,
//         fontWeight: FontWeight.w500,
//         fontFamily: 'SF Pro Display',
//       ),
//       chip: const TextStyle(
//         color: Color(0xFF64D2FF),
//         fontSize: 12,
//         fontWeight: FontWeight.w600,
//         fontFamily: 'SF Pro Display',
//       ),
//       percent: const TextStyle(
//         color: Color(0xFF64D2FF),
//         fontSize: 15,
//         fontWeight: FontWeight.w600,
//         fontFamily: 'SF Pro Display',
//       ),
//     );
//   }

//   @override
//   AppTheme copyWith({
//     Gradient? primaryGradient,
//     Color? cardBg,
//     Color? surfaceBorder,
//     Color? glowColor,
//     Color? safeBlue,
//     TextStyle? title,
//     TextStyle? body,
//     TextStyle? chip,
//     TextStyle? percent,
//   }) {
//     return AppTheme(
//       primaryGradient: primaryGradient ?? this.primaryGradient,
//       cardBg: cardBg ?? this.cardBg,
//       surfaceBorder: surfaceBorder ?? this.surfaceBorder,
//       glowColor: glowColor ?? this.glowColor,
//       safeBlue: safeBlue ?? this.safeBlue,
//       title: title ?? this.title,
//       body: body ?? this.body,
//       chip: chip ?? this.chip,
//       percent: percent ?? this.percent,
//     );
//   }

//   @override
//   AppTheme lerp(ThemeExtension<AppTheme>? other, double t) {
//     if (other is! AppTheme) return this;
//     return AppTheme(
//       primaryGradient: LinearGradient(
//         colors: [
//           Color.lerp(
//                 (primaryGradient as LinearGradient).colors.first,
//                 (other.primaryGradient as LinearGradient).colors.first,
//                 t,
//               ) ??
//               Colors.transparent,
//           Color.lerp(
//                 (primaryGradient as LinearGradient).colors.last,
//                 (other.primaryGradient as LinearGradient).colors.last,
//                 t,
//               ) ??
//               Colors.transparent,
//         ],
//       ),
//       cardBg: Color.lerp(cardBg, other.cardBg, t) ?? cardBg,
//       surfaceBorder:
//           Color.lerp(surfaceBorder, other.surfaceBorder, t) ?? surfaceBorder,
//       glowColor: Color.lerp(glowColor, other.glowColor, t) ?? glowColor,
//       safeBlue: Color.lerp(safeBlue, other.safeBlue, t) ?? safeBlue,
//       title: TextStyle.lerp(title, other.title, t) ?? title,
//       body: TextStyle.lerp(body, other.body, t) ?? body,
//       chip: TextStyle.lerp(chip, other.chip, t) ?? chip,
//       percent: TextStyle.lerp(percent, other.percent, t) ?? percent,
//     );
//   }
// }
