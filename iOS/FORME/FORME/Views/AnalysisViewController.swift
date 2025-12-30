import UIKit
import SnapKit

class AnalysisViewController: UIViewController {

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

    private let deepSeekSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "DeepSeek分析"
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .label
        return label
    }()

    private let deepSeekStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        return stackView
    }()

    private let localSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "本地分析模型"
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .label
        return label
    }()

    private let localStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        return stackView
    }()

    private let apiStatusView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 12
        return view
    }()

    private let apiStatusLabel: UILabel = {
        let label = UILabel()
        label.text = "DeepSeek: 未连接"
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textColor = .label
        return label
    }()

    private let apiUsageLabel: UILabel = {
        let label = UILabel()
        label.text = "本月用量: 0/1000 tokens"
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupAnalysisCards()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationItem.title = "分析中心"

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(deepSeekSectionLabel)
        contentView.addSubview(deepSeekStackView)
        contentView.addSubview(localSectionLabel)
        contentView.addSubview(localStackView)
        contentView.addSubview(apiStatusView)

        apiStatusView.addSubview(apiStatusLabel)
        apiStatusView.addSubview(apiUsageLabel)
    }

    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }

        deepSeekSectionLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        deepSeekStackView.snp.makeConstraints { make in
            make.top.equalTo(deepSeekSectionLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        localSectionLabel.snp.makeConstraints { make in
            make.top.equalTo(deepSeekStackView.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        localStackView.snp.makeConstraints { make in
            make.top.equalTo(localSectionLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        apiStatusView.snp.makeConstraints { make in
            make.top.equalTo(localStackView.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(80)
            make.bottom.equalToSuperview().offset(-20)
        }

        apiStatusLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        apiUsageLabel.snp.makeConstraints { make in
            make.top.equalTo(apiStatusLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }

    private func setupAnalysisCards() {
        let deepSeekCards = [
            ("深度理解", "使用DeepSeek深度分析资料", "brain.head.profile"),
            ("智能问答", "基于资料回答研究问题", "questionmark.bubble"),
            ("关联发现", "发现资料间隐藏关联", "link")
        ]

        for card in deepSeekCards {
            let cardView = createAnalysisCard(title: card.0, description: card.1, iconName: card.2, isDeepSeek: true)
            deepSeekStackView.addArrangedSubview(cardView)
        }

        let localCards = [
            ("文本摘要", "自动生成内容摘要", "text.alignleft"),
            ("趋势分析", "识别时间趋势", "chart.line.uptrend.xyaxis")
        ]

        for card in localCards {
            let cardView = createAnalysisCard(title: card.0, description: card.1, iconName: card.2, isDeepSeek: false)
            localStackView.addArrangedSubview(cardView)
        }
    }

    private func createAnalysisCard(title: String, description: String, iconName: String, isDeepSeek: Bool) -> UIView {
        let cardView = UIView()
        cardView.backgroundColor = .secondarySystemBackground
        cardView.layer.cornerRadius = 12
        cardView.isUserInteractionEnabled = true

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(analysisCardTapped(_:)))
        cardView.addGestureRecognizer(tapGesture)

        let iconImageView = UIImageView()
        iconImageView.image = UIImage(systemName: iconName)
        iconImageView.tintColor = isDeepSeek ? UIColor(red: 0.0, green: 0.71, blue: 0.68, alpha: 1.0) : UIColor(red: 0.07, green: 0.21, blue: 0.36, alpha: 1.0)
        iconImageView.contentMode = .scaleAspectFit

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = .label

        let descLabel = UILabel()
        descLabel.text = description
        descLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        descLabel.textColor = .secondaryLabel
        descLabel.numberOfLines = 0

        let arrowImageView = UIImageView()
        arrowImageView.image = UIImage(systemName: "chevron.right")
        arrowImageView.tintColor = .tertiaryLabel
        arrowImageView.contentMode = .scaleAspectFit

        cardView.addSubview(iconImageView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(descLabel)
        cardView.addSubview(arrowImageView)

        iconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(12)
            make.top.equalToSuperview().offset(16)
            make.trailing.equalTo(arrowImageView.snp.leading).offset(-8)
        }

        descLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.trailing.equalTo(arrowImageView.snp.leading).offset(-8)
            make.bottom.equalToSuperview().offset(-16)
        }

        arrowImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(16)
        }

        // 存储分析类型信息
        cardView.accessibilityIdentifier = title

        return cardView
    }

    @objc private func analysisCardTapped(_ gesture: UITapGestureRecognizer) {
        guard let cardView = gesture.view,
              let analysisType = cardView.accessibilityIdentifier else { return }

        let analysisRunVC = AnalysisRunViewController()
        analysisRunVC.analysisType = analysisType
        analysisRunVC.isDeepSeek = cardView.superview == deepSeekStackView
        navigationController?.pushViewController(analysisRunVC, animated: true)
    }
}