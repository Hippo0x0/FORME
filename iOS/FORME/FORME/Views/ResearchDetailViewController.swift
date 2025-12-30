import UIKit
import SnapKit

class ResearchDetailViewController: UIViewController {

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

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()

    private let statusView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 8
        return view
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textColor = .label
        label.text = "状态: 进行中"
        return label
    }()

    private let workflowTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "5步工作流"
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .label
        return label
    }()

    private let workflowStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .fill
        return stackView
    }()

    private let materialsTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "关联资料"
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .label
        return label
    }()

    private let materialsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .fill
        return stackView
    }()

    private let addMaterialButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("添加资料", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        button.setTitleColor(UIColor(red: 0.07, green: 0.21, blue: 0.36, alpha: 1.0), for: .normal)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupWorkflowSteps()
        setupActions()
        setupKeyboardDismissal()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(statusView)
        contentView.addSubview(workflowTitleLabel)
        contentView.addSubview(workflowStackView)
        contentView.addSubview(materialsTitleLabel)
        contentView.addSubview(materialsStackView)
        contentView.addSubview(addMaterialButton)

        statusView.addSubview(statusLabel)

        // 临时数据
        titleLabel.text = navigationItem.title ?? "研究详情"
        descriptionLabel.text = "这是一个研究项目的详细描述，包含研究目标、方法和预期成果。"
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

        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        statusView.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }

        statusLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(16)
        }

        workflowTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(statusView.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        workflowStackView.snp.makeConstraints { make in
            make.top.equalTo(workflowTitleLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        materialsTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(workflowStackView.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        materialsStackView.snp.makeConstraints { make in
            make.top.equalTo(materialsTitleLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        addMaterialButton.snp.makeConstraints { make in
            make.top.equalTo(materialsStackView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().offset(-20)
        }
    }

    private func setupWorkflowSteps() {
        let steps = [
            ("1. Boost", "激发研究兴趣"),
            ("2. Pick Target", "选择研究目标"),
            ("3. Schedule", "制定研究计划"),
            ("4. Work-Feedback-Loop", "工作反馈循环"),
            ("5. Output-Feedback-Loop", "输出反馈循环")
        ]

        for (index, step) in steps.enumerated() {
            let stepView = createStepView(number: index + 1, title: step.0, description: step.1)
            workflowStackView.addArrangedSubview(stepView)
        }
    }

    private func createStepView(number: Int, title: String, description: String) -> UIView {
        let containerView = UIView()

        let numberLabel = UILabel()
        numberLabel.text = "\(number)"
        numberLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        numberLabel.textColor = .white
        numberLabel.textAlignment = .center
        numberLabel.backgroundColor = UIColor(red: 0.07, green: 0.21, blue: 0.36, alpha: 1.0)
        numberLabel.layer.cornerRadius = 12
        numberLabel.clipsToBounds = true

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .label

        let descLabel = UILabel()
        descLabel.text = description
        descLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        descLabel.textColor = .secondaryLabel
        descLabel.numberOfLines = 0

        containerView.addSubview(numberLabel)
        containerView.addSubview(titleLabel)
        containerView.addSubview(descLabel)

        numberLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
            make.width.height.equalTo(24)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(numberLabel.snp.trailing).offset(12)
            make.top.equalToSuperview()
            make.trailing.equalToSuperview()
        }

        descLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        return containerView
    }

    private func setupActions() {
        addMaterialButton.addTarget(self, action: #selector(addMaterialButtonTapped), for: .touchUpInside)
    }

    @objc private func addMaterialButtonTapped() {
        let alert = UIAlertController(title: "添加资料", message: "请选择添加方式", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "从网页保存", style: .default) { _ in
            self.showSaveFromWebAlert()
        })
        alert.addAction(UIAlertAction(title: "上传文件", style: .default) { _ in
            self.showUploadFileAlert()
        })
        alert.addAction(UIAlertAction(title: "手动输入", style: .default) { _ in
            self.showManualInputAlert()
        })
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(alert, animated: true)
    }

    private func showSaveFromWebAlert() {
        let alert = UIAlertController(title: "从网页保存", message: "请输入网页URL", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "https://example.com"
            textField.keyboardType = .URL
        }
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "保存", style: .default) { _ in
            // TODO: 实现网页保存逻辑
        })
        present(alert, animated: true)
    }

    private func showUploadFileAlert() {
        // TODO: 实现文件上传
    }

    private func showManualInputAlert() {
        let alert = UIAlertController(title: "手动输入", message: "请输入资料内容", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "资料标题"
        }
        alert.addTextField { textField in
            textField.placeholder = "资料内容"
        }
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "保存", style: .default) { _ in
            // TODO: 实现手动输入保存逻辑
        })
        present(alert, animated: true)
    }
  

}
