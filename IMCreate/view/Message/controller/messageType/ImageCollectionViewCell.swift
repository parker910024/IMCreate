//
//  ImageCollectionViewCell.swift
//  IMCreate
//
//  Created by admin on 2025/11/26.
//

import UIKit
import SDWebImage

class ImageCollectionViewCell: UICollectionViewCell {
    static let reuseId = "ImageCollectionViewCell"

    let imageView = UIImageView()
    private let loadingIndicator = UIActivityIndicatorView(style: .medium) // 改为 medium
    private let sizeLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true

        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 6
        imageView.layer.masksToBounds = true

        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true

        sizeLabel.translatesAutoresizingMaskIntoConstraints = false
        sizeLabel.font = UIFont.systemFont(ofSize: 11)
        sizeLabel.textColor = .white
        sizeLabel.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        sizeLabel.layer.cornerRadius = 6
        sizeLabel.clipsToBounds = true
        sizeLabel.textAlignment = .center

        contentView.addSubview(imageView)
        contentView.addSubview(loadingIndicator)
        contentView.addSubview(sizeLabel)

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            loadingIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            sizeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            sizeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 6),
            sizeLabel.heightAnchor.constraint(equalToConstant: 20),
            sizeLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -6) // 新增：避免宽度约束不足
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        sizeLabel.text = nil
        sizeLabel.isHidden = false
        loadingIndicator.stopAnimating()
        imageView.sd_cancelCurrentImageLoad()
    }

    /// 加载图片并通过 completion 返回最终 image（用于单图时更新布局）
    func load(url: URL, completion: ((UIImage?) -> Void)? = nil) {
        loadingIndicator.startAnimating()
        sizeLabel.isHidden = false
        sizeLabel.text = "0.0MB/--MB"

        imageView.sd_setImage(with: url,
                              placeholderImage: nil,
                              options: [.retryFailed, .continueInBackground, .highPriority],
                              progress: { [weak self] receivedSize, expectedSize, _ in
            guard let self = self else { return }
            let loadedMB = Double(receivedSize) / 1024.0 / 1024.0
            let loadedStr = String(format: "%.1f", loadedMB)
            let totalStr: String
            if expectedSize > 0 {
                totalStr = String(format: "%.1f", Double(expectedSize) / 1024.0 / 1024.0)
            } else {
                totalStr = "--"
            }
            DispatchQueue.main.async {
                self.sizeLabel.text = "\(loadedStr)MB/\(totalStr)MB"
                if !self.loadingIndicator.isAnimating { self.loadingIndicator.startAnimating() }
            }
        }, completed: { [weak self] image, error, _, _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.loadingIndicator.stopAnimating()
                if let _ = image {
                    self.sizeLabel.text = nil
                    self.sizeLabel.isHidden = true
                } else {
                    self.sizeLabel.text = "加载失败"
                    self.sizeLabel.isHidden = false
                }
                completion?(image)
            }
        })
    }
}
