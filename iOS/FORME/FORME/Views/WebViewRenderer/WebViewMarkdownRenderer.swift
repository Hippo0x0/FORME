import UIKit
import WebKit

protocol WebViewMarkdownRendererDelegate: AnyObject {
    func webViewRenderer(_ renderer: WebViewMarkdownRenderer, didUpdateHeight height: CGFloat, forMessageId messageId: String)
    func webViewRenderer(_ renderer: WebViewMarkdownRenderer, didReceiveLinkClick url: URL, forMessageId messageId: String)
}

class WebViewMarkdownRenderer: NSObject {
    static let shared = WebViewMarkdownRenderer()

    private let cache = NSCache<NSString, NSNumber>()
    private let htmlTemplate: String
    private let userStyle: String
    private let aiStyle: String
    private var heightObservers: [String: (CGFloat) -> Void] = [:]
    private var activeWebViews: [String: WKWebView] = [:]

    weak var delegate: WebViewMarkdownRendererDelegate?

    override init() {
        // 用户消息样式（蓝色气泡）
        userStyle = """
            .markdown-body {
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
                font-size: 16px;
                line-height: 1.6;
                color: #FFFFFF;
                margin: 0;
                padding: 12px;
                background-color: #007AFF;
                border-radius: 12px;
                word-wrap: break-word;
                overflow-wrap: break-word;
            }
            .markdown-body a { color: #FFFFFF; text-decoration: underline; }
            .markdown-body code { background-color: rgba(255, 255, 255, 0.2); color: #FFFFFF; }
            .markdown-body pre { background-color: rgba(255, 255, 255, 0.1); }
        """

        // AI消息样式（灰色气泡）
        aiStyle = """
            .markdown-body {
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
                font-size: 16px;
                line-height: 1.6;
                color: #000000;
                margin: 0;
                padding: 12px;
                background-color: #F2F2F7;
                border-radius: 12px;
                word-wrap: break-word;
                overflow-wrap: break-word;
            }
            .markdown-body a { color: #007AFF; text-decoration: underline; }
            .markdown-body code { background-color: rgba(0, 0, 0, 0.1); color: #000000; }
            .markdown-body pre { background-color: rgba(0, 0, 0, 0.05); }
        """

        // HTML模板 - 专门为WebView渲染优化
        htmlTemplate = """
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="utf-8">
                <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
                <style id="dynamic-style"></style>
            </head>
            <body>
                <div id="content" class="markdown-body"></div>
                <script>
                    // 存储初始内容
                    let currentContent = '';
                    let heightObserver = null;
                    let lastHeight = 0;

                    // 完整的Markdown解析器
                    function parseMarkdown(markdown) {
                        // 转义HTML
                        let html = markdown
                            .replace(/&/g, '&amp;')
                            .replace(/</g, '&lt;')
                            .replace(/>/g, '&gt;')
                            .replace(/"/g, '&quot;')
                            .replace(/'/g, '&#039;');

                        // 标题
                        html = html.replace(/^### (.*$)/gm, '<h3>$1</h3>');
                        html = html.replace(/^## (.*$)/gm, '<h2>$1</h2>');
                        html = html.replace(/^# (.*$)/gm, '<h1>$1</h1>');

                        // 粗体和斜体
                        html = html.replace(/\\*\\*\\*(.*?)\\*\\*\\*/g, '<strong><em>$1</em></strong>');
                        html = html.replace(/\\*\\*(.*?)\\*\\*/g, '<strong>$1</strong>');
                        html = html.replace(/\\*(.*?)\\*/g, '<em>$1</em>');

                        // 代码块和内联代码
                        html = html.replace(/```([\\s\\S]*?)```/g, '<pre><code>$1</code></pre>');
                        html = html.replace(/`([^`]+)`/g, '<code>$1</code>');

                        // 引用
                        html = html.replace(/^> (.*$)/gm, '<blockquote>$1</blockquote>');

                        // 列表
                        html = html.replace(/^\\* (.*$)/gm, '<li>$1</li>');
                        html = html.replace(/^\\d+\\. (.*$)/gm, '<li>$1</li>');

                        // 链接
                        html = html.replace(/\\[([^\\]]+)\\]\\(([^\\)]+)\\)/g, '<a href="$2">$1</a>');

                        // 图片
                        html = html.replace(/!\\[([^\\]]*)\\]\\(([^\\)]+)\\)/g, '<img src="$2" alt="$1">');

                        // 换行
                        html = html.replace(/\\n/g, '<br>');

                        return html;
                    }

                    // 更新内容并计算高度
                    function updateContent(content) {
                        currentContent = content;
                        const contentElement = document.getElementById('content');
                        contentElement.innerHTML = parseMarkdown(content);

                        // 使用requestAnimationFrame确保DOM更新完成
                        requestAnimationFrame(() => {
                            notifyHeight();
                        });
                    }

                    // 通知高度变化
                    function notifyHeight() {
                        const height = document.body.scrollHeight;

                        // 只有当高度变化超过1像素时才通知，避免频繁回调
                        if (Math.abs(height - lastHeight) > 1) {
                            lastHeight = height;
                            if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.heightUpdate) {
                                window.webkit.messageHandlers.heightUpdate.postMessage(height.toString());
                            }
                        }
                    }

                    // 启动高度观察（用于流式输出）
                    function startHeightObservation() {
                        if (heightObserver) {
                            heightObserver.disconnect();
                        }

                        // 使用MutationObserver监听DOM变化
                        heightObserver = new MutationObserver((mutations) => {
                            let shouldUpdate = false;
                            for (const mutation of mutations) {
                                if (mutation.type === 'childList' || mutation.type === 'characterData') {
                                    shouldUpdate = true;
                                    break;
                                }
                            }

                            if (shouldUpdate) {
                                requestAnimationFrame(() => {
                                    notifyHeight();
                                });
                            }
                        });

                        // 观察整个body的变化
                        heightObserver.observe(document.body, {
                            childList: true,
                            subtree: true,
                            characterData: true
                        });
                    }

                    // 停止高度观察
                    function stopHeightObservation() {
                        if (heightObserver) {
                            heightObserver.disconnect();
                            heightObserver = null;
                        }
                    }

                    // 监听来自iOS的消息
                    window.addEventListener('message', function(event) {
                        const data = event.data;

                        if (data.type === 'updateContent') {
                            updateContent(data.content);
                            if (data.observeChanges) {
                                startHeightObservation();
                            }
                        } else if (data.type === 'cleanup') {
                            stopHeightObservation();
                        } else if (data.type === 'getHeight') {
                            notifyHeight();
                        }
                    });

                    // 如果存在初始内容，立即渲染
                    if (window.initialContent) {
                        updateContent(window.initialContent);
                        startHeightObservation();
                    }
                </script>
            </body>
            </html>
        """

        super.init()
    }

