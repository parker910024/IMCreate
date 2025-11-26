//
//  IMProfileControlsCell.swift
//  IMCreate
//
//  Created by admin on 2025/11/25.
//

import UIKit

final class IMProfileControlsCell: UITableViewCell {

    // 回调
    var onLevelSwitchChanged: ((Bool) -> Void)?
    var onNotifySwitchChanged: ((Bool) -> Void)?

    private let topGrayView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hex: "#F6F7FB")
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let line: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hex: "#979797",alpha: 0.1)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let bottomGrayView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hex: "#F6F7FB")
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let row1Label: UILabel = {
        let l = UILabel()
        l.text = "等级和气泡效果"
        l.font = UIFont.systemFont(ofSize: 14)
        l.textColor = UIColor(hex: "#333333")
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // 使用自定义开关
    private let levelSwitch: IMCustomSwitch = {
        let s = IMCustomSwitch()
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    private let row2Label: UILabel = {
        let l = UILabel()
        l.text = "消息通知"
        l.font = UIFont.systemFont(ofSize: 14)
        l.textColor = UIColor(hex: "#333333")
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let notifySwitch: IMCustomSwitch = {
        let s = IMCustomSwitch()
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    private let bottomInfoLabel: UILabel = {
        let l = UILabel()
        l.text = "消息将通过声音、振动等进行提示"
        l.font = UIFont.systemFont(ofSize: 12)
        l.textColor = UIColor(hex: "#AAAAAA")
        l.numberOfLines = 2
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // 固定高度 136
    private let fixedHeight: CGFloat = 136

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setup()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not implemented") }

    private func setup() {
        contentView.addSubview(topGrayView)
        contentView.addSubview(row1Label)
        contentView.addSubview(levelSwitch)
        contentView.addSubview(line)
        contentView.addSubview(row2Label)
        contentView.addSubview(notifySwitch)
        contentView.addSubview(bottomGrayView)
        contentView.addSubview(bottomInfoLabel)

        // 固定 cell 高度
        let h = contentView.heightAnchor.constraint(equalToConstant: fixedHeight)
        h.priority = .required
        h.isActive = true

        NSLayoutConstraint.activate([
            // top gray spacer
            topGrayView.topAnchor.constraint(equalTo: contentView.topAnchor),
            topGrayView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            topGrayView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            topGrayView.heightAnchor.constraint(equalToConstant: 10),

            // row1
            row1Label.topAnchor.constraint(equalTo: topGrayView.bottomAnchor, constant: 0),
            row1Label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            row1Label.heightAnchor.constraint(equalToConstant: 44),

            levelSwitch.centerYAnchor.constraint(equalTo: row1Label.centerYAnchor),
            levelSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            levelSwitch.widthAnchor.constraint(equalToConstant: 43),
            levelSwitch.heightAnchor.constraint(equalToConstant: 20),

            // separator line
            line.topAnchor.constraint(equalTo: row1Label.bottomAnchor),
            line.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            line.heightAnchor.constraint(equalToConstant: 1),
            line.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            // row2
            row2Label.topAnchor.constraint(equalTo: row1Label.bottomAnchor),
            row2Label.leadingAnchor.constraint(equalTo: row1Label.leadingAnchor),
            row2Label.heightAnchor.constraint(equalToConstant: 44),

            notifySwitch.centerYAnchor.constraint(equalTo: row2Label.centerYAnchor),
            notifySwitch.trailingAnchor.constraint(equalTo: levelSwitch.trailingAnchor),
            notifySwitch.widthAnchor.constraint(equalToConstant: 43),
            notifySwitch.heightAnchor.constraint(equalToConstant: 20),

            // bottom info (高度 30) + bottom gray bg (高度 30)
            bottomInfoLabel.topAnchor.constraint(equalTo: row2Label.bottomAnchor, constant: 0),
            bottomInfoLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            bottomInfoLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            bottomInfoLabel.heightAnchor.constraint(equalToConstant: 30),

            bottomGrayView.topAnchor.constraint(equalTo: row2Label.bottomAnchor, constant: 0),
            bottomGrayView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bottomGrayView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bottomGrayView.heightAnchor.constraint(equalToConstant: 30),
        ])

        // 事件
        levelSwitch.addTarget(self, action: #selector(levelChanged(_:)), for: .valueChanged)
        notifySwitch.addTarget(self, action: #selector(notifyChanged(_:)), for: .valueChanged)
    }

    @objc private func levelChanged(_ s: IMCustomSwitch) {
        onLevelSwitchChanged?(s.isOn)
    }

    @objc private func notifyChanged(_ s: IMCustomSwitch) {
        onNotifySwitchChanged?(s.isOn)
    }

    // 对外更新状态
    func configure(levelOn: Bool, notifyOn: Bool) {
        levelSwitch.setOn(levelOn, animated: false)
        notifySwitch.setOn(notifyOn, animated: false)
    }
}
