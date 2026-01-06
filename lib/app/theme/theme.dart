import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 古籍工具包主题配置
/// 采用古籍风格设计：宣纸色背景、墨黑色文字、朱砂红强调色
class AppTheme {
  // 古籍风格配色
  static const Color paperColor = Color(0xFFF5F2E9); // 宣纸色
  static const Color inkBlack = Color(0xFF2C2C2C); // 墨黑色
  static const Color vermilionRed = Color(0xFF8B0000); // 朱砂红
  static const Color lightInk = Color(0xFF666666); // 淡墨色
  static const Color borderColor = Color(0xFFD4CDB8); // 边框色

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: vermilionRed,
        onPrimary: paperColor,
        secondary: inkBlack,
        onSecondary: paperColor,
        surface: paperColor,
        onSurface: inkBlack,
        error: vermilionRed,
        onError: paperColor,
        outline: borderColor,
        surfaceContainerHighest: Color(0xFFEBE7DC),
        onSurfaceVariant: lightInk,
      ),

      // 文字主题 - 使用思源宋体
      textTheme: GoogleFonts.notoSerifScTextTheme().copyWith(
        displayLarge: GoogleFonts.notoSerifSc(
          fontSize: 57,
          fontWeight: FontWeight.w400,
          color: inkBlack,
          letterSpacing: -0.25,
        ),
        displayMedium: GoogleFonts.notoSerifSc(
          fontSize: 45,
          fontWeight: FontWeight.w400,
          color: inkBlack,
        ),
        displaySmall: GoogleFonts.notoSerifSc(
          fontSize: 36,
          fontWeight: FontWeight.w400,
          color: inkBlack,
        ),
        headlineLarge: GoogleFonts.notoSerifSc(
          fontSize: 32,
          fontWeight: FontWeight.w500,
          color: inkBlack,
        ),
        headlineMedium: GoogleFonts.notoSerifSc(
          fontSize: 28,
          fontWeight: FontWeight.w500,
          color: inkBlack,
        ),
        headlineSmall: GoogleFonts.notoSerifSc(
          fontSize: 24,
          fontWeight: FontWeight.w500,
          color: inkBlack,
        ),
        titleLarge: GoogleFonts.notoSerifSc(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: inkBlack,
          letterSpacing: 0,
        ),
        titleMedium: GoogleFonts.notoSerifSc(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: inkBlack,
          letterSpacing: 0.15,
        ),
        titleSmall: GoogleFonts.notoSerifSc(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: inkBlack,
          letterSpacing: 0.1,
        ),
        bodyLarge: GoogleFonts.notoSerifSc(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: inkBlack,
          letterSpacing: 0.5,
          height: 1.8,
        ),
        bodyMedium: GoogleFonts.notoSerifSc(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: inkBlack,
          letterSpacing: 0.25,
          height: 1.8,
        ),
        bodySmall: GoogleFonts.notoSerifSc(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: lightInk,
          letterSpacing: 0.4,
          height: 1.6,
        ),
        labelLarge: GoogleFonts.notoSerifSc(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: inkBlack,
          letterSpacing: 0.1,
        ),
        labelMedium: GoogleFonts.notoSerifSc(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: inkBlack,
          letterSpacing: 0.5,
        ),
        labelSmall: GoogleFonts.notoSerifSc(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: lightInk,
          letterSpacing: 0.5,
        ),
      ),

      // AppBar 主题
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: paperColor,
        foregroundColor: inkBlack,
        elevation: 0,
        titleTextStyle: GoogleFonts.notoSerifSc(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: inkBlack,
          letterSpacing: 0.15,
        ),
        iconTheme: const IconThemeData(color: vermilionRed),
      ),

      // 卡片主题
      cardTheme: CardThemeData(
        color: paperColor,
        elevation: 2,
        shadowColor: inkBlack.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: borderColor, width: 1),
        ),
      ),

      // 按钮主题
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: vermilionRed,
          foregroundColor: paperColor,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: GoogleFonts.notoSerifSc(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: vermilionRed,
          side: const BorderSide(color: vermilionRed, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: GoogleFonts.notoSerifSc(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: vermilionRed,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: GoogleFonts.notoSerifSc(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // 输入框主题
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: paperColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: vermilionRed, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: vermilionRed),
        ),
        labelStyle: GoogleFonts.notoSerifSc(
          fontSize: 14,
          color: lightInk,
        ),
        hintStyle: GoogleFonts.notoSerifSc(
          fontSize: 14,
          color: lightInk,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),

      // Checkbox 主题
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return vermilionRed;
          }
          return null;
        }),
        checkColor: WidgetStateProperty.all(paperColor),
      ),

      // Divider 主题
      dividerTheme: const DividerThemeData(
        color: borderColor,
        thickness: 1,
      ),

      // 导航栏主题
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: paperColor,
        selectedIconTheme: const IconThemeData(color: vermilionRed),
        unselectedIconTheme: IconThemeData(color: lightInk),
        selectedLabelTextStyle: GoogleFonts.notoSerifSc(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: vermilionRed,
        ),
        unselectedLabelTextStyle: GoogleFonts.notoSerifSc(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: lightInk,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    // 暂时保留深色主题，使用相同的古籍风格
    // 未来可以实现夜间阅读模式
    return lightTheme;
  }

  /// 获取内容区域最大宽度（响应式设计）
  static double getContentMaxWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1400) {
      return 1200;
    } else if (screenWidth > 900) {
      return screenWidth * 0.85;
    } else {
      return screenWidth;
    }
  }

  /// 获取内容区域内边距（响应式设计）
  static EdgeInsets getContentPadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 900) {
      return const EdgeInsets.all(32);
    } else if (screenWidth > 600) {
      return const EdgeInsets.all(24);
    } else {
      return const EdgeInsets.all(16);
    }
  }

  /// 获取卡片间距（响应式设计）
  static double getCardSpacing(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 900) {
      return 24;
    } else if (screenWidth > 600) {
      return 16;
    } else {
      return 12;
    }
  }
}
