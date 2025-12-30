import UIKit
import SnapKit

class ProfileViewController: UIViewController {

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

    private let userInfoView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 12
        return view
    }()

    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.circle.fill")
        imageView.tintColor = UIColor(red: 0.07, green: 0.21, blue: 0.36, alpha: 1.0)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.text = "用户"
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .label
        return label
    }()

    private let membershipLabel: UILabel = {
        let label = UILabel()
        label.text = "会员状态: 免费版"
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()

    private let topicsSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "课题分类"
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .label
        return label
    }()

    private let topicsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        return stackView
    }()

    private let settingsSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "设置"
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .label
        return label
    }()

    private let settingsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.alignment = .fill
        return stackView
    }()

    private let statsSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "统计信息"
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .label
        return label
    }()

    private let statsView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 12
        return view
    }()

    private let usageTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "使用时长: 0小时"
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = .label
        return label
    }()

    private let researchCountLabel: UILabel = {
        let label = UILabel()
        label.text = "研究完成: 0个"
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = .label
        return label
    }()

    private let materialCountLabel: UILabel = {
        let label = UILabel()
        label.text = "资料保存: 0个"
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = .label
        return label
    }()

    private let deepSeekUsageLabel: UILabel = {
        let label = UILabel()
        label.text = "DeepSeek用量: 0 tokens"
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = .label
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupTopics()
        setupSettings()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(userInfoView)
        contentView.addSubview(topicsSectionLabel)
        contentView.addSubview(topicsStackView)
        contentView.addSubview(settingsSectionLabel)
        contentView.addSubview(settingsStackView)
        contentView.addSubview(statsSectionLabel)
        contentView.addSubview(statsView)

        userInfoView.addSubview(avatarImageView)
        userInfoView.addSubview(userNameLabel)
        userInfoView.addSubview(membershipLabel)

        statsView.addSubview(usageTimeLabel)
        statsView.addSubview(researchCountLabel)
        statsView.addSubview(materialCountLabel)
        statsView.addSubview(deepSeekUsageLabel)
    }

    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }

        userInfoView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(100)
        }

        avatarImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(60)
        }

        userNameLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatarImageView.snp.trailing).offset(16)
            make.top.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-20)
        }

        membershipLabel.snp.makeConstraints { make in
            make.leading.equalTo(userNameLabel)
            make.top.equalTo(userNameLabel.snp.bottom).offset(4)
            make.trailing.equalToSuperview().offset(-20)
        }

        topicsSectionLabel.snp.makeConstraints { make in
            make.top.equalTo(userInfoView.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        topicsStackView.snp.makeConstraints { make in
            make.top.equalTo(topicsSectionLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        settingsSectionLabel.snp.makeConstraints { make in
            make.top.equalTo(topicsStackView.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        settingsStackView.snp.makeConstraints { make in
            make.top.equalTo(settingsSectionLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        statsSectionLabel.snp.makeConstraints { make in
            make.top.equalTo(settingsStackView.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        statsView.snp.makeConstraints { make in
            make.top.equalTo(statsSectionLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(140)
            make.bottom.equalToSuperview().offset(-20)
        }

        usageTimeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        researchCountLabel.snp.makeConstraints { make in
            make.top.equalTo(usageTimeLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        materialCountLabel.snp.makeConstraints { make in
            make.top.equalTo(researchCountLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        deepSeekUsageLabel.snp.makeConstraints { make in
            make.top.equalTo(materialCountLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }

    private func setupTopics() {
        let adlerTopics = ["生活", "工作", "友情", "爱情"]
        let adlerView = createTopicView(title: "阿德勒课题", topics: adlerTopics)
        topicsStackView.addArrangedSubview(adlerView)

        let lifeTopics = ["财务自由计划", "长期技能", "长期爱好", "人生意义", "幸福感", "周末去哪儿"]
        let lifeView = createTopicView(title: "现实人生课题", topics: lifeTopics)
        topicsStackView.addArrangedSubview(lifeView)

        let investmentTopics = ["投资风格", "核心目的", "预期收益", "操作Action"]
        let investmentView = createTopicView(title: "投资的课题", topics: investmentTopics)
        topicsStackView.addArrangedSubview(investmentView)
    }

    private func createTopicView(title: String, topics: [String]) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .tertiarySystemBackground
        containerView.layer.cornerRadius = 8

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .label

        let topicsLabel = UILabel()
        topicsLabel.text = topics.joined(separator: " · ")
        topicsLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        topicsLabel.textColor = .secondaryLabel
        topicsLabel.numberOfLines = 0

        containerView.addSubview(titleLabel)
        containerView.addSubview(topicsLabel)

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.trailing.equalToSuperview().inset(12)
        }

        topicsLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().offset(-12)
        }

        return containerView
    }

    private func setupSettings() {
        let settings = [
            ("DeepSeek API设置", "key.fill"),
            ("账号设置", "person.fill"),
            ("通知设置", "bell.fill"),
            ("主题设置", "paintbrush.fill"),
            ("数据备份", "externaldrive.fill"),
            ("帮助与反馈", "questionmark.circle.fill"),
            ("关于FORME", "info.circle.fill")
        ]

        for (index, setting) in settings.enumerated() {
            let settingView = createSettingView(title: setting.0, iconName: setting.1, isLast: index == settings.count - 1)
            settingsStackView.addArrangedSubview(settingView)
        }
    }

    private func createSettingView(title: String, iconName: String, isLast: Bool) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .secondarySystemBackground
        containerView.isUserInteractionEnabled = true

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(settingTapped(_:)))
        containerView.addGestureRecognizer(tapGesture)

        let iconImageView = UIImageView()
        iconImageView.image = UIImage(systemName: iconName)
        iconImageView.tintColor = UIColor(red: 0.07, green: 0.21, blue: 0.36, alpha: 1.0)
        iconImageView.contentMode = .scaleAspectFit

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        titleLabel.textColor = .label

        let arrowImageView = UIImageView()
        arrowImageView.image = UIImage(systemName: "chevron.right")
        arrowImageView.tintColor = .tertiaryLabel
        arrowImageView.contentMode = .scaleAspectFit

        let separator = UIView()
        separator.backgroundColor = .separator
        separator.isHidden = isLast

        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(arrowImageView)
        containerView.addSubview(separator)

        iconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(12)
            make.centerY.equalToSuperview()
            make.trailing.equalTo(arrowImageView.snp.leading).offset(-8)
        }

        arrowImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(16)
        }

        separator.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }

        containerView.snp.makeConstraints { make in
            make.height.equalTo(50)
        }

        // 存储设置类型信息
        containerView.accessibilityIdentifier = title

        return containerView
    }

    @objc private func settingTapped(_ gesture: UITapGestureRecognizer) {
        guard let settingView = gesture.view,
              let settingTitle = settingView.accessibilityIdentifier else { return }

        if settingTitle == "DeepSeek API设置" {
            let deepSeekSettingsVC = DeepSeekSettingsViewController()
            navigationController?.pushViewController(deepSeekSettingsVC, animated: true)
        } else {
            let alert = UIAlertController(title: settingTitle, message: "功能开发中", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确定", style: .default))
            present(alert, animated: true)
        }
    }
}