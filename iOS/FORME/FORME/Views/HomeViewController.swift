import UIKit
import SnapKit
import Markdown
import Alamofire

struct ResearchItem {
    let title: String
    let color: UIColor
}

class Message {
    let id: String
    var content: String
    let isUser: Bool
    let timestamp: Date

    init(id: String, content: String, isUser: Bool, timestamp: Date) {
        self.id = id
        self.content = content
        self.isUser = isUser
        self.timestamp = timestamp
    }
}

class HomeViewController: UIViewController {
  
    deinit {
      removeKeyboardObservers()
    }

    private let existingResearchLabel: UILabel = {
        let label = UILabel()
        label.text = "已有研究"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        return label
    }()

    private let researchCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(ResearchCell.self, forCellWithReuseIdentifier: "ResearchCell")
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()

    private let conversationContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()

    private let conversationTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "研究对话"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        return label
    }()

    private let conversationScrollView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 0

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsVerticalScrollIndicator = true
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .clear
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        return collectionView
    }()

    private let inputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.separator.cgColor
        return view
    }()

    private let inputTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.textColor = .label
        textView.backgroundColor = .clear
        textView.isScrollEnabled = false
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        textView.placeholder = "输入您的研究问题..."
        return textView
    }()

    private let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        button.tintColor = UIColor(red: 0.07, green: 0.21, blue: 0.36, alpha: 1.0)
        return button
    }()

    private let emptyConversationLabel: UILabel = {
        let label = UILabel()
        label.text = "暂无对话\n开始您的研究对话吧"
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    private var researchItems: [ResearchItem] = [
        ResearchItem(title: "心理学", color: UIColor(red: 0.91, green: 0.29, blue: 0.24, alpha: 1.0)),
        ResearchItem(title: "投资", color: UIColor(red: 0.20, green: 0.60, blue: 0.86, alpha: 1.0)),
        ResearchItem(title: "技能", color: UIColor(red: 0.15, green: 0.68, blue: 0.38, alpha: 1.0)),
        ResearchItem(title: "财务", color: UIColor(red: 0.95, green: 0.77, blue: 0.06, alpha: 1.0)),
        ResearchItem(title: "人生", color: UIColor(red: 0.61, green: 0.35, blue: 0.71, alpha: 1.0)),
        ResearchItem(title: "健康", color: UIColor(red: 0.98, green: 0.50, blue: 0.45, alpha: 1.0))
    ]

    private var messages: [Message] = [
        Message(
            id: "1",
            content: "# 阿德勒心理学研究\n\n**核心观点**: 人的行为受目标驱动，而非过去决定。\n\n## 关键概念\n- **自卑与超越**: 自卑感是进步的动力\n- **社会兴趣**: 健康的人际关系是幸福的关键\n- **生活风格**: 个人独特的行为模式",
            isUser: false,
            timestamp: Date().addingTimeInterval(-3600)
        ),
        Message(
            id: "2",
            content: "我想了解如何应用阿德勒心理学改善人际关系？",
            isUser: true,
            timestamp: Date().addingTimeInterval(-1800)
        ),
        Message(
            id: "3",
            content: "## 改善人际关系的阿德勒方法\n\n1. **培养社会兴趣**: 关注他人需求，建立共同体感觉\n2. **平等对话**: 避免优越感或自卑感，保持平等姿态\n3. **课题分离**: 分清自己的课题和他人的课题\n\n> 记住：所有烦恼都来自人际关系，但所有幸福也来自人际关系。",
            isUser: false,
            timestamp: Date().addingTimeInterval(-900)
        )
    ]

  override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        setupKeyboardObservers()
        loadConversation()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationItem.title = "首页"

        view.addSubview(existingResearchLabel)
        view.addSubview(researchCollectionView)
        view.addSubview(conversationContainerView)

        conversationContainerView.addSubview(conversationTitleLabel)
        conversationContainerView.addSubview(conversationScrollView)
        conversationContainerView.addSubview(emptyConversationLabel)

        view.addSubview(inputContainerView)
        inputContainerView.addSubview(inputTextView)
        inputContainerView.addSubview(sendButton)

        researchCollectionView.delegate = self
        researchCollectionView.dataSource = self

        conversationScrollView.delegate = self
        conversationScrollView.dataSource = self
        conversationScrollView.register(MessageCollectionViewCell.self, forCellWithReuseIdentifier: "MessageCell")

        inputTextView.delegate = self
    }

    private func setupConstraints() {
        existingResearchLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        researchCollectionView.snp.makeConstraints { make in
            make.top.equalTo(existingResearchLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(100)
        }

        conversationContainerView.snp.makeConstraints { make in
            make.top.equalTo(researchCollectionView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(inputContainerView.snp.top)
        }

        conversationTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        conversationScrollView.snp.makeConstraints { make in
            make.top.equalTo(conversationTitleLabel.snp.bottom).offset(12)
            make.leading.trailing.bottom.equalToSuperview()
        }


        emptyConversationLabel.snp.makeConstraints { make in
            make.center.equalTo(conversationScrollView)
            make.leading.trailing.equalToSuperview().inset(40)
        }

        inputContainerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.height.greaterThanOrEqualTo(50)
        }

        inputTextView.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
            make.trailing.equalTo(sendButton.snp.leading).offset(-8)
            make.height.greaterThanOrEqualTo(50)
        }

        sendButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-12)
            make.width.height.equalTo(32)
        }
    }

    private func setupActions() {
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
    }

    private func loadConversation() {
        emptyConversationLabel.isHidden = !messages.isEmpty
        conversationScrollView.reloadData()

        DispatchQueue.main.async {
            self.scrollToBottom()
        }
    }

    private func createMessageView(message: Message) -> UIView {
        let containerView = UIView()

        let bubbleView = UIView()
        bubbleView.layer.cornerRadius = 12
        bubbleView.layer.masksToBounds = true

        if message.isUser {
            bubbleView.backgroundColor = UIColor(red: 0.07, green: 0.21, blue: 0.36, alpha: 1.0)
        } else {
            bubbleView.backgroundColor = .secondarySystemBackground
        }

        let contentView = MessageContentView(message: message)

        containerView.addSubview(bubbleView)
        bubbleView.addSubview(contentView)

        if message.isUser {
            bubbleView.snp.makeConstraints { make in
                make.trailing.equalToSuperview().offset(-8)
                make.top.bottom.equalToSuperview()
                make.width.lessThanOrEqualTo(320)
            }

            contentView.snp.makeConstraints { make in
                make.edges.equalToSuperview().inset(12)
            }
        } else {
            bubbleView.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(8)
                make.top.bottom.equalToSuperview()
                make.width.lessThanOrEqualTo(360)
            }

            contentView.snp.makeConstraints { make in
                make.edges.equalToSuperview().inset(12)
            }
        }

        return containerView
    }

    private func scrollToBottom() {
        guard !messages.isEmpty else { return }
        let lastIndexPath = IndexPath(item: messages.count - 1, section: 0)
        conversationScrollView.scrollToItem(at: lastIndexPath, at: .bottom, animated: true)
    }

    @objc private func sendButtonTapped() {
        guard let text = inputTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty else { return }

        // 添加用户消息
        let userMessage = Message(
            id: UUID().uuidString,
            content: text,
            isUser: true,
            timestamp: Date()
        )
        messages.append(userMessage)
        inputTextView.text = ""

        // 添加AI消息占位符（显示正在输入）
        let aiMessageId = UUID().uuidString
        let aiMessage = Message(
            id: aiMessageId,
            content: "正在思考...",
            isUser: false,
            timestamp: Date()
        )
        messages.append(aiMessage)
        loadConversation()

        // 检查DeepSeek服务是否配置
        guard DeepSeekService.shared.isConfigured else {
            print("DeepSeek未配置，使用本地分析")
            fallbackToLocalAnalysis(question: text, aiMessageId: aiMessageId)
            return
        }

        // 准备消息历史（排除当前的AI占位符消息）
        // 获取用户消息和之前的AI消息（最多最近10条）
        let contextMessages = messages.filter { $0.id != aiMessageId }.suffix(10)
        let chatMessages: [ChatMessage] = contextMessages.map { message in
            let role: ChatMessage.Role = message.isUser ? .user : .assistant
            return ChatMessage(role: role, content: message.content)
        }

        // 如果没有消息历史，至少包含用户消息
        let finalMessages = chatMessages.isEmpty ?
            [ChatMessage(role: .user, content: text)] : chatMessages

        // 添加系统消息作为第一条消息（如果不存在）
        var allMessages = finalMessages
        if !allMessages.contains(where: { $0.role == .system }) {
            let systemMessage = ChatMessage(
                role: .system,
                content: "你是一个专业的研究助手，擅长回答各种研究问题并提供有价值的见解。请以友好、专业的方式回应用户的问题，使用Markdown格式组织你的回答。"
            )
            allMessages.insert(systemMessage, at: 0)
        }

        // 使用流式API获取回复
        DeepSeekService.shared.chatCompletionStream(
            messages: allMessages,
            maxTokens: 2000,
            temperature: 0.7,
            onChunk: { [weak self] accumulatedContent in
                guard let self = self else { return }

                // 更新AI消息内容
                DispatchQueue.main.async {
                    if let index = self.messages.firstIndex(where: { $0.id == aiMessageId }) {
                        self.messages[index].content = accumulatedContent
                        self.loadConversation()
                    }
                }
            },
            onCompletion: { [weak self] result in
                guard let self = self else { return }

                DispatchQueue.main.async {
                    switch result {
                    case .success(let finalContent):
                        // 更新最终内容
                        if let index = self.messages.firstIndex(where: { $0.id == aiMessageId }) {
                            self.messages[index].content = finalContent
                            self.loadConversation()
                        }

                    case .failure(let error):
                        print("DeepSeek流式API失败: \(error)")
                        // 回退到本地分析
                        self.fallbackToLocalAnalysis(question: text, aiMessageId: aiMessageId)
                    }
                }
            }
        )
    }

    private func fallbackToLocalAnalysis(question: String, aiMessageId: String) {
        Task {
            let fallbackResponse = await self.generateFallbackResponse(to: question)

            await MainActor.run {
                if let index = self.messages.firstIndex(where: { $0.id == aiMessageId }) {
                    self.messages[index].content = fallbackResponse
                    self.loadConversation()
                }
            }
        }
    }

    private func generateAIResponse(to question: String) async throws -> String {
        let analysisManager = AnalysisManager.shared

        // 创建自定义分析类型用于对话
        let conversationType = AnalysisType.custom(
            systemPrompt: "你是一个专业的研究助手，擅长回答各种研究问题并提供有价值的见解。请以友好、专业的方式回应用户的问题，使用Markdown格式组织你的回答。",
            userPrompt: { text in
                return "请回答以下研究问题：\n\n\(text)\n\n请提供详细、有用的回答，可以包含示例、建议和进一步的研究方向。"
            },
            temperature: 0.7
        )

        let result = await analysisManager.analyze(
            text: question,
            analysisType: conversationType,
            preferDeepSeek: true
        )

        return result.content
    }

    private func generateFallbackResponse(to question: String) async -> String {
        // 使用本地分析服务作为回退
        let localService = LocalAnalysisService.shared
        let conversationType = AnalysisType.custom(
            systemPrompt: "你是一个研究助手，请回答用户的问题。",
            userPrompt: { text in
                return "请回答：\(text)"
            },
            temperature: 0.7
        )

        let result = await localService.analyzeText(
            text: question,
            analysisType: conversationType
        )

        return result.content
    }

    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
              let animationCurveRaw = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else {
            return
        }

        let animationCurve = UIView.AnimationOptions(rawValue: animationCurveRaw << 16)
        let keyboardHeight = keyboardFrame.height

        UIView.animate(withDuration: animationDuration, delay: 0, options: animationCurve, animations: {
            self.inputContainerView.snp.remakeConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.bottom.equalToSuperview().offset(-keyboardHeight)
                make.height.greaterThanOrEqualTo(50)
            }

            self.conversationContainerView.snp.remakeConstraints { make in
                make.top.equalTo(self.researchCollectionView.snp.bottom).offset(20)
                make.leading.trailing.equalToSuperview()
                make.bottom.equalTo(self.inputContainerView.snp.top)
            }

            self.view.layoutIfNeeded()
            self.scrollToBottom()
        })
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
              let animationCurveRaw = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else {
            return
        }

        let animationCurve = UIView.AnimationOptions(rawValue: animationCurveRaw << 16)

        UIView.animate(withDuration: animationDuration, delay: 0, options: animationCurve, animations: {
            self.inputContainerView.snp.remakeConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.bottom.equalTo(self.view.safeAreaLayoutGuide)
                make.height.greaterThanOrEqualTo(50)
            }

            self.conversationContainerView.snp.remakeConstraints { make in
                make.top.equalTo(self.researchCollectionView.snp.bottom).offset(20)
                make.leading.trailing.equalToSuperview()
                make.bottom.equalTo(self.inputContainerView.snp.top)
            }

            self.view.layoutIfNeeded()
        })
    }
}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == researchCollectionView {
            return researchItems.count
        } else { // conversationScrollView (messages collection view)
            return messages.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == researchCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ResearchCell", for: indexPath) as! ResearchCell
            let item = researchItems[indexPath.item]
            cell.configure(with: item.title, color: item.color)
            return cell
        } else { // conversationScrollView (messages collection view)
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MessageCell", for: indexPath) as! MessageCollectionViewCell
            let message = messages[indexPath.item]
            cell.configure(with: message)
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == researchCollectionView {
            return CGSize(width: 64, height: 64)
        } else { // conversationScrollView (messages collection view)
            let message = messages[indexPath.item]
            let maxWidth: CGFloat = collectionView.frame.width - 32 // 左右各16点边距
            let bubbleMaxWidth: CGFloat = message.isUser ? 320 : 360
            let contentWidth: CGFloat = min(maxWidth, bubbleMaxWidth) - 24 // 减去气泡内边距（12+12）

            // 计算内容高度
            let contentView = MessageContentView(message: message)
            let estimatedSize = contentView.sizeThatFits(CGSize(width: contentWidth, height: .greatestFiniteMagnitude))

            return CGSize(width: collectionView.frame.width, height: estimatedSize.height + 24) // 加上气泡内边距（12+12）
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == researchCollectionView {
            let item = researchItems[indexPath.item]
            let alert = UIAlertController(title: "开始研究", message: "是否开始研究：\(item.title)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "取消", style: .cancel))
            alert.addAction(UIAlertAction(title: "开始", style: .default) { _ in
                // TODO: 跳转到具体研究
            })
            present(alert, animated: true)
        }
        // 消息集合视图不需要选择处理
    }
}

extension HomeViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: textView.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)

        textView.constraints.forEach { constraint in
            if constraint.firstAttribute == .height {
                constraint.constant = max(50, estimatedSize.height)
            }
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            sendButtonTapped()
            return false
        }
        return true
    }
}

