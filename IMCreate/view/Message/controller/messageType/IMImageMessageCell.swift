//
//  IMImageMessageCell.swift
//  IMCreate
//
//  Created by admin on 2025/11/26.
//


import UIKit

class IMImageMessageCell: UITableViewCell {
    static let reuseIdentifier = "IMImageMessageCell"

    private let avatarImageView = UIImageView()
    private let bubbleContainer = UIView()
    private let collectionView: UICollectionView
    private let readStatusLabel = UILabel()

    private var imageUrls: [URL] = []
    // 新增：缓存已加载的图片，按 URL 存储
    private var loadedImages: [URL: UIImage] = [:]

    // layout constants
    private let avatarSize: CGFloat = 41
    private let bubbleMaxWidth: CGFloat = 300
    private let itemSpacing: CGFloat = 6
    private let minItemWidth: CGFloat = 80

    private var bubbleLeadingToAvatar: NSLayoutConstraint!
    private var bubbleTrailingToAvatar: NSLayoutConstraint!
    private var avatarLeading: NSLayoutConstraint!
    private var avatarTrailing: NSLayoutConstraint!
    private var bubbleWidthConstraint: NSLayoutConstraint?
    private var bubbleFallbackLeading: NSLayoutConstraint!
    private var bubbleFallbackTrailing: NSLayoutConstraint!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = itemSpacing
        layout.minimumLineSpacing = itemSpacing
        layout.scrollDirection = .vertical
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isScrollEnabled = false

        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none

        // avatar
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.layer.cornerRadius = avatarSize/2
        avatarImageView.clipsToBounds = true
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.backgroundColor = UIColor(white: 0.9, alpha: 1)

        bubbleContainer.translatesAutoresizingMaskIntoConstraints = false
        bubbleContainer.layer.cornerRadius = 8
        bubbleContainer.clipsToBounds = true

        contentView.addSubview(avatarImageView)
        contentView.addSubview(bubbleContainer)
        bubbleContainer.addSubview(collectionView)
        contentView.addSubview(readStatusLabel)

        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: ImageCollectionViewCell.reuseId)
        collectionView.dataSource = self
        collectionView.delegate = self

        readStatusLabel.font = UIFont.systemFont(ofSize: 12)
        readStatusLabel.translatesAutoresizingMaskIntoConstraints = false

        avatarLeading = avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15)
        avatarTrailing = avatarImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15)

        bubbleLeadingToAvatar = bubbleContainer.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 8)
        bubbleTrailingToAvatar = bubbleContainer.trailingAnchor.constraint(equalTo: avatarImageView.leadingAnchor, constant: -8)

        bubbleFallbackLeading = bubbleContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12)
        bubbleFallbackLeading.priority = UILayoutPriority(rawValue: 250)
        bubbleFallbackTrailing = bubbleContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12)
        bubbleFallbackTrailing.priority = UILayoutPriority(rawValue: 250)

        NSLayoutConstraint.activate([
            avatarImageView.widthAnchor.constraint(equalToConstant: avatarSize),
            avatarImageView.heightAnchor.constraint(equalToConstant: avatarSize),
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),

            bubbleContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),

            collectionView.leadingAnchor.constraint(equalTo: bubbleContainer.leadingAnchor, constant: 8),
            collectionView.trailingAnchor.constraint(equalTo: bubbleContainer.trailingAnchor, constant: -8),
            collectionView.topAnchor.constraint(equalTo: bubbleContainer.topAnchor, constant: 8),
            collectionView.bottomAnchor.constraint(equalTo: bubbleContainer.bottomAnchor, constant: -8),

            readStatusLabel.topAnchor.constraint(equalTo: bubbleContainer.bottomAnchor, constant: 5),
            readStatusLabel.trailingAnchor.constraint(equalTo: bubbleContainer.trailingAnchor),
            readStatusLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])

        bubbleFallbackLeading.isActive = true
        bubbleFallbackTrailing.isActive = true

        let initialCap = bubbleContainer.widthAnchor.constraint(lessThanOrEqualToConstant: bubbleMaxWidth)
        initialCap.isActive = true
        bubbleWidthConstraint = initialCap

        // default outgoing
        avatarTrailing.isActive = true
        bubbleTrailingToAvatar.isActive = true

        readStatusLabel.textAlignment = .right

        contentView.layoutIfNeeded()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageUrls = []
        loadedImages.removeAll() // 清空缓存，避免重用时混乱
        collectionView.reloadData()
        readStatusLabel.text = nil
        avatarImageView.image = nil
    }

    func configure(urls: [URL], isOutgoing: Bool, avatar: UIImage?, readStatus: String?) {
        self.imageUrls = urls
        avatarImageView.image = avatar
        if avatar != nil { avatarImageView.backgroundColor = .clear }
        readStatusLabel.text = readStatus

        avatarLeading.isActive = false
        avatarTrailing.isActive = false
        bubbleLeadingToAvatar.isActive = false
        bubbleTrailingToAvatar.isActive = false

        if isOutgoing {
            avatarTrailing.isActive = true
            bubbleTrailingToAvatar.isActive = true
            bubbleContainer.backgroundColor = UIColor(hex: "#C4D7F8") ?? UIColor(red: 0.89, green: 0.90, blue: 0.97, alpha: 1)
        } else {
            avatarLeading.isActive = true
            bubbleLeadingToAvatar.isActive = true
            bubbleContainer.backgroundColor = .white
        }

        // safe width
        let parentWidth: CGFloat = (contentView.bounds.width > 0) ? contentView.bounds.width : UIScreen.main.bounds.width
        let maxW = min(bubbleMaxWidth, parentWidth - (avatarSize + 15 + 12))
        if let c = bubbleWidthConstraint { c.isActive = false }
        let c = bubbleContainer.widthAnchor.constraint(lessThanOrEqualToConstant: maxW)
        c.isActive = true
        bubbleWidthConstraint = c

        // 异步刷新 collection（在主线程）
        DispatchQueue.main.async {
            self.setNeedsLayout()
            self.layoutIfNeeded()
            self.collectionView.collectionViewLayout.invalidateLayout()
            self.collectionView.reloadData()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }

    // 查找父 UITableView
    private func enclosingTableView() -> UITableView? {
        var v: UIView? = self
        while let view = v {
            if let table = view as? UITableView { return table }
            v = view.superview
        }
        return nil
    }
}

