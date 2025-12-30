import UIKit
import SnapKit

struct ResearchCategory {
    let title: String
    var researches: [String]
    var isExpanded: Bool

    init(title: String, researches: [String]) {
        self.title = title
        self.researches = researches
        self.isExpanded = true
    }
}

class ResearchViewController: UIViewController {

    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "搜索研究..."
        searchBar.searchBarStyle = .minimal
        return searchBar
    }()

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(ResearchCategoryCell.self, forCellWithReuseIdentifier: "ResearchCategoryCell")
        collectionView.register(ResearchItemCell.self, forCellWithReuseIdentifier: "ResearchItemCell")
        collectionView.backgroundColor = .systemBackground
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()

    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        button.tintColor = UIColor(red: 0.07, green: 0.21, blue: 0.36, alpha: 1.0)
        button.backgroundColor = .systemBackground
        button.layer.cornerRadius = 28
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.1
        return button
    }()

    private let emptyStateView: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()

    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "暂无研究\n点击右下角 + 创建第一个研究"
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private var categories: [ResearchCategory] = [
        ResearchCategory(title: "心理学研究", researches: [
            "阿德勒心理学：生活、工作、友情、爱情",
            "认知行为疗法：情绪调节策略",
            "积极心理学：幸福感提升方法"
        ]),
        ResearchCategory(title: "人生规划", researches: [
            "财务自由计划：被动收入策略",
            "长期技能：AI时代核心竞争力",
            "人生意义：价值观探索与实现"
        ]),
        ResearchCategory(title: "投资研究", researches: [
            "投资风格：价值投资 vs 成长投资",
            "核心目的：财富保值与增值",
            "预期收益：理性预期与风险管理"
        ])
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupNavigationBar()
        setupKeyboardDismissal()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationItem.title = "研究"

        view.addSubview(searchBar)
        view.addSubview(collectionView)
        view.addSubview(addButton)
        view.addSubview(emptyStateView)
        emptyStateView.addSubview(emptyStateLabel)

        collectionView.delegate = self
        collectionView.dataSource = self
        searchBar.delegate = self

        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)

        updateEmptyState()
    }

    private func setupConstraints() {
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
        }

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }

        addButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.width.height.equalTo(56)
        }

        emptyStateView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(40)
        }

        emptyStateLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setupNavigationBar() {
        // 搜索按钮已经在searchBar中，不需要额外的导航栏按钮
    }

    private func updateEmptyState() {
        let hasResearch = categories.contains { !$0.researches.isEmpty }
        emptyStateView.isHidden = hasResearch
        collectionView.isHidden = !hasResearch
    }

    @objc private func addButtonTapped() {
        let alert = UIAlertController(title: "新建研究", message: "请输入研究标题", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "研究标题"
        }
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "创建", style: .default) { [weak self] _ in
            guard let title = alert.textFields?.first?.text, !title.isEmpty else { return }
            self?.addResearch(title: title)
        })
        present(alert, animated: true)
    }

    private func addResearch(title: String) {
        // 默认添加到第一个分类
        if categories.isEmpty {
            categories.append(ResearchCategory(title: "我的研究", researches: [title]))
        } else {
            categories[0].researches.insert(title, at: 0)
        }
        collectionView.reloadData()
        updateEmptyState()
    }

    private func toggleCategory(at index: Int) {
        categories[index].isExpanded.toggle()
        collectionView.reloadData()
    }
  

}

extension ResearchViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return categories.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let category = categories[section]
        return category.isExpanded ? category.researches.count + 1 : 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let category = categories[indexPath.section]

        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ResearchCategoryCell", for: indexPath) as! ResearchCategoryCell
            cell.configure(with: category.title, isExpanded: category.isExpanded)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ResearchItemCell", for: indexPath) as! ResearchItemCell
            let research = category.researches[indexPath.item - 1]
            cell.configure(with: research)
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width - 24

        if indexPath.item == 0 {
            return CGSize(width: width, height: 60)
        } else {
            return CGSize(width: width, height: 80)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)

        if indexPath.item == 0 {
            toggleCategory(at: indexPath.section)
        } else {
            let category = categories[indexPath.section]
            let researchTitle = category.researches[indexPath.item - 1]
            let detailVC = ResearchDetailViewController()
            detailVC.title = researchTitle
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
}

extension ResearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // TODO: 实现搜索功能
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

class ResearchCategoryCell: UICollectionViewCell {
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        return label
    }()

    private let expandButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = UIColor(red: 0.07, green: 0.21, blue: 0.36, alpha: 1.0)
        return button
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
        containerView.addSubview(expandButton)
    }

    private func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
        }

        expandButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-16)
            make.width.height.equalTo(24)
        }
    }

    func configure(with title: String, isExpanded: Bool) {
        titleLabel.text = title
        let imageName = isExpanded ? "chevron.down" : "chevron.right"
        expandButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
}

class ResearchItemCell: UICollectionViewCell {
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.secondarySystemBackground.cgColor
        view.layer.masksToBounds = true
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        label.numberOfLines = 2
        return label
    }()

    private let arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = .secondaryLabel
        imageView.contentMode = .scaleAspectFit
        return imageView
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
        containerView.addSubview(arrowImageView)
    }

    private func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(4)
        }

        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(arrowImageView.snp.leading).offset(-12)
        }

        arrowImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-16)
            make.width.height.equalTo(16)
        }
    }

    func configure(with title: String) {
        titleLabel.text = title
    }
  
}