class ResearchCell: UICollectionViewCell {
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
    }

    private func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(4)
        }
    }

    func configure(with title: String, color: UIColor) {
        titleLabel.text = title
        containerView.backgroundColor = color
    }
}

class MessageCollectionViewCell: UICollectionViewCell {
    private var message: Message?
    private let bubbleView = UIView()
    private var messageContentView: MessageContentView?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(bubbleView)
        bubbleView.layer.cornerRadius = 12
        bubbleView.layer.masksToBounds = true
    }

    func configure(with message: Message) {
        self.message = message

        // 移除旧的内容视图
        messageContentView?.removeFromSuperview()

        // 创建新的内容视图
        let newContentView = MessageContentView(message: message)
        bubbleView.addSubview(newContentView)
        self.messageContentView = newContentView

        // 设置气泡颜色
        if message.isUser {
            bubbleView.backgroundColor = UIColor(red: 0.07, green: 0.21, blue: 0.36, alpha: 1.0)
        } else {
            bubbleView.backgroundColor = .secondarySystemBackground
        }

        // 设置约束
        bubbleView.snp.remakeConstraints { make in
            if message.isUser {
                make.trailing.equalToSuperview().offset(-8)
                make.width.lessThanOrEqualTo(320)
            } else {
                make.leading.equalToSuperview().offset(8)
                make.width.lessThanOrEqualTo(360)
            }
            make.top.bottom.equalToSuperview()
            make.height.greaterThanOrEqualTo(50)
        }

        newContentView.snp.remakeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
    }
}

