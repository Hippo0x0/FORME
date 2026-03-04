import UIKit
import SnapKit

class WebViewMessageCell: UICollectionViewCell {
    static let reuseIdentifier = "WebViewMessageCell"

    private var message: Message?
    private var contentViewWrapper: UIView!
    private var webViewContentView: WebViewContentView?

    private let bubbleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()

    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        label.textAlignment = .right
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.backgroundColor = .clear

        // 气泡视图
        contentView.addSubview(bubbleView)

        // 内容包装视图
        contentViewWrapper = UIView()
        contentViewWrapper.backgroundColor = .clear
        bubbleView.addSubview(contentViewWrapper)

        // 时间标签
        contentView.addSubview(timeLabel)

        setupConstraints()
    }

    private func setupConstraints() {
        bubbleView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
        }

        contentViewWrapper.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        timeLabel.snp.makeConstraints { make in
            make.trailing.equalTo(bubbleView)
            make.bottom.equalTo(bubbleView.snp.bottom).offset(4)
            make.height.equalTo(16)
        }
    }

    func configure(with message: Message, maxWidth: CGFloat) {
        self.message = message

        // 设置气泡颜色
        if message.isUser {
            bubbleView.backgroundColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0) // 蓝色
            timeLabel.textColor = .white.withAlphaComponent(0.8)
        } else {
            bubbleView.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 247/255, alpha: 1.0) // 浅灰色
            timeLabel.textColor = .secondaryLabel
        }

        // 设置气泡位置
        if message.isUser {
            bubbleView.snp.remakeConstraints { make in
                make.top.equalToSuperview().offset(8)
                make.bottom.equalToSuperview().offset(-8)
                make.trailing.equalToSuperview().offset(-16)
                make.leading.greaterThanOrEqualToSuperview().offset(60)
                make.width.lessThanOrEqualTo(maxWidth - 76) // 减去左右边距
            }
        } else {
            bubbleView.snp.remakeConstraints { make in
                make.top.equalToSuperview().offset(8)
                make.bottom.equalToSuperview().offset(-8)
                make.leading.equalToSuperview().offset(16)
                make.trailing.lessThanOrEqualToSuperview().offset(-60)
                make.width.lessThanOrEqualTo(maxWidth - 76) // 减去左右边距
            }
        }

        // 设置时间
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        timeLabel.text = formatter.string(from: message.timestamp)

        // 创建或更新WebView内容视图
        setupWebViewContentView()
    }

    private func setupWebViewContentView() {
        guard let message = message else { return }

        // 清理旧视图
        webViewContentView?.removeFromSuperview()
        webViewContentView = nil

        // 创建新的WebView内容视图
        let webViewContentView = WebViewContentView(message: message)
        self.webViewContentView = webViewContentView

        contentViewWrapper.addSubview(webViewContentView)
        webViewContentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // 监听高度变化
        webViewContentView.onHeightUpdate = { [weak self] height in
            guard let self = self else { return }

            DispatchQueue.main.async {
                // 更新气泡高度
                self.bubbleView.snp.updateConstraints { make in
                    make.height.equalTo(height)
                }

                // 通知集合视图更新布局
                self.contentView.setNeedsLayout()
                self.contentView.layoutIfNeeded()

                // 如果需要，可以通知父视图更新
                if let collectionView = self.superview as? UICollectionView {
                    UIView.performWithoutAnimation {
                        collectionView.collectionViewLayout.invalidateLayout()
                    }
                }
            }
        }
    }

    func updateMessageContent(_ newContent: String) {
        guard let message = message else { return }

        message.content = newContent
        webViewContentView?.updateMessageContent(newContent)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        // 清理WebView内容视图
        webViewContentView?.removeFromSuperview()
        webViewContentView = nil
        message = nil
    }

    static func cellSize(for message: Message, maxWidth: CGFloat) -> CGSize {
        // 估算高度
        let lineHeight: CGFloat = 24
        let lines = ceil(Double(message.content.count) / 50.0)
        let contentHeight = CGFloat(lines) * lineHeight + 24 // 加上内边距

        // 气泡高度 = 内容高度 + 上下内边距
        let bubbleHeight = contentHeight

        // 总高度 = 气泡高度 + 上下边距 + 时间标签高度
        let totalHeight = bubbleHeight + 8 + 8 + 4 + 16 // 上下边距各8 + 时间标签底部偏移4 + 时间标签高度16

        // 宽度由布局决定
        return CGSize(width: maxWidth, height: totalHeight)
    }
}