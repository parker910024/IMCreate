//
//  IMFunctionPanel.swift
//  IMCreate
//
//  Created by mac密码1234 on 2025/11/25.
//

import UIKit

struct IMFunctionItem {
    let title: String
    let icon: UIImage?
}

protocol IMFunctionPanelDelegate: AnyObject {
    func functionPanelDidSelectItem(_ item: IMFunctionItem)
}

class IMFunctionPanel: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    weak var delegate: IMFunctionPanelDelegate?

    private let items: [IMFunctionItem] = [
        IMFunctionItem(title: "相册", icon: UIImage(systemName: "photo")),
        IMFunctionItem(title: "拍摄", icon: UIImage(systemName: "camera")),
        IMFunctionItem(title: "短视频", icon: UIImage(systemName: "video")),
        IMFunctionItem(title: "文件", icon: UIImage(systemName: "folder")),
        IMFunctionItem(title: "红包", icon: UIImage(systemName: "envelope")),
        IMFunctionItem(title: "设备", icon: UIImage(systemName: "iphone")),
        IMFunctionItem(title: "名片", icon: UIImage(systemName: "person")),
        IMFunctionItem(title: "小程序", icon: UIImage(systemName: "sparkles"))
    ]
    private let collectionView: UICollectionView

    override init(frame: CGRect) {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 64, height: 80)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.sectionInset = .zero
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 64, height: 80)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.sectionInset = .zero
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        backgroundColor = UIColor(hex: "#F7F7F7")
        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            collectionView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
            collectionView.rightAnchor.constraint(equalTo: rightAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(FunctionPanelCell.self, forCellWithReuseIdentifier: "FunctionPanelCell")
        collectionView.isScrollEnabled = false
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FunctionPanelCell", for: indexPath) as! FunctionPanelCell
        cell.configure(with: items[indexPath.item])
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width) / 4
        let height = (collectionView.bounds.height) / 2
        return CGSize(width: width, height: height)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[indexPath.item]
        delegate?.functionPanelDidSelectItem(item)
    }
}

class FunctionPanelCell: UICollectionViewCell {
    private let iconView = UIImageView()
    private let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        iconView.contentMode = .scaleAspectFit
        titleLabel.font = .systemFont(ofSize: 14)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .darkGray

        contentView.addSubview(iconView)
        contentView.addSubview(titleLabel)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            iconView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            iconView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            iconView.widthAnchor.constraint(equalToConstant: 32),
            iconView.heightAnchor.constraint(equalToConstant: 32),
            titleLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 8),
            titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            titleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor)
        ])
    }

    func configure(with item: IMFunctionItem) {
        iconView.image = item.icon
        titleLabel.text = item.title
    }
}
