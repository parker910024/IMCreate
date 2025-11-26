//
//  IMMineHeaderView.swift
//  IMCreate
//
//  Created by admin on 2025/11/25.
//

import UIKit

protocol IMMineHeaderViewDelegate: AnyObject {
    func mineHeaderTappedProfile(_ header: IMMineHeaderView)
    func mineHeaderDidTapEdit(_ header: IMMineHeaderView)
}

final class IMMineHeaderView: UIView {

    weak var delegate: IMMineHeaderViewDelegate?

    private let avatarView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = UIColor(white: 0.9, alpha: 1)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let nameLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        l.textColor = UIColor(red: 0.19, green: 0.19, blue: 0.20, alpha: 1)
        l.numberOfLines = 1
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let idLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 12)
        l.textColor = UIColor(red: 0.67, green: 0.67, blue: 0.67, alpha: 1)
        l.numberOfLines = 1
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let badgeView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let chevron: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .regular)
        let img = UIImage(systemName: "chevron.right", withConfiguration: config)
        let iv = UIImageView(image: img)
        iv.tintColor = UIColor(white: 0.78, alpha: 1)
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    // 复制按钮：14 x 14
    private let copyButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        if let img = UIImage(named: "cpIcon") {
            b.setImage(img.withRenderingMode(.alwaysTemplate), for: .normal)
            b.tintColor = UIColor(white: 0.6, alpha: 1)
        } else {
            b.setTitle("复制", for: .normal)
            b.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        }
        b.accessibilityLabel = "复制ID"
        return b
    }()

    private let preferredHeight: CGFloat = 120

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setup()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not implemented") }

    private func setup() {
        addSubview(avatarView)
        addSubview(nameLabel)
        addSubview(idLabel)
        addSubview(badgeView)
        addSubview(chevron)
        addSubview(copyButton)

        // 高度约束，确保 tableView heightForHeaderInSection 与此一致
        let heightConstraint = heightAnchor.constraint(equalToConstant: preferredHeight)
        heightConstraint.priority = .required
        heightConstraint.isActive = true

        NSLayoutConstraint.activate([
            avatarView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            avatarView.centerYAnchor.constraint(equalTo: centerYAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 52),
            avatarView.heightAnchor.constraint(equalToConstant: 52),

            chevron.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            chevron.centerYAnchor.constraint(equalTo: centerYAnchor),
            chevron.widthAnchor.constraint(equalToConstant: 12),
            chevron.heightAnchor.constraint(equalToConstant: 12),

            nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            nameLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: chevron.leadingAnchor, constant: -8),
            nameLabel.heightAnchor.constraint(equalToConstant: 24),

            badgeView.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 6),
            badgeView.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            badgeView.widthAnchor.constraint(equalToConstant: 51),
            badgeView.heightAnchor.constraint(equalToConstant: 16),

            idLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 1),
            idLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            idLabel.heightAnchor.constraint(equalToConstant: 17),

            copyButton.leadingAnchor.constraint(equalTo: idLabel.trailingAnchor, constant: 5),
            copyButton.centerYAnchor.constraint(equalTo: idLabel.centerYAnchor),
            copyButton.widthAnchor.constraint(equalToConstant: 14),
            copyButton.heightAnchor.constraint(equalToConstant: 14),
            copyButton.trailingAnchor.constraint(lessThanOrEqualTo: chevron.leadingAnchor, constant: -8)
        ])

        idLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        nameLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)

        copyButton.addTarget(self, action: #selector(copyTapped), for: .touchUpInside)

        let tap = UITapGestureRecognizer(target: self, action: #selector(headerTapped))
        addGestureRecognizer(tap)

        isAccessibilityElement = false
        avatarView.isAccessibilityElement = true
        nameLabel.isAccessibilityElement = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        avatarView.layer.cornerRadius = avatarView.bounds.width / 2
    }

    func configure(name: String, id: String, avatarURL: URL?, badgeImage: UIImage?) {
        nameLabel.text = name
        idLabel.text = id
        badgeView.image = badgeImage
        badgeView.isHidden = badgeImage == nil

        if let url = avatarURL {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let data = try? Data(contentsOf: url), let img = UIImage(data: data) else { return }
                DispatchQueue.main.async { self?.avatarView.image = img }
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.avatarView.image = UIImage(named: "defaultAvatar")
            }
        }
    }

    @objc private func headerTapped() {
        delegate?.mineHeaderTappedProfile(self)
    }

    @objc private func copyTapped() {
        let textToCopy = idLabel.text ?? ""
        UIPasteboard.general.string = textToCopy

        // 简单视觉反馈：短暂改变 tintColor
        let originalTint = copyButton.tintColor
        UIView.animate(withDuration: 0.12, animations: {
            self.copyButton.tintColor = UIColor.systemBlue
        }) { _ in
            UIView.animate(withDuration: 0.12, delay: 0.2, options: [], animations: {
                self.copyButton.tintColor = originalTint
            }, completion: nil)
        }
    }
}
