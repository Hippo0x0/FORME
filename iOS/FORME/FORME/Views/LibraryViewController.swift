import UIKit
import SnapKit

class LibraryViewController: UIViewController {

    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "搜索资料..."
        searchBar.searchBarStyle = .minimal
        return searchBar
    }()

    private let segmentedControl: UISegmentedControl = {
        let items = ["全部", "网页", "文档", "图片"]
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.selectedSegmentIndex = 0
        return segmentedControl
    }()

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(MaterialCell.self, forCellWithReuseIdentifier: "MaterialCell")
        collectionView.backgroundColor = .systemBackground
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()

    private let emptyStateView: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()

    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "暂无资料\n保存第一个资料开始研究"
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private var materials: [String] = [
        "网页: 阿德勒心理学入门指南",
        "网页: 财务自由：被动收入的7种方式",
        "文档: 投资基础知识手册",
        "图片: 人生规划思维导图",
        "网页: AI时代必备技能清单",
        "文档: 积极心理学实践方法",
        "图片: 投资组合管理图表",
        "网页: 长期主义：如何坚持长期目标",
        "文档: 情绪调节技巧手册",
        "图片: 幸福感提升可视化数据"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupNavigationBar()
        updateEmptyState()
        setupKeyboardDismissal()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationItem.title = "资料库"

        view.addSubview(searchBar)
        view.addSubview(segmentedControl)
        view.addSubview(collectionView)
        view.addSubview(emptyStateView)
        emptyStateView.addSubview(emptyStateLabel)

        collectionView.delegate = self
        collectionView.dataSource = self

        searchBar.delegate = self
        segmentedControl.addTarget(self, action: #selector(segmentedControlChanged), for: .valueChanged)
    }

    private func setupConstraints() {
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
        }

        segmentedControl.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(32)
        }

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom).offset(12)
            make.leading.trailing.bottom.equalToSuperview()
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
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonTapped)
        )
        navigationItem.rightBarButtonItem = addButton
    }

    private func updateEmptyState() {
        emptyStateView.isHidden = !materials.isEmpty
        collectionView.isHidden = materials.isEmpty
    }

    @objc private func segmentedControlChanged() {
        // TODO: 根据分段控制筛选资料
        collectionView.reloadData()
    }

    @objc private func addButtonTapped() {
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
            guard let url = alert.textFields?.first?.text, !url.isEmpty else { return }
            self.addMaterial(title: "网页资料", type: "网页")
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
            guard let title = alert.textFields?.first?.text, !title.isEmpty else { return }
            self.addMaterial(title: title, type: "笔记")
        })
        present(alert, animated: true)
    }

    private func addMaterial(title: String, type: String) {
        materials.append("\(type): \(title)")
        collectionView.reloadData()
        updateEmptyState()
    }
  

}

extension LibraryViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return materials.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MaterialCell", for: indexPath) as! MaterialCell
        cell.configure(with: materials[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 36) / 2
        return CGSize(width: width, height: width * 1.2)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let materialTitle = materials[indexPath.item]
        let detailVC = MaterialDetailViewController()
        detailVC.title = materialTitle
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension LibraryViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // TODO: 实现搜索功能
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

class MaterialCell: UICollectionViewCell {
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor(red: 0.07, green: 0.21, blue: 0.36, alpha: 1.0)
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .label
        label.numberOfLines = 2
        label.textAlignment = .center
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
        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
    }

    private func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        iconImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(20)
            make.width.height.equalTo(40)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(12)
            make.bottom.lessThanOrEqualToSuperview().offset(-12)
        }
    }

    func configure(with title: String) {
        titleLabel.text = title

        if title.hasPrefix("网页") {
            iconImageView.image = UIImage(systemName: "globe")
        } else if title.hasPrefix("文档") {
            iconImageView.image = UIImage(systemName: "doc.text")
        } else if title.hasPrefix("图片") {
            iconImageView.image = UIImage(systemName: "photo")
        } else {
            iconImageView.image = UIImage(systemName: "note.text")
        }
    }
}
