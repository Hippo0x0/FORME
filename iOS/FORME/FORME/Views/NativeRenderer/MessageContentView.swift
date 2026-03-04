//
//  MessageContentView.swift
//  FORME
//
//  Created by zhuopeijin on 2026/2/15.
//

import UIKit

class MessageContentView: UIView {
    private var message: Message
    private let contentTextView = UITextView()
    private let nativeRenderer: NativeMarkdownRenderer = NativeMarkdownRenderer.shared

    init(message: Message) {
        self.message = message
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentTextView.isEditable = false
        contentTextView.isScrollEnabled = false
        contentTextView.backgroundColor = .clear
        contentTextView.textContainerInset = .zero
        contentTextView.textContainer.lineFragmentPadding = 0
        contentTextView.contentInset = .zero
        contentTextView.isSelectable = true
        contentTextView.dataDetectorTypes = .link
        contentTextView.textColor = .label

        updateContentLabel()

        addSubview(contentTextView)
        contentTextView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func updateMessageContent(_ newContent: String) {
        message.content = newContent
        updateContentLabel()
    }

    private func updateContentLabel() {
        let attributedText = nativeRenderer.parseMarkdown(message.content, isUser: message.isUser)
        contentTextView.attributedText = attributedText
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return contentTextView.sizeThatFits(size)
    }
}