extension IMImageMessageCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ cv: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageUrls.count
    }

    func collectionView(_ cv: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = cv.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.reuseId, for: indexPath) as? ImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        let url = imageUrls[indexPath.item]
        // 使用回调缓存图片并 reload 对应 item（避免 reuse 冲突，校验 url 是否匹配）
        cell.load(url: url) { [weak self, weak cv] image in
            DispatchQueue.main.async {
                guard let self = self, let cv = cv else { return }
                // 如果图片加载成功则缓存
                if let img = image {
                    self.loadedImages[url] = img
                }
                // 校验当前 indexPath 对应的 url 是否未发生变化
                if indexPath.item < self.imageUrls.count, self.imageUrls[indexPath.item] == url {
                    cv.performBatchUpdates({
                        cv.reloadItems(at: [indexPath])
                    }, completion: { _ in
                        if self.imageUrls.count == 1 {
                            if let table = self.enclosingTableView() {
                                table.beginUpdates()
                                table.endUpdates()
                            } else {
                                self.setNeedsLayout()
                                self.layoutIfNeeded()
                            }
                        }
                    })
                }
            }
        }
        return cell
    }

    func collectionView(_ cv: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let count = imageUrls.count
        let parentWidth: CGFloat = (contentView.bounds.width > 0) ? contentView.bounds.width : UIScreen.main.bounds.width
        let availableWidth = min(bubbleMaxWidth, parentWidth - (avatarSize + 15 + 12))
        let contentW = max(0.0, availableWidth - 16)

        if count == 1 {
            let url = imageUrls[indexPath.item]
            if let img = loadedImages[url] {
                let w = min(contentW, bubbleMaxWidth)
                let scale = w / max(img.size.width, 1)
                let h = img.size.height * scale
                return CGSize(width: w, height: h)
            } else {
                let w = min(contentW, bubbleMaxWidth)
                return CGSize(width: w, height: w * 0.66)
            }
        } else {
            var chosenCols = min(count, 3)
            var found = false
            for cols in stride(from: min(count, 3), through: 1, by: -1) {
                let itemW = floor((contentW - CGFloat(cols - 1) * itemSpacing) / CGFloat(cols))
                if itemW >= minItemWidth {
                    chosenCols = cols
                    found = true
                    break
                }
            }
            if !found { chosenCols = min(3, count) }
            let itemW = floor((contentW - CGFloat(chosenCols - 1) * itemSpacing) / CGFloat(chosenCols))
            return CGSize(width: itemW, height: itemW)
        }
    }
}

// Helpers
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
