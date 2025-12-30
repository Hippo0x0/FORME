import UIKit
import SnapKit

class MaterialDetailViewController: UIViewController {

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

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()

    private let typeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }()

    private let urlLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = .systemBlue
        label.numberOfLines = 0
        label.isUserInteractionEnabled = true
        return label
    }()

    private let saveTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .tertiaryLabel
        return label
    }()

    private let tagsTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "标签"
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        return label
    }()

    private let tagsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .leading
        stackView.distribution = .fill
        return stackView
    }()

    private let addTagButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("添加标签", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.setTitleColor(UIColor(red: 0.07, green: 0.21, blue: 0.36, alpha: 1.0), for: .normal)
        return button
    }()

    private let annotationsTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "标注"
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        return label
    }()

    private let annotationsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .fill
        return stackView
    }()

    private let addAnnotationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("添加标注", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.setTitleColor(UIColor(red: 0.07, green: 0.21, blue: 0.36, alpha: 1.0), for: .normal)
        return button
    }()

    private let relatedResearchTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "关联研究"
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        return label
    }()

    private let relatedResearchStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .fill
        return stackView
    }()

    private let linkResearchButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("关联到研究", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.setTitleColor(UIColor(red: 0.07, green: 0.21, blue: 0.36, alpha: 1.0), for: .normal)
        return button
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
        setupSampleData()
        setupKeyboardDismissal()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(titleLabel)
        contentView.addSubview(typeLabel)
        contentView.addSubview(urlLabel)
        contentView.addSubview(saveTimeLabel)
        contentView.addSubview(tagsTitleLabel)
        contentView.addSubview(tagsStackView)
        contentView.addSubview(addTagButton)
        contentView.addSubview(annotationsTitleLabel)
        contentView.addSubview(annotationsStackView)
        contentView.addSubview(addAnnotationButton)
        contentView.addSubview(relatedResearchTitleLabel)
        contentView.addSubview(relatedResearchStackView)
        contentView.addSubview(linkResearchButton)
        contentView.addSubview(actionButtonsStackView)

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

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        typeLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        urlLabel.snp.makeConstraints { make in
            make.top.equalTo(typeLabel.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        saveTimeLabel.snp.makeConstraints { make in
            make.top.equalTo(urlLabel.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        tagsTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(saveTimeLabel.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        tagsStackView.snp.makeConstraints { make in
            make.top.equalTo(tagsTitleLabel.snp.bottom).offset(12)
            make.leading.equalToSuperview().inset(20)
            make.trailing.lessThanOrEqualToSuperview().inset(20)
        }

        addTagButton.snp.makeConstraints { make in
            make.top.equalTo(tagsStackView.snp.bottom).offset(12)
            make.leading.equalToSuperview().inset(20)
        }

        annotationsTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(addTagButton.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        annotationsStackView.snp.makeConstraints { make in
            make.top.equalTo(annotationsTitleLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        addAnnotationButton.snp.makeConstraints { make in
            make.top.equalTo(annotationsStackView.snp.bottom).offset(12)
            make.leading.equalToSuperview().inset(20)
        }

        relatedResearchTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(addAnnotationButton.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        relatedResearchStackView.snp.makeConstraints { make in
            make.top.equalTo(relatedResearchTitleLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        linkResearchButton.snp.makeConstraints { make in
            make.top.equalTo(relatedResearchStackView.snp.bottom).offset(12)
            make.leading.equalToSuperview().inset(20)
        }

        actionButtonsStackView.snp.makeConstraints { make in
            make.top.equalTo(linkResearchButton.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().offset(-20)
        }
    }

    private func setupActionButtons() {
        let buttons = [
            ("重新解析", "arrow.clockwise"),
            ("导出", "square.and.arrow.up"),
            ("删除", "trash")
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

        // 存储按钮类型信息
        button.accessibilityIdentifier = title

        return button
    }

    private func setupActions() {
        addTagButton.addTarget(self, action: #selector(addTagButtonTapped), for: .touchUpInside)
        addAnnotationButton.addTarget(self, action: #selector(addAnnotationButtonTapped), for: .touchUpInside)
        linkResearchButton.addTarget(self, action: #selector(linkResearchButtonTapped), for: .touchUpInside)

        let urlTapGesture = UITapGestureRecognizer(target: self, action: #selector(urlLabelTapped))
        urlLabel.addGestureRecognizer(urlTapGesture)
    }

    private func setupSampleData() {
        titleLabel.text = navigationItem.title ?? "资料详情"
        typeLabel.text = "类型: 网页"
        urlLabel.text = "URL: https://example.com/article"
        saveTimeLabel.text = "保存时间: 2025-12-29"

        // 添加示例标签
        let sampleTags = ["AI", "研究", "技术"]
        for tag in sampleTags {
            let tagView = createTagView(text: tag)
            tagsStackView.addArrangedSubview(tagView)
        }

        // 添加示例标注
        let sampleAnnotations = [
            "重要观点: AI将改变未来工作方式",
            "关键数据: 到2030年，AI将创造2000万个新工作岗位"
        ]
        for annotation in sampleAnnotations {
            let annotationView = createAnnotationView(text: annotation)
            annotationsStackView.addArrangedSubview(annotationView)
        }

        // 添加示例关联研究
        let sampleResearch = ["AI研究项目", "技术趋势分析"]
        for research in sampleResearch {
            let researchView = createResearchView(text: research)
            relatedResearchStackView.addArrangedSubview(researchView)
        }
    }

    private func createTagView(text: String) -> UIView {
        let tagView = UIView()
        tagView.backgroundColor = UIColor(red: 0.07, green: 0.21, blue: 0.36, alpha: 0.1)
        tagView.layer.cornerRadius = 4

        let tagLabel = UILabel()
        tagLabel.text = "#\(text)"
        tagLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        tagLabel.textColor = UIColor(red: 0.07, green: 0.21, blue: 0.36, alpha: 1.0)

        tagView.addSubview(tagLabel)

        tagLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(8)
            make.top.bottom.equalToSuperview().inset(4)
        }

        return tagView
    }

    private func createAnnotationView(text: String) -> UIView {
        let annotationView = UIView()
        annotationView.backgroundColor = .tertiarySystemBackground
        annotationView.layer.cornerRadius = 8

        let annotationLabel = UILabel()
        annotationLabel.text = text
        annotationLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        annotationLabel.textColor = .label
        annotationLabel.numberOfLines = 0

        annotationView.addSubview(annotationLabel)

        annotationLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }

        return annotationView
    }

    private func createResearchView(text: String) -> UIView {
        let researchView = UIView()
        researchView.backgroundColor = .secondarySystemBackground
        researchView.layer.cornerRadius = 8

        let researchLabel = UILabel()
        researchLabel.text = text
        researchLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        researchLabel.textColor = .label

        researchView.addSubview(researchLabel)

        researchLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }

        return researchView
    }

    @objc private func actionButtonTapped(_ sender: UIButton) {
        guard let action = sender.accessibilityIdentifier else { return }

        switch action {
        case "重新解析":
            showAlert(title: "重新解析", message: "将重新解析网页内容")
        case "导出":
            showAlert(title: "导出", message: "将导出资料内容")
        case "删除":
            showDeleteConfirmation()
        default:
            break
        }
    }

    @objc private func addTagButtonTapped() {
        let alert = UIAlertController(title: "添加标签", message: "请输入标签名称", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "标签名称"
        }
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "添加", style: .default) { [weak self] _ in
            guard let tag = alert.textFields?.first?.text, !tag.isEmpty else { return }
            let tagView = self?.createTagView(text: tag)
            self?.tagsStackView.addArrangedSubview(tagView!)
        })
        present(alert, animated: true)
    }

    @objc private func addAnnotationButtonTapped() {
        let alert = UIAlertController(title: "添加标注", message: "请输入标注内容", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "标注内容"
        }
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "添加", style: .default) { [weak self] _ in
            guard let annotation = alert.textFields?.first?.text, !annotation.isEmpty else { return }
            let annotationView = self?.createAnnotationView(text: annotation)
            self?.annotationsStackView.addArrangedSubview(annotationView!)
        })
        present(alert, animated: true)
    }

    @objc private func linkResearchButtonTapped() {
        let alert = UIAlertController(title: "关联到研究", message: "请选择要关联的研究", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "AI研究项目", style: .default) { _ in
            // TODO: 实现关联逻辑
        })
        alert.addAction(UIAlertAction(title: "技术趋势分析", style: .default) { _ in
            // TODO: 实现关联逻辑
        })
        alert.addAction(UIAlertAction(title: "新建研究", style: .default) { _ in
            self.createNewResearchForLink()
        })
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(alert, animated: true)
    }

    @objc private func urlLabelTapped() {
        guard let urlText = urlLabel.text?.replacingOccurrences(of: "URL: ", with: ""),
              let url = URL(string: urlText) else {
            return
        }

        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    private func createNewResearchForLink() {
        let alert = UIAlertController(title: "新建研究", message: "请输入研究标题", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "研究标题"
        }
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "创建", style: .default) { _ in
            guard let title = alert.textFields?.first?.text, !title.isEmpty else { return }
            // TODO: 实现创建研究并关联逻辑
            self.showAlert(title: "创建成功", message: "已创建研究: \(title)")
        })
        present(alert, animated: true)
    }

    private func showDeleteConfirmation() {
        let alert = UIAlertController(title: "删除资料", message: "确定要删除这个资料吗？此操作不可撤销。", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "删除", style: .destructive) { _ in
            self.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
  

}
