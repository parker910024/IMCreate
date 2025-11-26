//
//  IMChatNavBar.swift
//  IMCreate
//
//  Created by mac密码1234 on 2025/11/25.
//

import UIKit

class IMChatNavBar: UIView {
    private let backButton = UIButton(type: .system)
    private let avatarView = UIImageView()
    private let nameLabel = UILabel()
    private let moreButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        backgroundColor = .white

        backButton.setTitle("←", for: .normal)
        moreButton.setTitle("⋯", for: .normal)
        avatarView.layer.cornerRadius = 16
        avatarView.clipsToBounds = true
        avatarView.backgroundColor = .systemGray4
        nameLabel.font = .boldSystemFont(ofSize: 17)
        nameLabel.text = "昵称"

        addSubview(backButton)
        addSubview(avatarView)
        addSubview(nameLabel)
        addSubview(moreButton)

        backButton.translatesAutoresizingMaskIntoConstraints = false
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        moreButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            backButton.leftAnchor.constraint(equalTo: leftAnchor, constant: 8),
            backButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 32),
            backButton.heightAnchor.constraint(equalToConstant: 32),

            avatarView.leftAnchor.constraint(equalTo: backButton.rightAnchor, constant: 8),
            avatarView.centerYAnchor.constraint(equalTo: centerYAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 32),
            avatarView.heightAnchor.constraint(equalToConstant: 32),

            nameLabel.leftAnchor.constraint(equalTo: avatarView.rightAnchor, constant: 8),
            nameLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            moreButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -8),
            moreButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            moreButton.widthAnchor.constraint(equalToConstant: 32),
            moreButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
}
