# 文本选择功能修复说明

## 问题描述

在 Flutter Web 应用中，默认情况下所有文本都无法使用鼠标选中。这是 Flutter Web 的默认行为。

## 根本原因

Flutter Web 为了提供原生应用般的体验，默认禁用了文本选择功能。需要显式启用。

## 解决方案

### 1. 在 MainLayout 中启用文本选择（推荐）

⚠️ **重要**: `SelectionArea` 需要访问 `Overlay`，所以不能放在 `MaterialApp.builder` 中。正确的做法是放在有 Scaffold 的 layout 中。

```dart
// lib/core/widgets/main_layout.dart
@override
Widget build(BuildContext context) {
  return SelectionArea(  // 包裹整个 Scaffold
    child: Scaffold(
      body: Row(
        children: [
          NavigationRail(...),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: child),
        ],
      ),
    ),
  );
}
```

**为什么这样做？**
- ✅ `SelectionArea` 在 Scaffold 之后，可以访问 Overlay
- ✅ 覆盖整个应用的所有页面
- ✅ 避免 "No Overlay widget found" 错误

**效果**:
- ✅ 整个应用的所有文本都可以选择
- ✅ 包括标题、按钮文字、提示文本等
- ✅ 用户可以复制任何可见文本

### 2. 局部启用文本选择

对于特定区域，可以使用 `SelectableText` 或包裹 `SelectionArea`：

```dart
// 单行文本
SelectableText('这段文本可以选择')

// 富文本
SelectableText.rich(
  TextSpan(children: [
    TextSpan(text: '普通文本'),
    TextSpan(text: '加粗文本', style: TextStyle(fontWeight: FontWeight.bold)),
  ]),
)

// 包裹整个区域
SelectionArea(
  child: Column(
    children: [
      Text('文本1'),
      Text('文本2'),
    ],
  ),
)
```

## 应用中的文本选择

### ✅ 已启用的区域

1. **全局文本** - 所有页面的文本都可选择
2. **对校结果区域** - 使用 `SelectableText.rich` 显示差异，支持选择和复制
3. **所有 Text Widget** - 通过全局 `SelectionArea` 自动启用

### 特殊说明

#### TextField vs SelectableText

- **TextField**: 输入框，始终可选择和编辑
- **SelectableText**: 只读文本，可选择但不可编辑
- **Text**: 在 SelectionArea 内可选择

#### 对校结果的选择

对校结果使用 `SelectableText.rich` 实现：

```dart
// lib/features/collation/widgets/result_display_panel.dart
SelectableText.rich(
  TextSpan(children: spans),
  style: const TextStyle(fontSize: 16, height: 1.8),
)
```

用户可以：
- ✅ 选择完整的对校结果
- ✅ 复制文本（包括差异标记）
- ✅ 拖拽选择多行文本

## 测试验证

### 验证步骤

1. **启动应用**
   ```bash
   flutter run -d chrome
   ```

2. **测试文本选择**
   - 在主页尝试选择标题"古籍工具箱"
   - 选择导航栏的文字
   - 选择卡片中的描述文本

3. **测试对校结果选择**
   - 进入古籍对校页面
   - 输入两段文本并对比
   - 尝试选择和复制对比结果

### 预期结果

- ✅ 所有文本都可以用鼠标拖拽选中
- ✅ 选中后文本高亮显示（蓝色背景）
- ✅ 右键或 Ctrl+C 可以复制选中的文本
- ✅ 对校结果可以完整复制

## 性能影响

添加 `SelectionArea` 对性能的影响：

- **内存**: 几乎无影响
- **渲染**: 微小的额外开销（可忽略）
- **交互**: 无明显延迟
- **构建时间**: 无影响

## 最佳实践

### 何时使用全局 SelectionArea

✅ **推荐使用**:
- 内容型应用（如古籍工具箱）
- 文档编辑器
- 阅读应用
- 展示大量文本的应用

⚠️ **谨慎使用**:
- 游戏类应用
- 高度自定义的 UI
- 需要精确控制选择行为的应用

### 何时使用局部 SelectionArea

适用于：
- 只有特定区域需要选择
- 需要禁用某些区域的选择
- 需要不同的选择样式

## 常见问题

### Q1: 某些文本仍然无法选择？

**A**: 检查是否有以下情况：
- Widget 被 `IgnorePointer` 或 `AbsorbPointer` 包裹
- 自定义 `GestureDetector` 拦截了触摸事件
- 使用了 `CustomPaint` 绘制的文本

### Q2: 选择样式如何自定义？

**A**: 使用 `SelectionArea` 的 `selectionControls` 参数：

```dart
SelectionArea(
  selectionControls: MaterialTextSelectionControls(),
  child: child,
)
```

### Q3: 如何禁用特定区域的选择？

**A**: 使用 `SelectionContainer.disabled`：

```dart
SelectionContainer.disabled(
  child: Text('这段文本不可选择'),
)
```

## 相关资源

- [Flutter SelectionArea 文档](https://api.flutter.dev/flutter/material/SelectionArea-class.html)
- [Flutter SelectableText 文档](https://api.flutter.dev/flutter/material/SelectableText-class.html)
- [Text Selection in Flutter Web](https://docs.flutter.dev/platform-integration/web/faq#how-do-i-enable-text-selection)

## 修复历史

- **2025-01-05**: 添加全局 `SelectionArea` 以启用整个应用的文本选择功能
- 修复文件: `lib/app/app.dart`
- 受影响范围: 整个应用
