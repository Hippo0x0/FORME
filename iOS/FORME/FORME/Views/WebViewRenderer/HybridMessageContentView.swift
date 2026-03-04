import UIKit
import WebKit
import SnapKit

class HybridMessageContentView: UIView {
    private var message: Message
    private var contentTextView: UITextView?
    private var webViewContentView: WebViewContentView?
    private var currentWidth: CGFloat = 0
    private var cachedHeight: CGFloat = 0
    private var isUsingWebView = false

    private let renderer = WebViewMarkdownRenderer.shared

    init(message: Message) {
        self.message = message
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .clear

        // 根据内容复杂度选择渲染方式
        if shouldUseWebView(for: message.content) {
            setupWebView()
            isUsingWebView = true
        } else {
            setupTextView()
            isUsingWebView = false
        }
    }

    private func setupWebView() {
        // 创建WebView内容视图
        let webViewContentView = WebViewContentView(message: message)
        self.webViewContentView = webViewContentView

        addSubview(webViewContentView)
        webViewContentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // 监听高度变化
        webViewContentView.onHeightUpdate = { [weak self] height in
            guard let self = self else { return }
            self.cachedHeight = height
            self.invalidateIntrinsicContentSize()
            self.superview?.setNeedsLayout()
        }
    }

    private func setupTextView() {
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.contentInset = .zero
        textView.isSelectable = true
        textView.dataDetectorTypes = .link
        textView.textColor = message.isUser ? .white : .label
        self.contentTextView = textView

        addSubview(textView)
        textView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // 渲染简单文本
        renderMarkdownWithTextView()
    }

    func updateMessageContent(_ newContent: String) {
        message.content = newContent

        // 检查是否需要切换渲染方式
        let shouldUseWebView = shouldUseWebView(for: newContent)

        if shouldUseWebView != isUsingWebView {
            // 切换渲染方式
            switchRenderMode(shouldUseWebView: shouldUseWebView)
        } else {
            // 更新当前渲染方式
            if isUsingWebView {
                updateWebViewContent()
            } else {
                updateTextViewContent()
            }
        }
    }

    private func switchRenderMode(shouldUseWebView: Bool) {
        // 清理旧视图
        webViewContentView?.removeFromSuperview()
        contentTextView?.removeFromSuperview()

        webViewContentView = nil
        contentTextView = nil

        // 设置新视图
        if shouldUseWebView {
            setupWebView()
        } else {
            setupTextView()
        }

        isUsingWebView = shouldUseWebView
        cachedHeight = 0
    }

    private func renderMarkdownWithTextView() {
        guard let textView = contentTextView else { return }

        // 使用简单的Markdown解析
        let attributedText = parseSimpleMarkdown(message.content, isUser: message.isUser)
        textView.attributedText = attributedText
    }

    private func updateWebViewContent() {
        webViewContentView?.updateMessageContent(message.content)
        cachedHeight = 0
    }

    private func updateTextViewContent() {
        guard let textView = contentTextView else { return }

        let attributedText = parseSimpleMarkdown(message.content, isUser: message.isUser)
        textView.attributedText = attributedText
    }

    private func shouldUseWebView(for markdown: String) -> Bool {
        // 检查是否包含复杂Markdown语法
        let complexPatterns = [
            "```",        // 代码块
            "|",          // 表格
            "$$",         // 数学公式
            "\\[!\\[",    // 图片链接
            "<table",     // HTML表格
            "`[^`\n]+`",  // 内联代码
            "^#+ ",       // 标题
            "^> ",        // 引用
            "^[-*+] ",    // 列表
        ]

        for pattern in complexPatterns {
            if markdown.range(of: pattern, options: .regularExpression) != nil {
                return true
            }
        }

        // 检查长度 - 长文本也使用WebView以获得更好的渲染
        return markdown.count > 500
    }

    private func parseSimpleMarkdown(_ text: String, isUser: Bool) -> NSAttributedString {
        let baseColor = isUser ? UIColor.white : UIColor.label
        let baseFont = UIFont.systemFont(ofSize: 16)

        let attributedString = NSMutableAttributedString(string: text)

        // 简单的Markdown解析
        let patterns: [(String, [NSAttributedString.Key: Any])] = [
            ("\\*\\*([^*]+)\\*\\*", [.font: UIFont.boldSystemFont(ofSize: 16)]),
            ("\\*([^*]+)\\*", [.font: UIFont.italicSystemFont(ofSize: 16)]),
            ("`([^`]+)`", [.font: UIFont.monospacedSystemFont(ofSize: 14, weight: .regular),
                          .backgroundColor: UIColor.secondarySystemBackground])
        ]

        for (pattern, attributes) in patterns {
            do {
                let regex = try NSRegularExpression(pattern: pattern)
                let matches = regex.matches(in: text, range: NSRange(location: 0, length: text.utf16.count))

                for match in matches.reversed() {
                    attributedString.addAttributes(attributes, range: match.range)
                }
            } catch {
                print("正则表达式错误: \(error)")
            }
        }

        // 应用基础样式
        let fullRange = NSRange(location: 0, length: attributedString.length)
        attributedString.addAttribute(.font, value: baseFont, range: fullRange)
        attributedString.addAttribute(.foregroundColor, value: baseColor, range: fullRange)

        return attributedString
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // 如果宽度变化，重新计算高度
        if currentWidth != bounds.width {
            currentWidth = bounds.width
            cachedHeight = 0
        }
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        if currentWidth != size.width {
            currentWidth = size.width
            cachedHeight = 0
        }

        if cachedHeight > 0 {
            return CGSize(width: size.width, height: cachedHeight)
        }

        // 估算高度
        if isUsingWebView {
            // WebView内容高度估算（等待实际高度计算）
            let lineHeight: CGFloat = 24
            let lines = ceil(Double(message.content.count) / 50.0)
            let estimatedHeight = CGFloat(lines) * lineHeight + 24 // 加上内边距
            cachedHeight = estimatedHeight
            return CGSize(width: size.width, height: estimatedHeight)
        } else {
            // TextView内容高度估算
            guard let textView = contentTextView else {
                return CGSize(width: size.width, height: 0)
            }

            let estimatedSize = textView.sizeThatFits(CGSize(width: size.width, height: .greatestFiniteMagnitude))
            cachedHeight = estimatedSize.height
            return CGSize(width: size.width, height: estimatedSize.height)
        }
    }

    override var intrinsicContentSize: CGSize {
        return sizeThatFits(CGSize(width: bounds.width, height: .greatestFiniteMagnitude))
    }

    deinit {
        // 清理WebView
        if isUsingWebView {
            webViewContentView?.removeFromSuperview()
            webViewContentView = nil
        }
    }
}