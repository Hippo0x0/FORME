import UIKit
import SnapKit

class WebViewDemoViewController: UIViewController {
    private var messages: [Message] = []
    private var collectionView: UICollectionView!
    private let maxCellWidth: CGFloat = UIScreen.main.bounds.width - 32

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTestMessages()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Web"

        // 设置集合视图布局
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 4
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)

        // 创建集合视图
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(WebViewMessageCell.self, forCellWithReuseIdentifier: WebViewMessageCell.reuseIdentifier)
        collectionView.alwaysBounceVertical = true

        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // 添加测试按钮
        let testButton = UIButton(type: .system)
        testButton.setTitle("添加测试消息", for: .normal)
        testButton.backgroundColor = .systemBlue
        testButton.setTitleColor(.white, for: .normal)
        testButton.layer.cornerRadius = 8
        testButton.addTarget(self, action: #selector(addTestMessage), for: .touchUpInside)

        view.addSubview(testButton)
        testButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.centerX.equalToSuperview()
            make.width.equalTo(150)
            make.height.equalTo(44)
        }
    }

    private func setupTestMessages() {
        // 添加一些测试消息
        let testMessages = [
            Message(content: "# 标题1\n这是一个简单的Markdown消息，包含**粗体**和*斜体*文本。", isUser: false),
            Message(content: "## 标题2\n`内联代码`和**粗体文本**的组合。", isUser: true),
            Message(content: "### 标题3\n```swift\nlet message = \"代码块示例\"\nprint(message)\n```", isUser: false),
            Message(content: "这是一个包含链接的消息：[点击这里](https://www.example.com) 访问示例网站。", isUser: true),
            Message(content: "> 引用文本\n> 这是引用的内容\n\n普通文本继续。", isUser: false),
            Message(content: "**复杂Markdown示例**:\n1. 第一项\n2. 第二项\n3. 第三项\n\n- 无序项1\n- 无序项2", isUser: true),
        ]

        messages.append(contentsOf: testMessages)
        collectionView.reloadData()

        // 滚动到底部
        DispatchQueue.main.async {
            let lastSection = self.collectionView.numberOfSections - 1
            let lastItem = self.collectionView.numberOfItems(inSection: lastSection) - 1
            if lastItem >= 0 {
                let indexPath = IndexPath(item: lastItem, section: lastSection)
                self.collectionView.scrollToItem(at: indexPath, at: .bottom, animated: false)
            }
        }
    }

    @objc private func addTestMessage() {
        let markdownExamples = [
            "# 新消息标题\n这是新添加的测试消息，包含**粗体**和`代码`。",
            "## 流式更新测试\n这个消息会模拟流式更新...",
            "```python\nprint('Hello, World!')\nfor i in range(5):\n    print(f'Count: {i}')\n```",
            "**重要通知**\n这是一个重要的通知消息，包含多个段落。\n\n第二段落继续说明。",
            "> 名人名言\n> 代码就像幽默，如果你必须解释它，那就不好了。\n\n— Cory House",
            "### 数学公式\n虽然WebView不支持LaTeX，但可以显示简单的数学：\n`a² + b² = c²`\n`E = mc²`",
        ]

        let randomIndex = Int.random(in: 0..<markdownExamples.count)
        let isUser = Bool.random()
        let newMessage = Message(content: markdownExamples[randomIndex], isUser: isUser)

        messages.append(newMessage)

        let indexPath = IndexPath(item: messages.count - 1, section: 0)
        collectionView.insertItems(at: [indexPath])

        // 滚动到新消息
        DispatchQueue.main.async {
            self.collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
        }

        // 模拟流式更新
        if randomIndex == 1 { // 流式更新测试消息
            simulateStreamingUpdate(for: newMessage)
        }
    }

    private func simulateStreamingUpdate(for message: Message) {
        let updates = [
            "## 流式更新测试\n这个消息会模拟流式更新...",
            "## 流式更新测试\n这个消息会模拟流式更新...正在加载",
            "## 流式更新测试\n这个消息会模拟流式更新...正在加载数据",
            "## 流式更新测试\n这个消息会模拟流式更新...正在加载数据分析",
            "## 流式更新测试\n这个消息会模拟流式更新...正在加载数据分析完成！",
        ]

        var updateIndex = 0
        let timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] timer in
            guard let self = self, updateIndex < updates.count else {
                timer.invalidate()
                return
            }

            message.content = updates[updateIndex]

            // 找到对应的单元格并更新
            if let index = self.messages.firstIndex(where: { $0.id == message.id }) {
                let indexPath = IndexPath(item: index, section: 0)
                if let cell = self.collectionView.cellForItem(at: indexPath) as? WebViewMessageCell {
                    cell.updateMessageContent(updates[updateIndex])
                }
            }

            updateIndex += 1
        }

        // 启动定时器
        RunLoop.current.add(timer, forMode: .common)
    }
}

extension WebViewDemoViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WebViewMessageCell.reuseIdentifier, for: indexPath) as! WebViewMessageCell
        let message = messages[indexPath.item]
        cell.configure(with: message, maxWidth: maxCellWidth)
        return cell
    }
}

extension WebViewDemoViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let message = messages[indexPath.item]
        return WebViewMessageCell.cellSize(for: message, maxWidth: maxCellWidth)
    }
}