class MessageContentView: UIView {
    private var message: Message
    private let contentTextView = UITextView()

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
        contentTextView.textColor = message.isUser ? .white : .label
//        contentTextView.textAlignment = message.isUser ? .right : .left

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
        let attributedText = parseMarkdown(message.content, isUser: message.isUser)
        contentTextView.attributedText = attributedText
    }

    private func parseMarkdown(_ text: String, isUser: Bool) -> NSAttributedString? {
        let baseColor = isUser ? UIColor.white : UIColor.label
        let baseFont = UIFont.systemFont(ofSize: 16)

        // 使用cmark-gfm解析Markdown为HTML
        guard let html = markdownToHTML(text) else {
            return nil
        }
        return html
    }

    private func markdownToHTML(_ markdown: String) -> NSAttributedString? {
        do {
            // 使用swift-markdown解析Markdown
            let document = Document(parsing: markdown)

            // 创建HTML格式化器
            var htmlFormatter = Markdownosaur()
            let html = htmlFormatter.visit(document)

            return html
        } catch {
            print("Markdown to HTML error: \(error)")
            return nil
        }
    }

    private func parseHTML(_ html: String, isUser: Bool) -> NSAttributedString {
        let baseColor = isUser ? UIColor.white : UIColor.label
        let baseFont = UIFont.systemFont(ofSize: 16)

        guard let data = html.data(using: .utf8) else {
            return NSAttributedString(
                string: html,
                attributes: [
                    .font: baseFont,
                    .foregroundColor: baseColor
                ]
            )
        }

        do {
            let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ]

            let attributedString = try NSAttributedString(
                data: data,
                options: options,
                documentAttributes: nil
            )

            // 应用基础样式
            let mutableAttributedString = NSMutableAttributedString(attributedString: attributedString)
            let fullRange = NSRange(location: 0, length: mutableAttributedString.length)
            mutableAttributedString.addAttribute(.font, value: baseFont, range: fullRange)
            mutableAttributedString.addAttribute(.foregroundColor, value: baseColor, range: fullRange)

            return mutableAttributedString
        } catch {
            print("HTML parsing error: \(error)")
            return NSAttributedString(
                string: html,
                attributes: [
                    .font: baseFont,
                    .foregroundColor: baseColor
                ]
            )
        }
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return contentTextView.sizeThatFits(size)
    }
}

