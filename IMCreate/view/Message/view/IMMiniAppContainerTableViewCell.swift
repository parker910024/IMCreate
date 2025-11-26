//
//  IMMiniAppContainerTableViewCell.swift
//  IMCreate
//
//  Created by admin on 2025/11/24.
//

import UIKit

class IMMiniAppContainerTableViewCell: UITableViewCell {
    static let reuseIdentifier = "IMMiniAppContainerTableViewCell"

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.boldSystemFont(ofSize: 14)
        l.text = "我的小程序"
        l.textColor = UIColor(hex: "#5C5D61")
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let moreLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 14)
        l.textColor = UIColor(hex: "#5C5D61")
        l.text = "查看全部"
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let rightImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "rightGray")
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private var collectionView: UICollectionView!

    private var items: [IMMiniApp] = []

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupCollectionView()
        contentView.addSubview(titleLabel)
        contentView.addSubview(moreLabel)
        contentView.addSubview(rightImageView)
        contentView.addSubview(collectionView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),

            moreLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            moreLabel.trailingAnchor.constraint(equalTo: rightImageView.leadingAnchor, constant: -6),

            rightImageView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            rightImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),
            rightImageView.widthAnchor.constraint(equalToConstant: 7),
            rightImageView.heightAnchor.constraint(equalToConstant: 10),

            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 9),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),
            collectionView.heightAnchor.constraint(equalToConstant: 81),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -9)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 50, height: 81)
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(IMMiniAppCollectionViewCell.self, forCellWithReuseIdentifier: IMMiniAppCollectionViewCell.reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
    }

    func configure(with items: [IMMiniApp]) {
        self.items = items
        collectionView.reloadData()
    }
}

extension IMMiniAppContainerTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { items.count }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IMMiniAppCollectionViewCell.reuseIdentifier, for: indexPath) as! IMMiniAppCollectionViewCell
        cell.configure(with: items[indexPath.item])
        return cell
    }
}
