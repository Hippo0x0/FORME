import UIKit
import SnapKit

class DeepSeekSettingsViewController: UIViewController {

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

    private let statusSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "API状态"
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
        label.text = "状态: 未连接"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        return label
    }()

    private let planLabel: UILabel = {
        let label = UILabel()
        label.text = "方案: 免费版"
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()

    private let usageLabel: UILabel = {
        let label = UILabel()
        label.text = "本月用量: 0/10000 tokens"
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()

    private let configSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "API配置"
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        return label
    }()

    private let apiKeyView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 8
        return view
    }()

    private let apiKeyLabel: UILabel = {
        let label = UILabel()
        label.text = "API Key"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .label
        return label
    }()

    private let apiKeyTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "请输入API Key"
        textField.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        textField.isSecureTextEntry = true
        textField.textContentType = .password
        return textField
    }()

    private let showHideButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("显示", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.setTitleColor(UIColor(red: 0.07, green: 0.21, blue: 0.36, alpha: 1.0), for: .normal)
        return button
    }()

    private let regenerateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("重新生成", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.setTitleColor(UIColor(red: 0.07, green: 0.21, blue: 0.36, alpha: 1.0), for: .normal)
        return button
    }()

    private let testButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("测试连接", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.setTitleColor(UIColor(red: 0.07, green: 0.21, blue: 0.36, alpha: 1.0), for: .normal)
        return button
    }()

    private let baseURLView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 8
        return view
    }()

    private let baseURLLabel: UILabel = {
        let label = UILabel()
        label.text = "基础URL"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .label
        return label
    }()

    private let baseURLTextField: UITextField = {
        let textField = UITextField()
        textField.text = "https://api.deepseek.com"
        textField.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        textField.keyboardType = .URL
        return textField
    }()

    private let editURLButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("编辑", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.setTitleColor(UIColor(red: 0.07, green: 0.21, blue: 0.36, alpha: 1.0), for: .normal)
        return button
    }()

    private let modelView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 8
        return view
    }()

    private let modelLabel: UILabel = {
        let label = UILabel()
        label.text = "模型选择"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .label
        return label
    }()

    private let modelTextField: UITextField = {
        let textField = UITextField()
        textField.text = "deepseek-chat"
        textField.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        textField.isEnabled = false
        return textField
    }()

    private let switchModelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("切换模型", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.setTitleColor(UIColor(red: 0.07, green: 0.21, blue: 0.36, alpha: 1.0), for: .normal)
        return button
    }()

    private let usageSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "用量控制"
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        return label
    }()

    private let monthlyLimitView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 8
        return view
    }()

    private let monthlyLimitLabel: UILabel = {
        let label = UILabel()
        label.text = "每月限额"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .label
        return label
    }()

    private let monthlyLimitTextField: UITextField = {
        let textField = UITextField()
        textField.text = "10000"
        textField.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        textField.keyboardType = .numberPad
        return textField
    }()

    private let tokensLabel: UILabel = {
        let label = UILabel()
        label.text = "tokens"
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()

    private let singleLimitView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 8
        return view
    }()

    private let singleLimitLabel: UILabel = {
        let label = UILabel()
        label.text = "单次最大"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .label
        return label
    }()

    private let singleLimitTextField: UITextField = {
        let textField = UITextField()
        textField.text = "2000"
        textField.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        textField.keyboardType = .numberPad
        return textField
    }()

    private let singleTokensLabel: UILabel = {
        let label = UILabel()
        label.text = "tokens"
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()

    private let alertSwitch: UISwitch = {
        let switchControl = UISwitch()
        switchControl.isOn = true
        return switchControl
    }()

    private let alertLabel: UILabel = {
        let label = UILabel()
        label.text = "启用用量提醒"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .label
        return label
    }()

    private let thresholdView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 8
        return view
    }()

    private let thresholdLabel: UILabel = {
        let label = UILabel()
        label.text = "提醒阈值"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .label
        return label
    }()

    private let thresholdTextField: UITextField = {
        let textField = UITextField()
        textField.text = "80"
        textField.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        textField.keyboardType = .numberPad
        return textField
    }()

    private let percentLabel: UILabel = {
        let label = UILabel()
        label.text = "%"
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()

    private let strategySectionLabel: UILabel = {
        let label = UILabel()
        label.text = "使用策略"
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        return label
    }()

    private let defaultModeView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 8
        return view
    }()

    private let defaultModeLabel: UILabel = {
        let label = UILabel()
        label.text = "默认模式"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .label
        return label
    }()

    private let modeSegmentedControl: UISegmentedControl = {
        let items = ["自动", "仅本地", "仅API"]
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.selectedSegmentIndex = 0
        return segmentedControl
    }()

    private let fallbackSwitch: UISwitch = {
        let switchControl = UISwitch()
        switchControl.isOn = true
        return switchControl
    }()

    private let fallbackLabel: UILabel = {
        let label = UILabel()
        label.text = "自动降级"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .label
        return label
    }()

    private let fallbackDescLabel: UILabel = {
        let label = UILabel()
        label.text = "API失败时自动使用本地模型"
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()

    private let actionButtonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.distribution = .fillEqually
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        setupKeyboardDismissal()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationItem.title = "DeepSeek API设置"

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(statusSectionLabel)
        contentView.addSubview(statusView)
        contentView.addSubview(configSectionLabel)
        contentView.addSubview(apiKeyView)
        contentView.addSubview(baseURLView)
        contentView.addSubview(modelView)
        contentView.addSubview(usageSectionLabel)
        contentView.addSubview(monthlyLimitView)
        contentView.addSubview(singleLimitView)
        contentView.addSubview(alertSwitch)
        contentView.addSubview(alertLabel)
        contentView.addSubview(thresholdView)
        contentView.addSubview(strategySectionLabel)
        contentView.addSubview(defaultModeView)
        contentView.addSubview(fallbackSwitch)
        contentView.addSubview(fallbackLabel)
        contentView.addSubview(fallbackDescLabel)
        contentView.addSubview(actionButtonsStackView)

        statusView.addSubview(statusLabel)
        statusView.addSubview(planLabel)
        statusView.addSubview(usageLabel)

        apiKeyView.addSubview(apiKeyLabel)
        apiKeyView.addSubview(apiKeyTextField)
        apiKeyView.addSubview(showHideButton)
        apiKeyView.addSubview(regenerateButton)
        apiKeyView.addSubview(testButton)

        baseURLView.addSubview(baseURLLabel)
        baseURLView.addSubview(baseURLTextField)
        baseURLView.addSubview(editURLButton)

        modelView.addSubview(modelLabel)
        modelView.addSubview(modelTextField)
        modelView.addSubview(switchModelButton)

        monthlyLimitView.addSubview(monthlyLimitLabel)
        monthlyLimitView.addSubview(monthlyLimitTextField)
        monthlyLimitView.addSubview(tokensLabel)

        singleLimitView.addSubview(singleLimitLabel)
        singleLimitView.addSubview(singleLimitTextField)
        singleLimitView.addSubview(singleTokensLabel)

        thresholdView.addSubview(thresholdLabel)
        thresholdView.addSubview(thresholdTextField)
        thresholdView.addSubview(percentLabel)

        defaultModeView.addSubview(defaultModeLabel)
        defaultModeView.addSubview(modeSegmentedControl)

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

        statusSectionLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
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

        planLabel.snp.makeConstraints { make in
            make.top.equalTo(statusLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        usageLabel.snp.makeConstraints { make in
            make.top.equalTo(planLabel.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        configSectionLabel.snp.makeConstraints { make in
            make.top.equalTo(statusView.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        apiKeyView.snp.makeConstraints { make in
            make.top.equalTo(configSectionLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(120)
        }

        apiKeyLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        apiKeyTextField.snp.makeConstraints { make in
            make.top.equalTo(apiKeyLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(36)
        }

        showHideButton.snp.makeConstraints { make in
            make.top.equalTo(apiKeyTextField.snp.bottom).offset(12)
            make.leading.equalToSuperview().inset(16)
        }

        regenerateButton.snp.makeConstraints { make in
            make.top.equalTo(apiKeyTextField.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }

        testButton.snp.makeConstraints { make in
            make.top.equalTo(apiKeyTextField.snp.bottom).offset(12)
            make.trailing.equalToSuperview().inset(16)
        }

        baseURLView.snp.makeConstraints { make in
            make.top.equalTo(apiKeyView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(70)
        }

        baseURLLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        baseURLTextField.snp.makeConstraints { make in
            make.top.equalTo(baseURLLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().inset(16)
            make.trailing.equalTo(editURLButton.snp.leading).offset(-8)
        }

        editURLButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalTo(baseURLTextField)
            make.width.equalTo(50)
        }

        modelView.snp.makeConstraints { make in
            make.top.equalTo(baseURLView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(70)
        }

        modelLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        modelTextField.snp.makeConstraints { make in
            make.top.equalTo(modelLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().inset(16)
            make.trailing.equalTo(switchModelButton.snp.leading).offset(-8)
        }

        switchModelButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalTo(modelTextField)
            make.width.equalTo(80)
        }

        usageSectionLabel.snp.makeConstraints { make in
            make.top.equalTo(modelView.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        monthlyLimitView.snp.makeConstraints { make in
            make.top.equalTo(usageSectionLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(60)
        }

        monthlyLimitLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.width.equalTo(80)
        }

        monthlyLimitTextField.snp.makeConstraints { make in
            make.leading.equalTo(monthlyLimitLabel.snp.trailing).offset(12)
            make.centerY.equalToSuperview()
            make.width.equalTo(80)
        }

        tokensLabel.snp.makeConstraints { make in
            make.leading.equalTo(monthlyLimitTextField.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
        }

        singleLimitView.snp.makeConstraints { make in
            make.top.equalTo(monthlyLimitView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(60)
        }

        singleLimitLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.width.equalTo(80)
        }

        singleLimitTextField.snp.makeConstraints { make in
            make.leading.equalTo(singleLimitLabel.snp.trailing).offset(12)
            make.centerY.equalToSuperview()
            make.width.equalTo(80)
        }

        singleTokensLabel.snp.makeConstraints { make in
            make.leading.equalTo(singleLimitTextField.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
        }

        alertSwitch.snp.makeConstraints { make in
            make.top.equalTo(singleLimitView.snp.bottom).offset(20)
            make.leading.equalToSuperview().inset(20)
        }

        alertLabel.snp.makeConstraints { make in
            make.leading.equalTo(alertSwitch.snp.trailing).offset(12)
            make.centerY.equalTo(alertSwitch)
        }

        thresholdView.snp.makeConstraints { make in
            make.top.equalTo(alertSwitch.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(60)
        }

        thresholdLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.width.equalTo(80)
        }

        thresholdTextField.snp.makeConstraints { make in
            make.leading.equalTo(thresholdLabel.snp.trailing).offset(12)
            make.centerY.equalToSuperview()
            make.width.equalTo(60)
        }

        percentLabel.snp.makeConstraints { make in
            make.leading.equalTo(thresholdTextField.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
        }

        strategySectionLabel.snp.makeConstraints { make in
            make.top.equalTo(thresholdView.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        defaultModeView.snp.makeConstraints { make in
            make.top.equalTo(strategySectionLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(60)
        }

        defaultModeLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.width.equalTo(80)
        }

        modeSegmentedControl.snp.makeConstraints { make in
            make.leading.equalTo(defaultModeLabel.snp.trailing).offset(12)
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }

        fallbackSwitch.snp.makeConstraints { make in
            make.top.equalTo(defaultModeView.snp.bottom).offset(20)
            make.leading.equalToSuperview().inset(20)
        }

        fallbackLabel.snp.makeConstraints { make in
            make.leading.equalTo(fallbackSwitch.snp.trailing).offset(12)
            make.centerY.equalTo(fallbackSwitch)
        }

        fallbackDescLabel.snp.makeConstraints { make in
            make.top.equalTo(fallbackLabel.snp.bottom).offset(4)
            make.leading.equalTo(fallbackLabel)
        }

        actionButtonsStackView.snp.makeConstraints { make in
            make.top.equalTo(fallbackDescLabel.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().offset(-20)
        }
    }

    private func setupActionButtons() {
        let buttons = [
            ("保存配置", "checkmark.circle"),
            ("重置为默认", "arrow.counterclockwise"),
            ("断开连接", "xmark.circle")
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
        showHideButton.addTarget(self, action: #selector(showHideButtonTapped), for: .touchUpInside)
        regenerateButton.addTarget(self, action: #selector(regenerateButtonTapped), for: .touchUpInside)
        testButton.addTarget(self, action: #selector(testButtonTapped), for: .touchUpInside)
        editURLButton.addTarget(self, action: #selector(editURLButtonTapped), for: .touchUpInside)
        switchModelButton.addTarget(self, action: #selector(switchModelButtonTapped), for: .touchUpInside)
        alertSwitch.addTarget(self, action: #selector(alertSwitchChanged), for: .valueChanged)
        fallbackSwitch.addTarget(self, action: #selector(fallbackSwitchChanged), for: .valueChanged)
    }

    @objc private func showHideButtonTapped() {
        apiKeyTextField.isSecureTextEntry.toggle()
        let title = apiKeyTextField.isSecureTextEntry ? "显示" : "隐藏"
        showHideButton.setTitle(title, for: .normal)
    }

    @objc private func regenerateButtonTapped() {
        let alert = UIAlertController(title: "重新生成API Key", message: "确定要重新生成API Key吗？旧的Key将立即失效。", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "重新生成", style: .destructive) { _ in
            // TODO: 实现重新生成API Key逻辑
            self.apiKeyTextField.text = "sk-new-generated-api-key-123456"
        })
        present(alert, animated: true)
    }

    @objc private func testButtonTapped() {
        guard let apiKey = apiKeyTextField.text, !apiKey.isEmpty else {
            showAlert(title: "错误", message: "请输入API Key")
            return
        }

        statusLabel.text = "状态: 测试连接中..."
        statusLabel.textColor = .systemOrange

        // 模拟测试连接
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let success = apiKey.hasPrefix("sk-")
            if success {
                self.statusLabel.text = "状态: 已连接 ✅"
                self.statusLabel.textColor = .systemGreen
                self.showAlert(title: "成功", message: "API连接测试成功")
            } else {
                self.statusLabel.text = "状态: 连接失败 ❌"
                self.statusLabel.textColor = .systemRed
                self.showAlert(title: "失败", message: "API连接测试失败，请检查API Key")
            }
        }
    }

    @objc private func editURLButtonTapped() {
        baseURLTextField.isEnabled.toggle()
        let title = baseURLTextField.isEnabled ? "完成" : "编辑"
        editURLButton.setTitle(title, for: .normal)

        if !baseURLTextField.isEnabled {
            baseURLTextField.resignFirstResponder()
        } else {
            baseURLTextField.becomeFirstResponder()
        }
    }

    @objc private func switchModelButtonTapped() {
        let alert = UIAlertController(title: "切换模型", message: "请选择要使用的模型", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "deepseek-chat", style: .default) { _ in
            self.modelTextField.text = "deepseek-chat"
        })
        alert.addAction(UIAlertAction(title: "deepseek-coder", style: .default) { _ in
            self.modelTextField.text = "deepseek-coder"
        })
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(alert, animated: true)
    }

    @objc private func alertSwitchChanged() {
        thresholdView.isHidden = !alertSwitch.isOn
    }

    @objc private func fallbackSwitchChanged() {
        // TODO: 处理自动降级开关变化
    }

    @objc private func actionButtonTapped(_ sender: UIButton) {
        guard let action = sender.accessibilityIdentifier else { return }

        switch action {
        case "保存配置":
            saveConfiguration()
        case "重置为默认":
            resetToDefault()
        case "断开连接":
            disconnect()
        default:
            break
        }
    }

    private func saveConfiguration() {
        // TODO: 实现保存配置逻辑
        showAlert(title: "保存成功", message: "配置已保存")
    }

    private func resetToDefault() {
        let alert = UIAlertController(title: "重置为默认", message: "确定要重置所有设置为默认值吗？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "重置", style: .destructive) { _ in
            self.resetConfiguration()
        })
        present(alert, animated: true)
    }

    private func resetConfiguration() {
        apiKeyTextField.text = ""
        baseURLTextField.text = "https://api.deepseek.com"
        modelTextField.text = "deepseek-chat"
        monthlyLimitTextField.text = "10000"
        singleLimitTextField.text = "2000"
        alertSwitch.isOn = true
        thresholdTextField.text = "80"
        modeSegmentedControl.selectedSegmentIndex = 0
        fallbackSwitch.isOn = true
        statusLabel.text = "状态: 未连接"
        statusLabel.textColor = .label

        showAlert(title: "重置完成", message: "已重置为默认设置")
    }

    private func disconnect() {
        let alert = UIAlertController(title: "断开连接", message: "确定要断开DeepSeek API连接吗？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "断开", style: .destructive) { _ in
            self.apiKeyTextField.text = ""
            self.statusLabel.text = "状态: 未连接"
            self.statusLabel.textColor = .label
            self.showAlert(title: "已断开", message: "DeepSeek API连接已断开")
        })
        present(alert, animated: true)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
    

}
