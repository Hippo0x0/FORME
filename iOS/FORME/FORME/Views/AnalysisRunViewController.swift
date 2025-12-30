import UIKit
import SnapKit

class AnalysisRunViewController: UIViewController {

    var analysisType: String = "深度理解"
    var isDeepSeek: Bool = true

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()

    private let contentView: UIView = {
        let view = UIView()
        return view
    }()

    private let configSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "分析配置"
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        return label
    }()

    private let selectMaterialButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("选择资料...", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(UIColor(red: 0.07, green: 0.21, blue: 0.36, alpha: 1.0), for: .normal)
        button.backgroundColor = .secondarySystemBackground
        button.layer.cornerRadius = 8
        button.contentHorizontalAlignment = .left
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return button
    }()

    private let modelLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .label
        return label
    }()

    private let apiModeSegmentedControl: UISegmentedControl = {
        let items = ["自动", "仅本地", "仅API"]
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.selectedSegmentIndex = 0
        return segmentedControl
    }()

    private let paramsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .fill
        return stackView
    }()

    private let apiConfigView: UIView = {
        let view = UIView()
        view.backgroundColor = .tertiarySystemBackground
        view.layer.cornerRadius = 8
        view.isHidden = true
        return view
    }()

    private let apiConfigLabel: UILabel = {
        let label = UILabel()
        label.text = "使用DeepSeek API需要配置API Key"
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()

    private let goToSettingsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("前往设置", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.setTitleColor(UIColor(red: 0.07, green: 0.21, blue: 0.36, alpha: 1.0), for: .normal)
        return button
    }()

    private let useLocalButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("使用本地模型", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.setTitleColor(.secondaryLabel, for: .normal)
        return button
    }()

    private let statusSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "运行状态"
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        return label
    }()

    private let statusView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 12
        return view
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "准备分析..."
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        return label
    }()

    private let progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.progressTintColor = UIColor(red: 0.07, green: 0.21, blue: 0.36, alpha: 1.0)
        return progressView
    }()

    private let usageLabel: UILabel = {
        let label = UILabel()
        label.text = "已使用: 0 tokens"
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()

    private let resultSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "分析结果"
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        return label
    }()

    private let resultTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        textView.textColor = .label
        textView.backgroundColor = .secondarySystemBackground
        textView.layer.cornerRadius = 8
        textView.isEditable = false
        textView.isHidden = true
        return textView
    }()

    private let actionButtonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.distribution = .fillEqually
        return stackView
    }()

    private var isAnalyzing = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        updateUIForAnalysisType()
        setupKeyboardDismissal()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationItem.title = analysisType

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(configSectionLabel)
        contentView.addSubview(selectMaterialButton)
        contentView.addSubview(modelLabel)
        contentView.addSubview(apiModeSegmentedControl)
        contentView.addSubview(paramsStackView)
        contentView.addSubview(apiConfigView)
        contentView.addSubview(statusSectionLabel)
        contentView.addSubview(statusView)
        contentView.addSubview(resultSectionLabel)
        contentView.addSubview(resultTextView)
        contentView.addSubview(actionButtonsStackView)

        apiConfigView.addSubview(apiConfigLabel)
        apiConfigView.addSubview(goToSettingsButton)
        apiConfigView.addSubview(useLocalButton)

        statusView.addSubview(statusLabel)
        statusView.addSubview(progressView)
        statusView.addSubview(usageLabel)

        setupParams()
        setupActionButtons()
    }

    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }

        configSectionLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        selectMaterialButton.snp.makeConstraints { make in
            make.top.equalTo(configSectionLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }

        modelLabel.snp.makeConstraints { make in
            make.top.equalTo(selectMaterialButton.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        apiModeSegmentedControl.snp.makeConstraints { make in
            make.top.equalTo(modelLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        paramsStackView.snp.makeConstraints { make in
            make.top.equalTo(apiModeSegmentedControl.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        apiConfigView.snp.makeConstraints { make in
            make.top.equalTo(paramsStackView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(100)
        }

        apiConfigLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        goToSettingsButton.snp.makeConstraints { make in
            make.top.equalTo(apiConfigLabel.snp.bottom).offset(12)
            make.leading.equalToSuperview().inset(16)
        }

        useLocalButton.snp.makeConstraints { make in
            make.top.equalTo(apiConfigLabel.snp.bottom).offset(12)
            make.trailing.equalToSuperview().inset(16)
        }

        statusSectionLabel.snp.makeConstraints { make in
            make.top.equalTo(apiConfigView.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        statusView.snp.makeConstraints { make in
            make.top.equalTo(statusSectionLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(100)
        }

        statusLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        progressView.snp.makeConstraints { make in
            make.top.equalTo(statusLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(4)
        }

        usageLabel.snp.makeConstraints { make in
            make.top.equalTo(progressView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        resultSectionLabel.snp.makeConstraints { make in
            make.top.equalTo(statusView.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        resultTextView.snp.makeConstraints { make in
            make.top.equalTo(resultSectionLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(200)
        }

        actionButtonsStackView.snp.makeConstraints { make in
            make.top.equalTo(resultTextView.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().offset(-20)
        }
    }

    private func setupParams() {
        let params = [
            ("分析深度", ["浅层", "中等", "深入"]),
            ("语言", ["中文", "英文", "自动"]),
            ("最大token", ["1000", "2000", "4000"])
        ]

        for (title, options) in params {
            let paramView = createParamView(title: title, options: options)
            paramsStackView.addArrangedSubview(paramView)
        }
    }

    private func createParamView(title: String, options: [String]) -> UIView {
        let containerView = UIView()

        let titleLabel = UILabel()
        titleLabel.text = "\(title):"
        titleLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        titleLabel.textColor = .label

        let segmentedControl = UISegmentedControl(items: options)
        segmentedControl.selectedSegmentIndex = 1

        containerView.addSubview(titleLabel)
        containerView.addSubview(segmentedControl)

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(80)
        }

        segmentedControl.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing).offset(12)
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        return containerView
    }

    private func setupActionButtons() {
        let buttons = [
            ("保存结果", "square.and.arrow.down"),
            ("继续提问", "bubble.right"),
            ("分享", "square.and.arrow.up")
        ]

        for (title, iconName) in buttons {
            let button = createActionButton(title: title, iconName: iconName)
            actionButtonsStackView.addArrangedSubview(button)
        }
    }

    private func createActionButton(title: String, iconName: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setImage(UIImage(systemName: iconName), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.tintColor = UIColor(red: 0.07, green: 0.21, blue: 0.36, alpha: 1.0)
        button.backgroundColor = .secondarySystemBackground
        button.layer.cornerRadius = 8

        button.addTarget(self, action: #selector(actionButtonTapped(_:)), for: .touchUpInside)

        button.accessibilityIdentifier = title

        return button
    }

    private func setupActions() {
        selectMaterialButton.addTarget(self, action: #selector(selectMaterialButtonTapped), for: .touchUpInside)
        goToSettingsButton.addTarget(self, action: #selector(goToSettingsButtonTapped), for: .touchUpInside)
        useLocalButton.addTarget(self, action: #selector(useLocalButtonTapped), for: .touchUpInside)
        apiModeSegmentedControl.addTarget(self, action: #selector(apiModeChanged), for: .valueChanged)
    }

    private func updateUIForAnalysisType() {
        modelLabel.text = "分析模型: \(isDeepSeek ? "DeepSeek \(analysisType)" : "本地 \(analysisType)")"
        apiModeSegmentedControl.isHidden = !isDeepSeek
        apiConfigView.isHidden = !isDeepSeek

        if isDeepSeek {
            checkAPIStatus()
        }
    }

    private func checkAPIStatus() {
        // TODO: 检查API状态
        let hasAPIKey = false // 临时值
        apiConfigView.isHidden = hasAPIKey
    }

    @objc private func selectMaterialButtonTapped() {
        let alert = UIAlertController(title: "选择资料", message: "请选择要分析的资料", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "资料1: AI发展趋势报告", style: .default) { _ in
            self.selectMaterialButton.setTitle("资料1: AI发展趋势报告", for: .normal)
        })
        alert.addAction(UIAlertAction(title: "资料2: 机器学习入门", style: .default) { _ in
            self.selectMaterialButton.setTitle("资料2: 机器学习入门", for: .normal)
        })
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(alert, animated: true)
    }

    @objc private func goToSettingsButtonTapped() {
        let deepSeekSettingsVC = DeepSeekSettingsViewController()
        navigationController?.pushViewController(deepSeekSettingsVC, animated: true)
    }

    @objc private func useLocalButtonTapped() {
        isDeepSeek = false
        updateUIForAnalysisType()
        startAnalysis()
    }

    @objc private func apiModeChanged() {
        // TODO: 处理API模式变化
    }

    @objc private func actionButtonTapped(_ sender: UIButton) {
        guard let action = sender.accessibilityIdentifier else { return }

        switch action {
        case "保存结果":
            saveResult()
        case "继续提问":
            continueQuestion()
        case "分享":
            shareResult()
        default:
            break
        }
    }

    private func startAnalysis() {
        guard !isAnalyzing else { return }

        isAnalyzing = true
        statusLabel.text = isDeepSeek ? "正在调用DeepSeek API..." : "正在分析..."
        progressView.progress = 0
        usageLabel.text = "已使用: 0 tokens"

        // 模拟分析过程
        simulateAnalysis()
    }

    private func simulateAnalysis() {
        var progress: Float = 0
        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }

            progress += 0.02
            self.progressView.progress = progress

            if self.isDeepSeek {
                let tokens = Int(progress * 1000)
                self.usageLabel.text = "已使用: \(tokens) tokens"
            }

            if progress >= 1.0 {
                timer.invalidate()
                self.analysisComplete()
            }
        }
        RunLoop.current.add(timer, forMode: .common)
    }

    private func analysisComplete() {
        isAnalyzing = false
        statusLabel.text = "分析完成"

        // 显示结果
        resultTextView.isHidden = false
        resultTextView.text = """
        ## \(analysisType)结果

        本文主要讨论了人工智能的发展趋势和未来影响。

        ## 核心观点
        1. AI技术正在快速发展，将在未来5-10年内深刻改变各行各业
        2. 机器学习、深度学习等技术已经取得突破性进展
        3. 伦理和安全问题需要得到重视

        ## 关键洞察
        - AI将创造新的就业机会，同时也会替代部分传统工作
        - 数据质量和算法透明度是关键挑战
        - 跨学科合作将成为AI发展的重要趋势
        """
    }

    private func saveResult() {
        let alert = UIAlertController(title: "保存结果", message: "分析结果已保存", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }

    private func continueQuestion() {
        let alert = UIAlertController(title: "继续提问", message: "请输入您的问题", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "您的问题"
        }
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "提问", style: .default) { _ in
            // TODO: 处理提问
        })
        present(alert, animated: true)
    }

    private func shareResult() {
        let activityVC = UIActivityViewController(activityItems: [resultTextView.text ?? ""], applicationActivities: nil)
        present(activityVC, animated: true)
    }

}
