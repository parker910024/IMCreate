//
//  IMTopBannerView.swift
//  IMCreate
//
//  Created by admin on 2025/11/25.
//

import UIKit

struct TopBannerItem {
    let id: String
    let title: String
    let subtitle: String?
    let icon: UIImage?
    let duration: TimeInterval // 自动消失时间
    init(id: String = UUID().uuidString, title: String, subtitle: String? = nil, icon: UIImage? = nil, duration: TimeInterval = 3.0) {
        self.id = id; self.title = title; self.subtitle = subtitle; self.icon = icon; self.duration = duration
    }
}

final class IMTopBannerView: UIView {
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private var autoDismissWork: DispatchWorkItem?
    private var currentItem: TopBannerItem?

    private let contentHeight: CGFloat = 64
    private let horizontalPadding: CGFloat = 12
    private let verticalMargin: CGFloat = 8

    private var originalY: CGFloat = 0
    private let dismissThreshold: CGFloat = 40

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupGesture()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not implemented") }

    private func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 12
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.18
        layer.shadowRadius = 8

        iconView.layer.cornerRadius = 18
        iconView.clipsToBounds = true
        iconView.contentMode = .scaleAspectFill
        iconView.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textColor = UIColor(white: 0.08, alpha: 1)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        subtitleLabel.font = UIFont.systemFont(ofSize: 12)
        subtitleLabel.textColor = UIColor(white: 0.45, alpha: 1)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(iconView)
        addSubview(titleLabel)
        addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: horizontalPadding),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 36),
            iconView.heightAnchor.constraint(equalToConstant: 36),

            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -horizontalPadding),
            titleLabel.topAnchor.constraint(equalTo: iconView.topAnchor, constant: -2),

            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2)
        ])
    }

    private func setupGesture() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(pan)
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        switch gesture.state {
        case .began:
            originalY = frame.origin.y
            autoDismissWork?.cancel()
        case .changed:
            if translation.y < 0 { // 只允许向上拖动
                frame.origin.y = originalY + translation.y
            }
        case .ended, .cancelled:
            if translation.y < -dismissThreshold {
                dismiss(animated: true, fast: true, completion: nil)
            } else {
                UIView.animate(withDuration: 0.2) {
                    self.frame.origin.y = self.originalY
                }
                // 重新启动自动消失
                if let item = currentItem {
                    scheduleAutoDismiss(duration: item.duration)
                }
            }
        default:
            break
        }
    }

    func configure(with item: TopBannerItem) {
        currentItem = item
        iconView.image = item.icon
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
        accessibilityLabel = item.title + (item.subtitle.map { "，\($0)" } ?? "")
    }

    func show(in window: UIWindow, animated: Bool = true, duration: TimeInterval) {
        autoDismissWork?.cancel()
        autoDismissWork = nil

        if superview == nil {
            frame = CGRect(x: 12, y: -contentHeight - 20, width: window.bounds.width - 24, height: contentHeight)
            window.addSubview(self)
        }
        let topInset = window.safeAreaInsets.top
        let targetY = topInset + verticalMargin

        if animated {
            transform = CGAffineTransform(translationX: 0, y: -6)
            alpha = 0
            UIView.animate(withDuration: 0.32, delay: 0, options: [.curveEaseOut]) {
                self.frame.origin.y = targetY
                self.alpha = 1
                self.transform = .identity
            }
        } else {
            frame.origin.y = targetY
            alpha = 1
        }
        originalY = targetY
        scheduleAutoDismiss(duration: duration)
    }

    private func scheduleAutoDismiss(duration: TimeInterval) {
        let work = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.dismiss(animated: true, fast: false, completion: nil)
            }
        }
        autoDismissWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: work)
    }

    func dismiss(animated: Bool = true, fast: Bool = false, completion: (() -> Void)? = nil) {
        autoDismissWork?.cancel()
        autoDismissWork = nil

        let duration = fast ? 0.18 : (animated ? 0.28 : 0)
        UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseIn], animations: {
            self.frame.origin.y = -self.bounds.height - 20
            self.alpha = 0
        }) { _ in
            self.removeFromSuperview()
            completion?()
        }
    }
}