extension UITextView {
    private struct AssociatedKeys {
        static var placeholderLabel = "placeholderLabel"
    }

    var placeholder: String? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.placeholderLabel) as? String
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.placeholderLabel, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            updatePlaceholder()
        }
    }

    private func updatePlaceholder() {
        guard let placeholder = placeholder else { return }

        let placeholderLabel: UILabel
        if let existingLabel = objc_getAssociatedObject(self, &AssociatedKeys.placeholderLabel) as? UILabel {
            placeholderLabel = existingLabel
        } else {
            placeholderLabel = UILabel()
            placeholderLabel.textColor = .placeholderText
            placeholderLabel.font = self.font
            placeholderLabel.numberOfLines = 0
            addSubview(placeholderLabel)
            objc_setAssociatedObject(self, &AssociatedKeys.placeholderLabel, placeholderLabel, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }

        placeholderLabel.text = placeholder
        placeholderLabel.isHidden = !text.isEmpty

        placeholderLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(textContainerInset.top)
            make.leading.equalToSuperview().offset(textContainerInset.left + 4)
            make.trailing.equalToSuperview().offset(-textContainerInset.right)
        }
    }

    @objc private func textViewDidChange() {
        (objc_getAssociatedObject(self, &AssociatedKeys.placeholderLabel) as? UILabel)?.isHidden = !text.isEmpty
    }

    static func swizzleTextView() {
        let originalSelector = #selector(setter: UITextView.text)
        let swizzledSelector = #selector(UITextView.swizzled_setText(_:))

        guard let originalMethod = class_getInstanceMethod(UITextView.self, originalSelector),
              let swizzledMethod = class_getInstanceMethod(UITextView.self, swizzledSelector) else { return }

        method_exchangeImplementations(originalMethod, swizzledMethod)
    }

    @objc private func swizzled_setText(_ text: String) {
        self.swizzled_setText(text)
        updatePlaceholder()
    }
}

