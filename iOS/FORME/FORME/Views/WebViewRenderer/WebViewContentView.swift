import UIKit
import WebKit

class WebViewContentView: UIView {
    private let message: Message
    private var webView: WKWebView?
    private var currentWidth: CGFloat = 0
    private var cachedHeight: CGFloat = 0
    private var isRendering = false

    private let renderer = WebViewMarkdownRenderer.shared

    var onHeightUpdate: ((CGFloat) -> Void)?

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
        setupWebView()
    }

    private func setupWebView() {
        // 创建WebView
        let webView = renderer.getWebView(forMessageId: message.id) ?? createNewWebView()
        self.webView = webView

        addSubview(webView)
        webView.snp.makeConstraints { make in
            make.top.left.width.equalToSuperview()
            make.height.equalToSuperview()
        }

        // 设置渲染器代理
        renderer.delegate = self

        // 开始渲染
        renderMarkdown()
    }

    private func createNewWebView() -> WKWebView {
        let webView = WKWebView()
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false
        webView.isUserInteractionEnabled = true
        return webView
    }

    private func renderMarkdown() {
        guard let webView = webView else { return }

        // 确保不在渲染中
        if isRendering { return }
        isRendering = true

        // 使用WebViewMarkdownRenderer渲染
        renderer.renderMarkdown(
            message.content,
            isUser: message.isUser,
            messageId: message.id,
            width: bounds.width
        ) { [weak self] height in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.isRendering = false
                self.cachedHeight = height

                // 更新WebView约束
                
                webView.snp.remakeConstraints({ make in
                    make.top.left.width.equalToSuperview()
                    make.height.equalTo(height)
                })

                // 通知高度更新
                self.onHeightUpdate?(height)

                // 更新自身大小
                self.invalidateIntrinsicContentSize()
                self.superview?.setNeedsLayout()
            }
        }
    }

    func updateMessageContent(_ newContent: String) {
        message.content = newContent

        // 清除缓存高度
        cachedHeight = 0

        // 更新WebView内容
        renderer.updateWebViewContent(newContent, forMessageId: message.id)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // 如果宽度变化，重新渲染
        if currentWidth != bounds.width {
            currentWidth = bounds.width
            cachedHeight = 0
            renderMarkdown()
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
        let lineHeight: CGFloat = 24
        let lines = ceil(Double(message.content.count) / 50.0)
        let estimatedHeight = CGFloat(lines) * lineHeight + 24 // 加上内边距
        return CGSize(width: size.width, height: estimatedHeight)
    }

    override var intrinsicContentSize: CGSize {
        return sizeThatFits(CGSize(width: bounds.width, height: .greatestFiniteMagnitude))
    }

    deinit {
        // 清理WebView
        renderer.cleanupWebView(forMessageId: message.id)
    }
}

extension WebViewContentView: WebViewMarkdownRendererDelegate {
    func webViewRenderer(_ renderer: WebViewMarkdownRenderer, didUpdateHeight height: CGFloat, forMessageId messageId: String) {
        guard messageId == message.id else { return }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            self.cachedHeight = height

            // 更新WebView约束
            if let webView = self.webView {
                webView.snp.remakeConstraints { make in
                    make.top.left.width.equalToSuperview()
                    make.height.equalTo(height)
                }
            }

            // 通知高度更新
            self.onHeightUpdate?(height)

            // 更新自身大小
            self.invalidateIntrinsicContentSize()
            self.superview?.setNeedsLayout()
        }
    }

    func webViewRenderer(_ renderer: WebViewMarkdownRenderer, didReceiveLinkClick url: URL, forMessageId messageId: String) {
        guard messageId == message.id else { return }

        // 处理链接点击
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
