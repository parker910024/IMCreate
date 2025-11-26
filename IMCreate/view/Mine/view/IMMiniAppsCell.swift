//
//  IMMiniAppsCell.swift
//  IMCreate
//
//  Created by admin on 2025/11/25.
//

import UIKit

final class IMMiniAppsCell: UITableViewCell {
    static let reuseIdentifier = "IMMiniAppsCell"

    private let collectionView: UICollectionView
    private var items: [(icon: UIImage?, title: String)] = []

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
        layout.itemSize = CGSize(width: 64, height: 84)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not implemented") }

    private func setup() {
        contentView.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(MiniAppItemCell.self, forCellWithReuseIdentifier: MiniAppItemCell.reuseIdentifier)
    }

    func configure(items: [(icon: UIImage?, title: String)]) {
        self.items = items
        collectionView.reloadData()
    }

    // Cell for each mini app
    private final class MiniAppItemCell: UICollectionViewCell {
        static let reuseIdentifier = "MiniAppItemCell"
        private let iconView = UIImageView()
        private let titleLabel = UILabel()

        override init(frame: CGRect) {
            super.init(frame: frame)
            contentView.addSubview(iconView)
            contentView.addSubview(titleLabel)
            iconView.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            iconView.layer.cornerRadius = 10
            iconView.clipsToBounds = true
            iconView.contentMode = .scaleAspectFill
            titleLabel.font = UIFont.systemFont(ofSize: 11)
            titleLabel.textAlignment = .center
            titleLabel.numberOfLines = 2
            NSLayoutConstraint.activate([
                iconView.topAnchor.constraint(equalTo: contentView.topAnchor),
                iconView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                iconView.widthAnchor.constraint(equalToConstant: 56),
                iconView.heightAnchor.constraint(equalToConstant: 56),

                titleLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 6),
                titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor),
                titleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor)
            ])
        }

        required init?(coder: NSCoder) { fatalError("init(coder:) has not implemented") }

        func configure(icon: UIImage?, title: String) {
            iconView.image = icon ?? UIImage(named: "miniDefault")
            titleLabel.text = title
        }
    }
}

extension IMMiniAppsCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { items.count }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IMMiniAppsCell.MiniAppItemCell.reuseIdentifier, for: indexPath) as? IMMiniAppsCell.MiniAppItemCell else {
            return UICollectionViewCell()
        }
        let item = items[indexPath.item]
        cell.configure(icon: item.icon, title: item.title)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 打开小程序逻辑
    }
}