public struct Markdownosaur: MarkupVisitor {
    let baseFontSize: CGFloat = 15.0

    public init() {}
    
    public mutating func attributedString(from document: Document) -> NSAttributedString {
        return visit(document)
    }
    
    mutating public func defaultVisit(_ markup: Markup) -> NSAttributedString {
        let result = NSMutableAttributedString()
        
        for child in markup.children {
            result.append(visit(child))
        }
        
        return result
    }
    
    mutating public func visitText(_ text: Text) -> NSAttributedString {
        return NSAttributedString(string: text.plainText, attributes: [.font: UIFont.systemFont(ofSize: baseFontSize, weight: .regular)])
    }
    
    mutating public func visitEmphasis(_ emphasis: Emphasis) -> NSAttributedString {
        let result = NSMutableAttributedString()
        
        for child in emphasis.children {
            result.append(visit(child))
        }
        
        result.applyEmphasis()
        
        return result
    }
    
    mutating public func visitStrong(_ strong: Strong) -> NSAttributedString {
        let result = NSMutableAttributedString()
        
        for child in strong.children {
            result.append(visit(child))
        }
        
        result.applyStrong()
        
        return result
    }
    
    mutating public func visitParagraph(_ paragraph: Paragraph) -> NSAttributedString {
        let result = NSMutableAttributedString()
        
        for child in paragraph.children {
            result.append(visit(child))
        }
        
        if paragraph.hasSuccessor {
            result.append(paragraph.isContainedInList ? .singleNewline(withFontSize: baseFontSize) : .doubleNewline(withFontSize: baseFontSize))
        }
        
        return result
    }
    
