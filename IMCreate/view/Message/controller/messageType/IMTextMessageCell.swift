//
//  IMTextMessageCell.swift
//  IMCreate
//
//  Created by admin on 2025/11/25.
//

import UIKit

class IMTextMessageCell: UITableViewCell {
    static let reuseIdentifier = "IMTextMessageCell"

    // MARK: - Views
    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 20.5
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.backgroundColor = UIColor(white: 0.9, alpha: 1)
        return iv
    }()

    private let bubbleContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.clipsToBounds = true
        return v
    }()

    private let bubbleBackgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleToFill
        iv.layer.cornerRadius = 6
        iv.layer.masksToBounds = true
        return iv
    }()

    private let messageLabel: UILabel = {
        let l = UILabel()
        l.numberOfLines = 0
        l.lineBreakMode = .byWordWrapping
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textAlignment = .left
        return l
    }()

    private let timeLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 10)
        l.translatesAutoresizingMaskIntoConstraints = false
        l.setContentHuggingPriority(.required, for: .horizontal)
        l.setContentCompressionResistancePriority(.required, for: .horizontal)
        l.textAlignment = .right
        return l
    }()

    private let readStatusLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 12)
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textAlignment = .left
        return l
    }()

    // MARK: - Constraints
    private var avatarLeading: NSLayoutConstraint!
    private var avatarTrailing: NSLayoutConstraint!
    private var bubbleLeadingToAvatar: NSLayoutConstraint!
    private var bubbleTrailingToAvatar: NSLayoutConstraint!
    private var bubbleMinWidth: NSLayoutConstraint!
    private var bubbleMaxWidth: NSLayoutConstraint!
    private var bubbleMinHeight: NSLayoutConstraint!

    private var messageMinHeightConstraint: NSLayoutConstraint!

    // time related
    private var messageTrailingToBubble: NSLayoutConstraint!
    private var messageTrailingToTime: NSLayoutConstraint!
    private var messageBottomToBubble: NSLayoutConstraint!
    private var messageBottomToTime: NSLayoutConstraint!
    private var timeLeadingToMessageMin: NSLayoutConstraint!

    // alternate message horizontal constraints for centering behavior
    private var messageLeadingEq: NSLayoutConstraint!
    private var messageLeadingGE: NSLayoutConstraint!
    private var messageTrailingLE: NSLayoutConstraint!
    private var messageCenterX: NSLayoutConstraint!

    // store time constraints so we can ensure bottom = -messagePadding
    private var timeTrailingConstraint: NSLayoutConstraint!
    private var timeBottomConstraint: NSLayoutConstraint!

    // Constants
    private let avatarSize: CGFloat = 41
    private let avatarRightMargin: CGFloat = 15
    private let bubbleAvatarSpacing: CGFloat = 8
    private let messagePadding: CGFloat = 8
    private let bubbleMinW: CGFloat = 50
    private let bubbleMaxW: CGFloat = 300
    private let bubbleMinH: CGFloat = 40

    // State
    private var isOutgoingMessage: Bool = false

    // extra content bounds
    private var bubbleLeadingMinToContent: NSLayoutConstraint!
    private var bubbleTrailingMaxToContent: NSLayoutConstraint!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none

        // 优先级调整：让 message 在必要时可以收缩，为 time 腾出空间（Hugging 保持低）
        messageLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        // 确保文本不会被压缩，从而推动气泡扩展
        messageLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        // 允许 bubbleContainer 横向扩展（不与父视图抢占）
        bubbleContainer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        bubbleContainer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        contentView.addSubview(avatarImageView)
        contentView.addSubview(bubbleContainer)
        bubbleContainer.addSubview(bubbleBackgroundImageView)
        bubbleContainer.addSubview(messageLabel)
        bubbleContainer.addSubview(timeLabel)
        contentView.addSubview(readStatusLabel)

        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupConstraints() {
        avatarLeading = avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: avatarRightMargin)
        avatarTrailing = avatarImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -avatarRightMargin)

        NSLayoutConstraint.activate([
            avatarImageView.widthAnchor.constraint(equalToConstant: avatarSize),
            avatarImageView.heightAnchor.constraint(equalToConstant: avatarSize),
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12)
        ])

        // 顶部固定，底部由 readStatusLabel 决定（气泡在上，未读标签在下）
        NSLayoutConstraint.activate([
            bubbleContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12)
        ])

        bubbleLeadingMinToContent = bubbleContainer.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 12)
        bubbleTrailingMaxToContent = bubbleContainer.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -12)
        bubbleLeadingMinToContent.isActive = true
        bubbleTrailingMaxToContent.isActive = true

        bubbleMinWidth = bubbleContainer.widthAnchor.constraint(greaterThanOrEqualToConstant: bubbleMinW)
        bubbleMaxWidth = bubbleContainer.widthAnchor.constraint(lessThanOrEqualToConstant: bubbleMaxW)
        bubbleMaxWidth.priority = .required
        bubbleMinHeight = bubbleContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: bubbleMinH)
        bubbleMinWidth.isActive = true
        bubbleMaxWidth.isActive = true
        bubbleMinHeight.isActive = true

        bubbleLeadingToAvatar = bubbleContainer.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: bubbleAvatarSpacing)
        bubbleTrailingToAvatar = bubbleContainer.trailingAnchor.constraint(equalTo: avatarImageView.leadingAnchor, constant: -bubbleAvatarSpacing)

        NSLayoutConstraint.activate([
            bubbleBackgroundImageView.leadingAnchor.constraint(equalTo: bubbleContainer.leadingAnchor),
            bubbleBackgroundImageView.trailingAnchor.constraint(equalTo: bubbleContainer.trailingAnchor),
            bubbleBackgroundImageView.topAnchor.constraint(equalTo: bubbleContainer.topAnchor),
            bubbleBackgroundImageView.bottomAnchor.constraint(equalTo: bubbleContainer.bottomAnchor)
        ])

        messageMinHeightConstraint = messageLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 20)

        // equality constraints (默认使用)
        messageLeadingEq = messageLabel.leadingAnchor.constraint(equalTo: bubbleContainer.leadingAnchor, constant: messagePadding)
        messageTrailingToBubble = messageLabel.trailingAnchor.constraint(equalTo: bubbleContainer.trailingAnchor, constant: -messagePadding)
        // inequalities 用于配合居中时的宽度限制
        messageLeadingGE = messageLabel.leadingAnchor.constraint(greaterThanOrEqualTo: bubbleContainer.leadingAnchor, constant: messagePadding)
        messageTrailingLE = messageLabel.trailingAnchor.constraint(lessThanOrEqualTo: bubbleContainer.trailingAnchor, constant: -messagePadding)
        // 中心约束（用于当文字宽度小于最小宽度时）
        messageCenterX = messageLabel.centerXAnchor.constraint(equalTo: bubbleContainer.centerXAnchor)
        // time 相关
        messageTrailingToTime = messageLabel.trailingAnchor.constraint(equalTo: timeLabel.leadingAnchor, constant: -5)
        messageBottomToBubble = messageLabel.bottomAnchor.constraint(equalTo: bubbleContainer.bottomAnchor, constant: -messagePadding)
        messageBottomToTime = messageLabel.bottomAnchor.constraint(lessThanOrEqualTo: timeLabel.topAnchor, constant: -5)

        // 初始激活默认的 equality 布局
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: bubbleContainer.topAnchor, constant: messagePadding),
            messageLeadingEq,
            messageMinHeightConstraint,
            messageTrailingToBubble,
            messageBottomToBubble
        ])

        // store time constraints so bottom always equals -messagePadding (8)
        timeTrailingConstraint = timeLabel.trailingAnchor.constraint(equalTo: bubbleContainer.trailingAnchor, constant: -messagePadding)
        timeBottomConstraint = timeLabel.bottomAnchor.constraint(equalTo: bubbleContainer.bottomAnchor, constant: -messagePadding)
        NSLayoutConstraint.activate([timeTrailingConstraint, timeBottomConstraint])

        timeLeadingToMessageMin = timeLabel.leadingAnchor.constraint(greaterThanOrEqualTo: messageLabel.trailingAnchor, constant: 5)
        timeLeadingToMessageMin.isActive = false

        // 未读标签：放在气泡底下，顶部与 bubbleContainer.bottom 间距 5，右侧与气泡对齐，底部与 contentView 保持至少 12 间距
        readStatusLabel.setContentHuggingPriority(.required, for: .horizontal)
        readStatusLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        NSLayoutConstraint.activate([
            readStatusLabel.topAnchor.constraint(equalTo: bubbleContainer.bottomAnchor, constant: 5),
            readStatusLabel.trailingAnchor.constraint(equalTo: bubbleContainer.trailingAnchor),
            readStatusLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 12),
            readStatusLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12)
        ])

        // 默认优先级设置
        messageTrailingToBubble.priority = .required
        messageTrailingToTime.priority = .defaultHigh
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // 先让系统做一次布局，确保 contentView.bounds 正确
        contentView.layoutIfNeeded()

        // 保证 time 的底部间距始终为 messagePadding（8）
        if timeBottomConstraint.constant != -messagePadding {
            timeBottomConstraint.constant = -messagePadding
        }
        timeBottomConstraint.isActive = true

        // 计算可用宽度并设置 messageLabel.preferredMaxLayoutWidth
        let contentWidth = max(0, contentView.bounds.width)
        let horizontalReserved = avatarSize + avatarRightMargin + bubbleAvatarSpacing + 12
        let maxBubbleSpace = max(0, contentWidth - horizontalReserved)
        let effectiveBubbleMaxW = min(bubbleMaxW, maxBubbleSpace)
        let bubbleMaxInner = max(0, effectiveBubbleMaxW - 2 * messagePadding)
        let availableInnerWidthForLayout = bubbleMaxInner

        // 如果没有 time，直接把 preferredMaxLayoutWidth 设为可用宽度（并不超过 bubbleMax）
        guard !timeLabel.isHidden, let timeText = timeLabel.text, !timeText.isEmpty else {
            let innerWidth = availableInnerWidthForLayout
            if innerWidth > 0 && messageLabel.preferredMaxLayoutWidth != innerWidth {
                messageLabel.preferredMaxLayoutWidth = innerWidth
                messageLabel.setNeedsLayout()
                messageLabel.layoutIfNeeded()
            }
            // 保证约束为 message 占满气泡宽度
            messageTrailingToTime.isActive = false
            messageBottomToTime.isActive = false
            timeLeadingToMessageMin.isActive = false
            messageTrailingToBubble.isActive = true
            messageBottomToBubble.isActive = true

            // 检查是否需要居中（文字宽度+padding <= bubbleMinW）
            let singleLineMessageSize = messageLabel.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
            let messageNeededWidth = singleLineMessageSize.width
            if messageNeededWidth + 2 * messagePadding <= bubbleMinW {
                // 启用居中约束，禁用两边的 equality 约束
                messageLeadingEq.isActive = false
                messageTrailingToBubble.isActive = false
                messageLeadingGE.isActive = true
                messageTrailingLE.isActive = true
                messageCenterX.isActive = true
                messageLabel.textAlignment = .center
            } else {
                // 恢复左对齐
                messageCenterX.isActive = false
                messageLeadingGE.isActive = false
                messageTrailingLE.isActive = false
                messageLeadingEq.isActive = true
                messageTrailingToBubble.isActive = true
                messageLabel.textAlignment = .left
            }

            return
        }

        // 判定是否能在同一行显示时，使用 effectiveBubbleMaxW（允许扩展到最大宽度再决定）
        let timeWidth = timeLabel.intrinsicContentSize.width
        let singleLineMessageSize = messageLabel.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
        let messageNeededWidth = singleLineMessageSize.width
        let spacing: CGFloat = 5

        // 只有当父视图允许展开到 bubbleMaxW 时，才按最大内宽尝试单行，否则按可用空间折行
        if effectiveBubbleMaxW >= bubbleMaxW && messageNeededWidth + timeWidth + spacing <= bubbleMaxInner {
            // 同一行：让 message 限制为 (bubbleMaxInner - timeWidth - spacing)
            let target = max(0, bubbleMaxInner - (timeWidth + spacing))
            if messageLabel.preferredMaxLayoutWidth != target {
                messageLabel.preferredMaxLayoutWidth = target
            }

            // 切换约束：message 与 time 同一行
            messageTrailingToBubble.isActive = false
            messageBottomToBubble.isActive = true
            messageTrailingToTime.isActive = true
            messageBottomToTime.isActive = false
            timeLeadingToMessageMin.isActive = true

            messageTrailingToTime.priority = .defaultHigh
            messageTrailingToBubble.priority = .defaultLow
            messageBottomToTime.priority = .defaultLow
            messageBottomToBubble.priority = .required
        } else {
            // 换行或无法扩展到最大宽度：message 占满当前可用宽度（不超过 effectiveBubbleMaxW），time 在第二行右下
            let target = max(0, availableInnerWidthForLayout)
            if messageLabel.preferredMaxLayoutWidth != target {
                messageLabel.preferredMaxLayoutWidth = target
            }

            messageTrailingToTime.isActive = false
            messageBottomToTime.isActive = true
            timeLeadingToMessageMin.isActive = false

            messageTrailingToBubble.isActive = true
            messageBottomToBubble.isActive = false

            messageTrailingToTime.priority = .defaultHigh
            messageTrailingToBubble.priority = .required
            messageBottomToTime.priority = .defaultHigh
            messageBottomToBubble.priority = .defaultLow
        }

        // 在处理完 time 布局后，检查是否需要居中（文字宽度+padding <= bubbleMinW）
        if messageNeededWidth + 2 * messagePadding <= bubbleMinW {
            // 启用居中约束，禁用两边的 equality 约束（并保留不超出气泡的 inequality 限制）
            messageLeadingEq.isActive = false
            messageTrailingToBubble.isActive = false
            messageLeadingGE.isActive = true
            messageTrailingLE.isActive = true
            messageCenterX.isActive = true
            messageLabel.textAlignment = .center
        } else {
            // 恢复左对齐行为
            messageCenterX.isActive = false
            messageLeadingGE.isActive = false
            messageTrailingLE.isActive = false
            messageLeadingEq.isActive = true
            messageTrailingToBubble.isActive = true
            messageLabel.textAlignment = .left
        }

        // 触发布局更新
        messageLabel.setNeedsLayout()
        messageLabel.layoutIfNeeded()
        timeLabel.setNeedsLayout()
        timeLabel.layoutIfNeeded()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.image = nil
        messageLabel.text = nil
        timeLabel.text = nil
        readStatusLabel.text = nil
        readStatusLabel.isHidden = true
        timeLabel.isHidden = true

        messageTrailingToTime.isActive = false
        messageBottomToTime.isActive = false
        messageTrailingToBubble.isActive = true
        messageBottomToBubble.isActive = true
        timeLeadingToMessageMin.isActive = false

        // 恢复居中相关约束状态
        messageCenterX.isActive = false
        messageLeadingGE.isActive = false
        messageTrailingLE.isActive = false
        messageLeadingEq.isActive = true

        avatarLeading.isActive = false
        avatarTrailing.isActive = false
        bubbleLeadingToAvatar.isActive = false
        bubbleTrailingToAvatar.isActive = false
    }

    func configure(text: String,
                   isOutgoing: Bool,
                   avatar: UIImage?,
                   time: String?,
                   readStatus: String? = "未读",
                   contentColor: UIColor? = nil,
                   timeColor: UIColor? = nil,
                   bubbleImage: UIImage? = nil) {
        isOutgoingMessage = isOutgoing
        messageLabel.text = text
        avatarImageView.image = avatar

        messageLabel.font = UIFont.systemFont(ofSize: 14)
        if let cc = contentColor { messageLabel.textColor = cc } else { messageLabel.textColor = .black }
        if let tc = timeColor { timeLabel.textColor = tc } else { timeLabel.textColor = UIColor(white: 0.6, alpha: 1) }

        if let t = time, !t.isEmpty {
            timeLabel.text = t
            timeLabel.isHidden = false

            // 初始约束切换（实际最终状态在 layoutSubviews 中决定）
            messageTrailingToBubble.isActive = false
            messageBottomToBubble.isActive = false

            messageTrailingToTime.isActive = true
            messageBottomToTime.isActive = true
            timeLeadingToMessageMin.isActive = true

            messageTrailingToTime.priority = .defaultHigh
            messageTrailingToBubble.priority = .defaultLow
            messageBottomToTime.priority = .defaultHigh
            messageBottomToBubble.priority = .defaultLow
        } else {
            timeLabel.isHidden = true
            messageTrailingToTime.isActive = false
            messageBottomToTime.isActive = false
            timeLeadingToMessageMin.isActive = false

            messageTrailingToBubble.isActive = true
            messageBottomToBubble.isActive = true

            messageTrailingToTime.priority = .defaultHigh
            messageTrailingToBubble.priority = .required
            messageBottomToTime.priority = .defaultHigh
            messageBottomToBubble.priority = .required
        }

        if let img = bubbleImage {
            let capInsets = UIEdgeInsets(top: 15, left: 20, bottom: 15, right: 20)
            bubbleBackgroundImageView.image = img.resizableImage(withCapInsets: capInsets, resizingMode: .stretch)
            bubbleBackgroundImageView.backgroundColor = .clear
        } else {
            bubbleBackgroundImageView.image = nil
            bubbleBackgroundImageView.backgroundColor = isOutgoing ? (UIColor(hex: "#C4D7F8") ?? UIColor(red: 0.89, green: 0.90, blue: 0.97, alpha: 1)) : .white
            messageLabel.textColor = contentColor ?? .black
        }

        if let status = readStatus, isOutgoing {
            readStatusLabel.text = status
            readStatusLabel.isHidden = false
            if status.contains("已读") {
                readStatusLabel.textColor = UIColor(hex: "#B4B4B4") ?? UIColor(white: 0.7, alpha: 1)
            } else {
                readStatusLabel.textColor = UIColor(red: 0.09, green: 0.50, blue: 1.00, alpha: 1.0)
            }
        } else {
            readStatusLabel.isHidden = true
        }

        avatarLeading.isActive = false
        avatarTrailing.isActive = false
        bubbleLeadingToAvatar.isActive = false
        bubbleTrailingToAvatar.isActive = false

        if isOutgoing {
            avatarTrailing.isActive = true
            bubbleTrailingToAvatar.isActive = true
        } else {
            avatarLeading.isActive = true
            bubbleLeadingToAvatar.isActive = true
        }

        contentView.bringSubviewToFront(avatarImageView)
        setNeedsLayout()
        layoutIfNeeded()
    }
}

// Helper UIColor init from hex
private extension UIColor {
    convenience init?(hex: String) {
        var str = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if str.hasPrefix("#") { str.removeFirst() }
        if str.count != 6 { return nil }
        var rgb: UInt64 = 0
        Scanner(string: str).scanHexInt64(&rgb)
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}
