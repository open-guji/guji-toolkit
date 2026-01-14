# 古籍风格主题重构文档

## 📋 重构概述

项目主题已从标准 Material Design 更新为**古籍风格设计**，参考了 kaiyuanguji-web 项目的视觉设计。

**重构日期**: 2025-01-05
**影响范围**: 全局主题配置

---

## 🎨 设计理念

采用中国古籍的视觉元素，营造传统典雅的阅读体验：

- **宣纸色背景** - 模拟古籍纸张的温润质感
- **墨黑色文字** - 传统墨迹的深沉典雅
- **朱砂红强调** - 古籍批注的朱砂印记
- **思源宋体** - 适合中文阅读的宋体字形

---

## 🎨 配色方案

### 主色调

```dart
static const Color paperColor = Color(0xFFF5F2E9);     // 宣纸色 - 背景
static const Color inkBlack = Color(0xFF2C2C2C);       // 墨黑色 - 主文字
static const Color vermilionRed = Color(0xFF8B0000);   // 朱砂红 - 强调色
static const Color lightInk = Color(0xFF666666);       // 淡墨色 - 次要文字
static const Color borderColor = Color(0xFFD4CDB8);   // 边框色 - 分隔线
```

### 颜色应用

| 元素 | 颜色 | 色值 | 说明 |
|------|------|------|------|
| 页面背景 | 宣纸色 | #F5F2E9 | 温润的纸张质感 |
| 标题文字 | 墨黑色 | #2C2C2C | 醒目的墨迹效果 |
| 正文文字 | 墨黑色 | #2C2C2C | 清晰易读 |
| 辅助文字 | 淡墨色 | #666666 | 层次分明 |
| 主按钮 | 朱砂红 | #8B0000 | 传统印章色 |
| 边框线条 | 边框色 | #D4CDB8 | 柔和的分隔 |

---

## 🔤 字体设计

### 主字体：思源宋体（Noto Serif SC）

通过 Google Fonts 引入：

```yaml
dependencies:
  google_fonts: ^6.2.1
```

### 字体应用

所有文本样式均使用思源宋体，包括：

- **Display 系列** - 大标题，57px - 36px
- **Headline 系列** - 中标题，32px - 24px
- **Title 系列** - 小标题，22px - 14px
- **Body 系列** - 正文，16px - 12px
- **Label 系列** - 标签，14px - 11px

### 字体特性

- **行高（height）**: 1.6 - 1.8，提高阅读舒适度
- **字间距（letterSpacing）**: 0.1 - 0.5，适合中文排版
- **字重（fontWeight）**: 400（常规）- 600（粗体）

---

## 🧩 组件主题

### AppBar（顶部栏）

```dart
AppBarTheme(
  backgroundColor: paperColor,      // 宣纸色背景
  foregroundColor: inkBlack,        // 墨黑色文字
  elevation: 0,                     // 无阴影，扁平化
  iconTheme: IconThemeData(
    color: vermilionRed,            // 朱砂红图标
  ),
)
```

### Card（卡片）

```dart
CardThemeData(
  color: paperColor,                // 宣纸色背景
  elevation: 2,                     // 轻微阴影
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(8),
    side: BorderSide(
      color: borderColor,           // 边框色
      width: 1,
    ),
  ),
)
```

### Button（按钮）

#### ElevatedButton（主按钮）

```dart
ElevatedButton.styleFrom(
  backgroundColor: vermilionRed,    // 朱砂红背景
  foregroundColor: paperColor,      // 宣纸色文字
  elevation: 2,
  padding: EdgeInsets.symmetric(
    horizontal: 24,
    vertical: 12,
  ),
)
```

#### OutlinedButton（边框按钮）

```dart
OutlinedButton.styleFrom(
  foregroundColor: vermilionRed,    // 朱砂红文字
  side: BorderSide(
    color: vermilionRed,            // 朱砂红边框
    width: 1,
  ),
)
```

#### TextButton（文本按钮）

```dart
TextButton.styleFrom(
  foregroundColor: vermilionRed,    // 朱砂红文字
)
```

### TextField（输入框）

```dart
InputDecorationTheme(
  filled: true,
  fillColor: paperColor,            // 宣纸色填充
  border: OutlineInputBorder(
    borderSide: BorderSide(
      color: borderColor,           // 边框色
    ),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(
      color: vermilionRed,          // 聚焦时朱砂红
      width: 2,
    ),
  ),
)
```

### Checkbox（复选框）

```dart
CheckboxThemeData(
  fillColor: WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.selected)) {
      return vermilionRed;          // 选中时朱砂红
    }
    return null;
  }),
  checkColor: WidgetStateProperty.all(paperColor),  // 勾选标记宣纸色
)
```

### NavigationRail（侧边栏导航）

```dart
NavigationRailThemeData(
  backgroundColor: paperColor,               // 宣纸色背景
  selectedIconTheme: IconThemeData(
    color: vermilionRed,                    // 选中时朱砂红
  ),
  unselectedIconTheme: IconThemeData(
    color: lightInk,                        // 未选中淡墨色
  ),
)
```

---

## 📐 响应式设计

### 内容区域最大宽度

```dart
static double getContentMaxWidth(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  if (screenWidth > 1400) {
    return 1200;                    // 大屏：固定1200px
  } else if (screenWidth > 900) {
    return screenWidth * 0.85;      // 中屏：85%宽度
  } else {
    return screenWidth;             // 小屏：全宽
  }
}
```