    mutating public func visitHeading(_ heading: Heading) -> NSAttributedString {
        let result = NSMutableAttributedString()
        
        for child in heading.children {
            result.append(visit(child))
        }
        
        result.applyHeading(withLevel: heading.level)
        
        if heading.hasSuccessor {
            result.append(.doubleNewline(withFontSize: baseFontSize))
        }
        
        return result
    }
    
    mutating public func visitLink(_ link: Link) -> NSAttributedString {
        let result = NSMutableAttributedString()
        
        for child in link.children {
            result.append(visit(child))
        }
        
        let url = link.destination != nil ? URL(string: link.destination!) : nil
        
        result.applyLink(withURL: url)
        
        return result
    }
    
    mutating public func visitInlineCode(_ inlineCode: InlineCode) -> NSAttributedString {
        return NSAttributedString(string: inlineCode.code, attributes: [.font: UIFont.monospacedSystemFont(ofSize: baseFontSize - 1.0, weight: .regular), .foregroundColor: UIColor.systemGray])
    }
    
    public func visitCodeBlock(_ codeBlock: CodeBlock) -> NSAttributedString {
        let result = NSMutableAttributedString(string: codeBlock.code, attributes: [.font: UIFont.monospacedSystemFont(ofSize: baseFontSize - 1.0, weight: .regular), .foregroundColor: UIColor.systemGray])
        
        if codeBlock.hasSuccessor {
            result.append(.singleNewline(withFontSize: baseFontSize))
        }
    
        return result
    }
    
    mutating public func visitStrikethrough(_ strikethrough: Strikethrough) -> NSAttributedString {
        let result = NSMutableAttributedString()
        
        for child in strikethrough.children {
            result.append(visit(child))
        }
        
        result.applyStrikethrough()
        
        return result
    }
    
    mutating public func visitUnorderedList(_ unorderedList: UnorderedList) -> NSAttributedString {
        let result = NSMutableAttributedString()
        
        let font = UIFont.systemFont(ofSize: baseFontSize, weight: .regular)
                
        for listItem in unorderedList.listItems {
            var listItemAttributes: [NSAttributedString.Key: Any] = [:]
            
            let listItemParagraphStyle = NSMutableParagraphStyle()
            
            let baseLeftMargin: CGFloat = 15.0
            let leftMarginOffset = baseLeftMargin + (20.0 * CGFloat(unorderedList.listDepth))
            let spacingFromIndex: CGFloat = 8.0
            let bulletWidth = ceil(NSAttributedString(string: "•", attributes: [.font: font]).size().width)
            let firstTabLocation = leftMarginOffset + bulletWidth
            let secondTabLocation = firstTabLocation + spacingFromIndex
            
            listItemParagraphStyle.tabStops = [
                NSTextTab(textAlignment: .right, location: firstTabLocation),
                NSTextTab(textAlignment: .left, location: secondTabLocation)
            ]
            
            listItemParagraphStyle.headIndent = secondTabLocation
            
            listItemAttributes[.paragraphStyle] = listItemParagraphStyle
            listItemAttributes[.font] = UIFont.systemFont(ofSize: baseFontSize, weight: .regular)
            listItemAttributes[.listDepth] = unorderedList.listDepth
            
            let listItemAttributedString = visit(listItem).mutableCopy() as! NSMutableAttributedString
            listItemAttributedString.insert(NSAttributedString(string: "\t•\t", attributes: listItemAttributes), at: 0)
            
            result.append(listItemAttributedString)
        }
        
        if unorderedList.hasSuccessor {
            result.append(.doubleNewline(withFontSize: baseFontSize))
        }
        
        return result
    }
    
