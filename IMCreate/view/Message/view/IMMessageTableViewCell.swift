//
//  IMMessageTableViewCell.swift
//  IMCreate
//
//  Created by admin on 2025/11/24.
//

// swift
import UIKit

class IMMessageTableViewCell: UITableViewCell {
    static let reuseIdentifier = "IMMessageTableViewCell"

    private let avatarLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 26)
        l.textColor = .white
        l.textAlignment = .center
        l.layer.cornerRadius = 26
        l.layer.masksToBounds = true
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let nameLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.boldSystemFont(ofSize: 15)
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textColor = UIColor(hex: "#0F0F0F")
        return l
    }()

    private let messageLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 13)
        l.textColor = UIColor(hex: "#999999")
        l.numberOfLines = 1
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let timeLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 12)
        l.textColor = UIColor(hex: "#AAAAAA")
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let separator: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hex: "#F1F1F1", alpha: 1)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none

        contentView.addSubview(avatarLabel)
        contentView.addSubview(nameLabel)
        contentView.addSubview(messageLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(separator)

        NSLayoutConstraint.activate([
            avatarLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            avatarLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            avatarLabel.widthAnchor.constraint(equalToConstant: 52),
            avatarLabel.heightAnchor.constraint(equalToConstant: 52),

            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            nameLabel.leadingAnchor.constraint(equalTo: avatarLabel.trailingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: timeLabel.leadingAnchor, constant: -10),

            messageLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 7),
            messageLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            timeLabel.topAnchor.constraint(equalTo: nameLabel.topAnchor),
            timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            separator.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(with model: IMMessage) {
        nameLabel.text = model.name
        timeLabel.text = model.timeText
        avatarLabel.backgroundColor = model.avatarColor
        avatarLabel.text = String(model.name.prefix(1))

        // 高亮关键字 "[红包]"
        let text = model.lastText
        let defaultColor = UIColor(hex: "#999999")
        let highlightColor = UIColor(hex: "#F74C31")
        let font = messageLabel.font ?? UIFont.systemFont(ofSize: 13)

        let attributed = NSMutableAttributedString(string: text, attributes: [
            .font: font,
            .foregroundColor: defaultColor
        ])

        let keyword = "[红包]"
        var searchRange = NSRange(location: 0, length: (text as NSString).length)
        while true {
            let foundRange = (text as NSString).range(of: keyword, options: [], range: searchRange)
            if foundRange.location == NSNotFound { break }
            attributed.addAttribute(.foregroundColor, value: highlightColor, range: foundRange)
            let nextLocation = foundRange.location + foundRange.length
            if nextLocation >= (text as NSString).length { break }
            searchRange = NSRange(location: nextLocation, length: (text as NSString).length - nextLocation)
        }

        messageLabel.attributedText = attributed
    }
}