    func renderMarkdown(_ markdown: String, isUser: Bool, messageId: String, width: CGFloat, completion: @escaping (CGFloat) -> Void) {
        let cacheKey = "\(messageId)-\(width)" as NSString

        // 检查缓存
        if let cachedHeight = cache.object(forKey: cacheKey) {
            completion(cachedHeight.doubleValue)
            return
        }

        // 注册高度回调
        heightObservers[messageId] = { [weak self] height in
            guard let self = self else { return }
            self.cache.setObject(NSNumber(value: Double(height)), forKey: cacheKey)
            completion(height)
            self.heightObservers.removeValue(forKey: messageId)
        }

        // 创建WebView进行渲染
        let webView = createWebView(forMessageId: messageId, isUser: isUser, width: width)
        let html = generateHTML(markdown: markdown, isUser: isUser, observeChanges: true)
        webView.loadHTMLString(html, baseURL: nil)
    }

    func updateWebViewContent(_ markdown: String, forMessageId messageId: String) {
        guard let webView = activeWebViews[messageId] else { return }

        // 转义Markdown内容
        let escapedMarkdown = markdown
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "'", with: "\\'")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\r", with: "\\r")

        // 发送JavaScript消息更新内容
        let script = """
            window.postMessage({
                type: 'updateContent',
                content: '\(escapedMarkdown)',
                observeChanges: true
            }, '*');
        """

        webView.evaluateJavaScript(script) { _, error in
            if let error = error {
                print("更新WebView内容失败: \(error)")
            }
        }
    }

    func cleanupWebView(forMessageId messageId: String) {
        guard let webView = activeWebViews[messageId] else { return }

        // 发送清理消息
        let script = """
            window.postMessage({
                type: 'cleanup'
            }, '*');
        """

        webView.evaluateJavaScript(script) { _, _ in
            // 清理完成后移除WebView
            webView.removeFromSuperview()
            self.activeWebViews.removeValue(forKey: messageId)
        }
    }

    func getWebView(forMessageId messageId: String) -> WKWebView? {
        return activeWebViews[messageId]
    }

    private func createWebView(forMessageId messageId: String, isUser: Bool, width: CGFloat) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        userContentController.add(self, name: "heightUpdate")
        configuration.userContentController = userContentController

        let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: width, height: 1), configuration: configuration)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false
        webView.navigationDelegate = self

        // 存储messageId以便回调
        objc_setAssociatedObject(webView, &AssociatedKeys.messageId, messageId, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(webView, &AssociatedKeys.isUser, isUser, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        // 添加到活跃WebView列表
        activeWebViews[messageId] = webView

        return webView
    }

    private func generateHTML(markdown: String, isUser: Bool, observeChanges: Bool = true) -> String {
        let style = isUser ? userStyle : aiStyle

        // 转义Markdown内容以便在JavaScript中使用
        let escapedMarkdown = markdown
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "'", with: "\\'")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\r", with: "\\r")

        // 构建初始JavaScript代码
        let initScript = """
            <script>
                window.initialContent = '\(escapedMarkdown)';
                window.shouldObserveChanges = \(observeChanges ? "true" : "false");
            </script>
        """

        return htmlTemplate
            .replacingOccurrences(of: "<style id=\"dynamic-style\"></style>", with: "<style>\(style)</style>")
            .replacingOccurrences(of: "</head>", with: "\(initScript)</head>")
    }
}

extension WebViewMarkdownRenderer: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "heightUpdate",
           let heightString = message.body as? String,
           let webView = message.webView,
           let messageId = objc_getAssociatedObject(webView, &AssociatedKeys.messageId) as? String {

            // 安全转换高度字符串
            guard let heightDouble = Double(heightString) else {
                print("无法转换高度字符串: \(heightString)")
                return
            }

            let height = CGFloat(heightDouble)

            if let callback = heightObservers[messageId] {
                callback(height)
                heightObservers.removeValue(forKey: messageId)
            }

            delegate?.webViewRenderer(self, didUpdateHeight: height, forMessageId: messageId)
        }
    }
}

extension WebViewMarkdownRenderer: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated,
           let url = navigationAction.request.url,
           let messageId = objc_getAssociatedObject(webView, &AssociatedKeys.messageId) as? String {
            delegate?.webViewRenderer(self, didReceiveLinkClick: url, forMessageId: messageId)
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }
}

private struct AssociatedKeys {
    static var messageId = "messageId"
    static var isUser = "isUser"
}