    mutating public func visitListItem(_ listItem: ListItem) -> NSAttributedString {
        let result = NSMutableAttributedString()
        
        for child in listItem.children {
            result.append(visit(child))
        }
        
        if listItem.hasSuccessor {
            result.append(.singleNewline(withFontSize: baseFontSize))
        }
        
        return result
    }
    
    mutating public func visitOrderedList(_ orderedList: OrderedList) -> NSAttributedString {
        let result = NSMutableAttributedString()
        
        for (index, listItem) in orderedList.listItems.enumerated() {
            var listItemAttributes: [NSAttributedString.Key: Any] = [:]
            
            let font = UIFont.systemFont(ofSize: baseFontSize, weight: .regular)
            let numeralFont = UIFont.monospacedDigitSystemFont(ofSize: baseFontSize, weight: .regular)
            
            let listItemParagraphStyle = NSMutableParagraphStyle()
            
            // Implement a base amount to be spaced from the left side at all times to better visually differentiate it as a list
            let baseLeftMargin: CGFloat = 15.0
            let leftMarginOffset = baseLeftMargin + (20.0 * CGFloat(orderedList.listDepth))
            
            // Grab the highest number to be displayed and measure its width (yes normally some digits are wider than others but since we're using the numeral mono font all will be the same width in this case)
            let highestNumberInList = orderedList.childCount
            let numeralColumnWidth = ceil(NSAttributedString(string: "\(highestNumberInList).", attributes: [.font: numeralFont]).size().width)
            
            let spacingFromIndex: CGFloat = 8.0
            let firstTabLocation = leftMarginOffset + numeralColumnWidth
            let secondTabLocation = firstTabLocation + spacingFromIndex
            
            listItemParagraphStyle.tabStops = [
                NSTextTab(textAlignment: .right, location: firstTabLocation),
                NSTextTab(textAlignment: .left, location: secondTabLocation)
            ]
            
            listItemParagraphStyle.headIndent = secondTabLocation
            
            listItemAttributes[.paragraphStyle] = listItemParagraphStyle
            listItemAttributes[.font] = font
            listItemAttributes[.listDepth] = orderedList.listDepth

            let listItemAttributedString = visit(listItem).mutableCopy() as! NSMutableAttributedString
            
            // Same as the normal list attributes, but for prettiness in formatting we want to use the cool monospaced numeral font
            var numberAttributes = listItemAttributes
            numberAttributes[.font] = numeralFont
            
            let numberAttributedString = NSAttributedString(string: "\t\(index + 1).\t", attributes: numberAttributes)
            listItemAttributedString.insert(numberAttributedString, at: 0)
            
            result.append(listItemAttributedString)
        }
        
        if orderedList.hasSuccessor {
            result.append(orderedList.isContainedInList ? .singleNewline(withFontSize: baseFontSize) : .doubleNewline(withFontSize: baseFontSize))
        }
        
        return result
    }
    
    mutating public func visitBlockQuote(_ blockQuote: BlockQuote) -> NSAttributedString {
        let result = NSMutableAttributedString()
        
        for child in blockQuote.children {
            var quoteAttributes: [NSAttributedString.Key: Any] = [:]
            
            let quoteParagraphStyle = NSMutableParagraphStyle()
            
            let baseLeftMargin: CGFloat = 15.0
            let leftMarginOffset = baseLeftMargin + (20.0 * CGFloat(blockQuote.quoteDepth))
            
            quoteParagraphStyle.tabStops = [NSTextTab(textAlignment: .left, location: leftMarginOffset)]
            
            quoteParagraphStyle.headIndent = leftMarginOffset
            
            quoteAttributes[.paragraphStyle] = quoteParagraphStyle
            quoteAttributes[.font] = UIFont.systemFont(ofSize: baseFontSize, weight: .regular)
            quoteAttributes[.listDepth] = blockQuote.quoteDepth
            
            let quoteAttributedString = visit(child).mutableCopy() as! NSMutableAttributedString
            quoteAttributedString.insert(NSAttributedString(string: "\t", attributes: quoteAttributes), at: 0)
            
            quoteAttributedString.addAttribute(.foregroundColor, value: UIColor.systemGray)
            
            result.append(quoteAttributedString)
        }
        
        if blockQuote.hasSuccessor {
            result.append(.doubleNewline(withFontSize: baseFontSize))
        }
        
        return result
    }
}

