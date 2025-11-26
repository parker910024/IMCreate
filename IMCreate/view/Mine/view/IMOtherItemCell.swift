//
//  IMOtherItemCell.swift
//  IMCreate
//
//  Created by admin on 2025/11/25.
//

final class IMOtherItemCell: UITableViewCell {

    static let reuseIdentifier = "IMOtherItemCell"

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 14)
        l.textColor = UIColor(hex: "#333333")
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let line: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hex: "#979797", alpha: 0.1)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        selectionStyle = .default
        accessoryType = .disclosureIndicator
        contentView.addSubview(titleLabel)
        contentView.addSubview(line)

        let onePixel = 1.0 / UIScreen.main.scale
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -56),

            // 将横线的 trailing 锚点改为 cell 本身，避免被 accessory 留出空白
            line.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            line.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            line.topAnchor.constraint(equalTo: contentView.topAnchor),
            line.heightAnchor.constraint(equalToConstant: CGFloat(onePixel))
        ])
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func configure(title: String, accessory: UITableViewCell.AccessoryType = .disclosureIndicator, accessoryView: UIView? = nil) {
        titleLabel.text = title
        if let av = accessoryView {
            self.accessoryView = av
            self.accessoryType = .none
        } else {
            self.accessoryView = nil
            self.accessoryType = accessory
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
