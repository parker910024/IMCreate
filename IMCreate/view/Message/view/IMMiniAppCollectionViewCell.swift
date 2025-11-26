//
//  IMMiniAppCollectionViewCell.swift
//  IMCreate
//
//  Created by admin on 2025/11/24.
//

import UIKit

class IMMiniAppCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "IMMiniAppCollectionViewCell"

    private let iconView: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 6
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 10)
        l.textAlignment = .center
        l.numberOfLines = 2
        l.textColor = UIColor(hex: "#333333")
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(iconView)
        contentView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            iconView.topAnchor.constraint(equalTo: contentView.topAnchor),
            iconView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 46),
            iconView.heightAnchor.constraint(equalToConstant: 46),

            titleLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 7),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -2)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(with model: IMMiniApp) {
        iconView.backgroundColor = model.color
        titleLabel.text = model.name
    }
}
