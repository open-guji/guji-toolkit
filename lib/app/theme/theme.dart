import 'package:flutter/material.dart';

/// 古籍工具包主题配置
/// 采用古籍风格设计：宣纸色背景、墨黑色文字、朱砂红强调色
class AppTheme {
  // 古籍风格配色
  static const Color paperColor = Color(0xFFF5F2E9); // 宣纸色
  static const Color inkBlack = Color(0xFF2C2C2C); // 墨黑色
  static const Color vermilionRed = Color(0xFF8B0000); // 朱砂红
  static const Color lightInk = Color(0xFF666666); // 淡墨色
  static const Color borderColor = Color(0xFFD4CDB8); // 边框色

  // 主体字体栈：优先使用系统自带的宋体/明体，实现"秒开"且零网络依赖
  static const String mainFontFamily =
      'SimSun, "Songti SC", "STSong", "Noto Serif SC", serif';

  // 字体栈列表形式，用于 fallback (虽主要通过 font-family 字符串控制，但 Flutter 有时也需要 fallback 列表)
  static const List<String> fontFallbacks = [
    'SimSun',
    'Songti SC',
    'STSong',
    'Noto Serif SC',
    'serif',
  ];

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,

      // 直接指定字体族字符串，让浏览器/操作系统去匹配
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

      // 文字主题 - 全部使用系统宋体
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 57,
          fontWeight: FontWeight.w400,
          color: inkBlack,
          letterSpacing: -0.25,
          fontFamily: 'SimSun',
          fontFamilyFallback: fontFallbacks,
        ),
        displayMedium: TextStyle(
          fontSize: 45,
          fontWeight: FontWeight.w400,
          color: inkBlack,
          fontFamily: 'SimSun',
          fontFamilyFallback: fontFallbacks,
        ),
        displaySmall: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w400,
          color: inkBlack,
          fontFamily: 'SimSun',
          fontFamilyFallback: fontFallbacks,
        ),
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w500,
          color: inkBlack,
          fontFamily: 'SimSun',
          fontFamilyFallback: fontFallbacks,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w500,
          color: inkBlack,
          fontFamily: 'SimSun',
          fontFamilyFallback: fontFallbacks,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w500,
          color: inkBlack,
          fontFamily: 'SimSun',
          fontFamilyFallback: fontFallbacks,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: inkBlack,
          letterSpacing: 0,
          fontFamily: 'SimSun',
          fontFamilyFallback: fontFallbacks,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: inkBlack,
          letterSpacing: 0.15,
          fontFamily: 'SimSun',
          fontFamilyFallback: fontFallbacks,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: inkBlack,
          letterSpacing: 0.1,
          fontFamily: 'SimSun',
          fontFamilyFallback: fontFallbacks,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: inkBlack,
          letterSpacing: 0.5,
          height: 1.8,
          fontFamily: 'SimSun',
          fontFamilyFallback: fontFallbacks,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: inkBlack,
          letterSpacing: 0.25,
          height: 1.8,
          fontFamily: 'SimSun',
          fontFamilyFallback: fontFallbacks,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: lightInk,
          letterSpacing: 0.4,
          height: 1.6,
          fontFamily: 'SimSun',
          fontFamilyFallback: fontFallbacks,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: inkBlack,
          letterSpacing: 0.1,
          fontFamily: 'SimSun',
          fontFamilyFallback: fontFallbacks,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: inkBlack,
          letterSpacing: 0.5,
          fontFamily: 'SimSun',
          fontFamilyFallback: fontFallbacks,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: lightInk,
          letterSpacing: 0.5,
          fontFamily: 'SimSun',
          fontFamilyFallback: fontFallbacks,
        ),
      ),

      // AppBar 主题
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: paperColor,
        foregroundColor: inkBlack,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: inkBlack,
          letterSpacing: 0.15,
          fontFamily: 'SimSun',
          fontFamilyFallback: fontFallbacks,
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
          textStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            fontFamily: 'SimSun',
            fontFamilyFallback: fontFallbacks,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: vermilionRed,
          side: const BorderSide(color: vermilionRed, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            fontFamily: 'SimSun',
            fontFamilyFallback: fontFallbacks,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: vermilionRed,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
            fontFamily: 'SimSun',
            fontFamilyFallback: fontFallbacks,
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
        labelStyle: TextStyle(
          fontSize: 14,
          color: lightInk,
          fontFamily: 'SimSun',
          fontFamilyFallback: fontFallbacks,
        ),
        hintStyle: TextStyle(
          fontSize: 14,
          color: lightInk,
          fontFamily: 'SimSun',
          fontFamilyFallback: fontFallbacks,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
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
      dividerTheme: const DividerThemeData(color: borderColor, thickness: 1),

      // 导航栏主题
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: paperColor,
        indicatorColor: Colors.grey.withAlpha(30),
        selectedIconTheme: const IconThemeData(color: vermilionRed),
        unselectedIconTheme: IconThemeData(color: lightInk),
        selectedLabelTextStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: vermilionRed,
          fontFamily: 'SimSun',
          fontFamilyFallback: fontFallbacks,
        ),
        unselectedLabelTextStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: lightInk,
          fontFamily: 'SimSun',
          fontFamilyFallback: fontFallbacks,
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