// MARK: - Extensions Land

extension NSMutableAttributedString {
    func applyEmphasis() {
        enumerateAttribute(.font, in: NSRange(location: 0, length: length), options: []) { value, range, stop in
            guard let font = value as? UIFont else { return }
            
            let newFont = font.apply(newTraits: .traitItalic)
            addAttribute(.font, value: newFont, range: range)
        }
    }
    
    func applyStrong() {
        enumerateAttribute(.font, in: NSRange(location: 0, length: length), options: []) { value, range, stop in
            guard let font = value as? UIFont else { return }
            
            let newFont = font.apply(newTraits: .traitBold)
            addAttribute(.font, value: newFont, range: range)
        }
    }
    
    func applyLink(withURL url: URL?) {
        addAttribute(.foregroundColor, value: UIColor.systemBlue)
        
        if let url = url {
            addAttribute(.link, value: url)
        }
    }
    
    func applyBlockquote() {
        addAttribute(.foregroundColor, value: UIColor.systemGray)
    }
    
    func applyHeading(withLevel headingLevel: Int) {
        enumerateAttribute(.font, in: NSRange(location: 0, length: length), options: []) { value, range, stop in
            guard let font = value as? UIFont else { return }
            
            let newFont = font.apply(newTraits: .traitBold, newPointSize: 28.0 - CGFloat(headingLevel * 2))
            addAttribute(.font, value: newFont, range: range)
        }
    }
    
    func applyStrikethrough() {
        addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue)
    }
}

extension UIFont {
    func apply(newTraits: UIFontDescriptor.SymbolicTraits, newPointSize: CGFloat? = nil) -> UIFont {
        var existingTraits = fontDescriptor.symbolicTraits
        existingTraits.insert(newTraits)
        
        guard let newFontDescriptor = fontDescriptor.withSymbolicTraits(existingTraits) else { return self }
        return UIFont(descriptor: newFontDescriptor, size: newPointSize ?? pointSize)
    }
}

extension ListItemContainer {
    /// Depth of the list if nested within others. Index starts at 0.
    var listDepth: Int {
        var index = 0

        var currentElement = parent

        while currentElement != nil {
            if currentElement is ListItemContainer {
                index += 1
            }

            currentElement = currentElement?.parent
        }
        
        return index
    }
}

extension BlockQuote {
    /// Depth of the quote if nested within others. Index starts at 0.
    var quoteDepth: Int {
        var index = 0

        var currentElement = parent

        while currentElement != nil {
            if currentElement is BlockQuote {
                index += 1
            }

            currentElement = currentElement?.parent
        }
        
        return index
    }
}

extension NSAttributedString.Key {
    static let listDepth = NSAttributedString.Key("ListDepth")
    static let quoteDepth = NSAttributedString.Key("QuoteDepth")
}

extension NSMutableAttributedString {
    func addAttribute(_ name: NSAttributedString.Key, value: Any) {
        addAttribute(name, value: value, range: NSRange(location: 0, length: length))
    }
    
    func addAttributes(_ attrs: [NSAttributedString.Key : Any]) {
        addAttributes(attrs, range: NSRange(location: 0, length: length))
    }
}

extension Markup {
    /// Returns true if this element has sibling elements after it.
    var hasSuccessor: Bool {
        guard let childCount = parent?.childCount else { return false }
        return indexInParent < childCount - 1
    }
    
    var isContainedInList: Bool {
        var currentElement = parent

        while currentElement != nil {
            if currentElement is ListItemContainer {
                return true
            }

            currentElement = currentElement?.parent
        }
        
        return false
    }
}

extension NSAttributedString {
    static func singleNewline(withFontSize fontSize: CGFloat) -> NSAttributedString {
        return NSAttributedString(string: "\n", attributes: [.font: UIFont.systemFont(ofSize: fontSize, weight: .regular)])
    }
    
    static func doubleNewline(withFontSize fontSize: CGFloat) -> NSAttributedString {
        return NSAttributedString(string: "\n\n", attributes: [.font: UIFont.systemFont(ofSize: fontSize, weight: .regular)])
    }
}
