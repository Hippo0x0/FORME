# WebView Markdown渲染器

这个文件夹包含了用于在iOS应用中渲染Markdown的WebView渲染器组件。它提供了高度监听、气泡大小自动更新和混合渲染功能。

## 组件概述

### 1. WebViewMarkdownRenderer (`WebViewMarkdownRenderer.swift`)
核心渲染器，负责：
- 将Markdown转换为HTML并在WebView中渲染
- 监听WebView高度变化
- 缓存渲染结果以提高性能
- 处理链接点击事件

### 2. WebViewContentView (`WebViewContentView.swift`)
WebView内容视图，负责：
- 管理WebView实例
- 监听高度变化并通知父视图
- 处理消息内容更新
- 清理资源

### 3. WebViewMessageCell (`WebViewMessageCell.swift`)
集合视图单元格，负责：
- 显示消息气泡
- 集成WebViewContentView
- 自动调整气泡大小
- 显示时间戳

### 4. HybridMessageContentView (`HybridMessageContentView.swift`)
混合渲染器，负责：
- 根据内容复杂度自动选择渲染方式（WebView或TextView）
- 提供无缝的渲染方式切换
- 保持与现有代码的兼容性

### 5. WebViewDemoViewController (`WebViewDemoViewController.swift`)
演示视图控制器，展示：
- WebView渲染器的基本用法
- 流式更新效果
- 多种Markdown格式渲染

### 6. Message (`Message.swift`)
消息数据模型。

## 功能特性

### 高度监听
- 实时监听WebView内容高度变化
- 高度变化超过1像素时才触发更新，避免频繁回调
- 支持流式内容的高度动态更新

### 气泡大小自动更新
- 当WebView高度变化时，自动调整气泡大小
- 通知集合视图更新布局
- 平滑的动画效果

### 混合渲染策略
根据内容复杂度自动选择渲染方式：

**使用WebView渲染的条件：**
- 包含代码块（```）
- 包含表格（|）
- 包含数学公式（$$）
- 包含图片链接（![...])
- 包含HTML表格（<table>）
- 包含内联代码（`...`）
- 包含标题（#）
- 包含引用（>）
- 包含列表（-、*、+）
- 文本长度超过500字符

**使用TextView渲染的条件：**
- 简单文本
- 基本的粗体、斜体格式
- 短文本内容

### 性能优化
- WebView实例池管理
- 渲染结果缓存
- 避免频繁的DOM操作
- 内存泄漏防护

## 使用方法

### 基本集成

1. 在需要的地方导入WebView渲染器：

```swift
import WebKit
```

2. 使用HybridMessageContentView替换现有的MessageContentView：

```swift
// 创建消息
let message = Message(content: "你的Markdown内容", isUser: false)

// 创建内容视图
let contentView = HybridMessageContentView(message: message)

// 添加到视图层级
addSubview(contentView)
```

### 在集合视图中使用

1. 注册单元格：

```swift
collectionView.register(WebViewMessageCell.self,
                       forCellWithReuseIdentifier: WebViewMessageCell.reuseIdentifier)
```

2. 配置单元格：

```swift
func collectionView(_ collectionView: UICollectionView,
                   cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WebViewMessageCell.reuseIdentifier,
                                                 for: indexPath) as! WebViewMessageCell
    let message = messages[indexPath.item]
    cell.configure(with: message, maxWidth: maxCellWidth)
    return cell
}
```

3. 计算单元格大小：

```swift
func collectionView(_ collectionView: UICollectionView,
                   layout collectionViewLayout: UICollectionViewLayout,
                   sizeForItemAt indexPath: IndexPath) -> CGSize {
    let message = messages[indexPath.item]
    return WebViewMessageCell.cellSize(for: message, maxWidth: maxCellWidth)
}
```

### 流式更新

```swift
// 更新消息内容
cell.updateMessageContent(newContent)

// 或者通过消息模型更新
message.content = newContent
if let cell = collectionView.cellForItem(at: indexPath) as? WebViewMessageCell {
    cell.updateMessageContent(newContent)
}
```

## 自定义配置

### 修改样式

在`WebViewMarkdownRenderer.swift`中修改样式：

```swift
// 用户消息样式
private let userStyle = """
    .markdown-body {
        font-family: -apple-system;
        font-size: 16px;
        color: #FFFFFF;
        background-color: #007AFF;
    }
"""

// AI消息样式
private let aiStyle = """
    .markdown-body {
        font-family: -apple-system;
        font-size: 16px;
        color: #000000;
        background-color: #F2F2F7;
    }
"""
```

### 调整渲染策略

在`HybridMessageContentView.swift`中修改`shouldUseWebView`方法：

```swift
private func shouldUseWebView(for markdown: String) -> Bool {
    // 添加或修改条件
    let complexPatterns = [
        "```",        // 代码块
        // ... 其他条件
    ]

    // 或者调整长度阈值
    return markdown.count > 300 // 改为300字符
}
```

## 演示

运行`WebViewDemoViewController`查看效果：

```swift
let demoVC = WebViewDemoViewController()
navigationController?.pushViewController(demoVC, animated: true)
```

## 注意事项

1. **内存管理**：WebView会消耗较多内存，确保及时清理
2. **性能**：复杂的Markdown内容可能渲染较慢，考虑使用缓存
3. **兼容性**：某些HTML/CSS特性可能在WebView中表现不一致
4. **安全性**：确保用户生成的内容经过适当的清理

## 故障排除

### WebView不显示内容
- 检查WebView的frame是否正确设置
- 确认HTML内容正确生成
- 检查JavaScript通信是否正常

### 高度更新不触发
- 确认高度监听已正确设置
- 检查JavaScript中的高度计算逻辑
- 确认委托方法被正确调用

### 内存泄漏
- 确保在deinit中清理WebView
- 使用WebView实例池管理
- 避免循环引用

## 扩展开发

### 添加新功能
1. 在`WebViewMarkdownRenderer`中添加新的JavaScript功能
2. 在HTML模板中添加对应的CSS样式
3. 通过JavaScript桥接与原生代码通信

### 优化性能
1. 实现更智能的缓存策略
2. 优化DOM操作频率
3. 减少不必要的重绘

## 许可证

本项目遵循MIT许可证。