### 内容区域内边距

```dart
static EdgeInsets getContentPadding(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  if (screenWidth > 900) {
    return EdgeInsets.all(32);      // 大屏：32px
  } else if (screenWidth > 600) {
    return EdgeInsets.all(24);      // 中屏：24px
  } else {
    return EdgeInsets.all(16);      // 小屏：16px
  }
}
```

### 卡片间距

```dart
static double getCardSpacing(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  if (screenWidth > 900) {
    return 24;                      // 大屏：24px
  } else if (screenWidth > 600) {
    return 16;                      // 中屏：16px
  } else {
    return 12;                      // 小屏：12px
  }
}
```

---

## 📦 文件变更

### 修改的文件

**lib/app/theme/theme.dart**

- ✅ 更新配色方案为古籍风格
- ✅ 应用思源宋体（Noto Serif SC）
- ✅ 配置所有组件主题
- ✅ 添加响应式设计辅助方法
- ✅ 修复 Material 3 API 兼容性

**pubspec.yaml**

- ✅ 添加 `google_fonts: ^6.2.1` 依赖

---

## 🔧 技术细节

### Material 3 API 更新

在主题配置中使用了最新的 Material 3 API：

#### ColorScheme

```dart
// ❌ 旧版（已弃用）
background: paperColor,
onBackground: inkBlack,
surfaceVariant: Color(0xFFEBE7DC),

// ✅ 新版
// background/onBackground 已合并到 surface/onSurface
surfaceContainerHighest: Color(0xFFEBE7DC),
```

#### WidgetState

```dart
// ❌ 旧版（已弃用）
MaterialStateProperty.resolveWith((states) {
  if (states.contains(MaterialState.selected)) {
    // ...
  }
})

// ✅ 新版
WidgetStateProperty.resolveWith((states) {
  if (states.contains(WidgetState.selected)) {
    // ...
  }
})
```

#### Color Opacity

```dart
// ❌ 旧版（精度损失）
inkBlack.withOpacity(0.1)

// ✅ 新版（无精度损失）
inkBlack.withValues(alpha: 0.1)
```

#### CardTheme

```dart
// ❌ 旧版
cardTheme: CardTheme(...)

// ✅ 新版
cardTheme: CardThemeData(...)
```

---

## 🎯 视觉效果

### 整体氛围

- **温润典雅** - 宣纸色背景营造温暖舒适的阅读环境
- **层次分明** - 墨色深浅变化清晰区分信息层级
- **重点突出** - 朱砂红恰当点缀，引导用户操作
- **传统现代** - 古籍美学与现代UI设计完美融合

### 阅读体验

- **高对比度** - 墨黑色文字在宣纸色背景上清晰易读
- **舒适行高** - 1.6-1.8 的行高适合长文本阅读
- **适中字距** - 0.1-0.5px 字间距平衡紧凑与舒展
- **优雅字体** - 思源宋体的衬线设计提升阅读品质

---

## 🌓 深色模式

目前深色模式暂时使用相同的古籍风格主题：

```dart
static ThemeData get darkTheme {
  // 暂时保留深色主题，使用相同的古籍风格
  // 未来可以实现夜间阅读模式
  return lightTheme;
}
```

**未来计划**：

- 可以实现"夜间阅读模式"，使用深色宣纸底色
- 参考古籍夜读场景，调整为更柔和的色调
- 可能的配色：深灰底色 + 浅黄文字 + 暗红强调

---

## 📚 参考资源

### 设计参考

- **kaiyuanguji-web 项目** - 古籍风格主题设计
- [中国古籍版式](https://zh.wikipedia.org/wiki/中國古籍版式) - 传统排版研究
- [传统色彩](https://colors.ichuantong.cn/) - 中国传统色谱

### 字体资源

- [Noto Serif SC](https://fonts.google.com/noto/specimen/Noto+Serif+SC) - Google Fonts 思源宋体
- [思源宋体项目](https://source.typekit.com/source-han-serif/cn/) - Adobe & Google 开源字体

### 技术文档

- [Material 3 Design](https://m3.material.io/) - Material Design 3 规范
- [Flutter Theming](https://docs.flutter.dev/cookbook/design/themes) - Flutter 主题指南
- [Google Fonts Package](https://pub.dev/packages/google_fonts) - Flutter 字体包

---

## ✅ 重构清单

- [x] 添加 google_fonts 依赖
- [x] 定义古籍风格配色常量
- [x] 更新 ColorScheme 为古籍配色
- [x] 应用思源宋体到所有文本样式
- [x] 配置 AppBar 主题
- [x] 配置 Card 主题
- [x] 配置 Button 主题（Elevated/Outlined/Text）
- [x] 配置 TextField 主题
- [x] 配置 Checkbox 主题
- [x] 配置 Divider 主题
- [x] 配置 NavigationRail 主题
- [x] 添加响应式设计辅助方法
- [x] 修复 Material 3 API 兼容性
- [x] 代码分析通过（无错误）
- [x] 应用运行验证
- [x] 编写文档

---

## 🎉 重构成果

✅ 成功将项目主题从标准 Material Design 更新为古籍风格
✅ 视觉体验焕然一新，更符合古籍工具的定位
✅ 保持代码现代化，使用最新 Material 3 API
✅ 提供响应式设计支持，适配不同屏幕
✅ 代码质量高，无任何分析错误
✅ 详细文档记录，便于维护和扩展

**古籍工具包，以传统之美，承载现代科技！** 📚✨
