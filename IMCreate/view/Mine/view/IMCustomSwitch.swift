//
//  IMCustomSwitch.swift
//  IMCreate
//
//  Created by admin on 2025/11/25.
//

import UIKit

final class IMCustomSwitch: UIControl {
    private let backgroundView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(white: 0.85, alpha: 1)
        v.isUserInteractionEnabled = false
        return v
    }()
    private let knobView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.shadowColor = UIColor(white: 0, alpha: 0.15).cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 1)
        v.layer.shadowRadius = 1
        v.layer.shadowOpacity = 1
        return v
    }()
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.isHidden = true
        return iv
    }()

    private let padding: CGFloat = 2
    private var knobSize: CGSize { CGSize(width: bounds.height - padding * 2, height: bounds.height - padding * 2) }

    private(set) var isOn: Bool = false

    override var intrinsicContentSize: CGSize { CGSize(width: 43, height: 20) }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        addSubview(backgroundView)
        addSubview(imageView)
        addSubview(knobView)

        backgroundColor = .clear
        isAccessibilityElement = true
        accessibilityTraits = .button

        let tap = UITapGestureRecognizer(target: self, action: #selector(toggleAnimated))
        addGestureRecognizer(tap)

        if let img = UIImage(named: "openSegmentIcon") {
            imageView.image = img.withRenderingMode(.alwaysOriginal)
        }
        updateUI(animated: false)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundView.frame = bounds
        backgroundView.layer.cornerRadius = bounds.height / 2

        imageView.frame = bounds.insetBy(dx: 2, dy: 2)

        let ks = knobSize
        let knobY = padding
        let knobX: CGFloat = isOn ? bounds.width - padding - ks.width : padding
        knobView.frame = CGRect(x: knobX, y: knobY, width: ks.width, height: ks.height)
        knobView.layer.cornerRadius = knobView.bounds.height / 2
    }

    private func updateUI(animated: Bool) {
        let apply = {
            self.imageView.isHidden = !self.isOn
            if self.isOn {
                self.backgroundView.backgroundColor = .clear
                self.knobView.alpha = 0.0
            } else {
                self.backgroundView.backgroundColor = UIColor(white: 0.9, alpha: 1)
                self.knobView.alpha = 1.0
            }
            self.setNeedsLayout()
            self.layoutIfNeeded()
            self.accessibilityValue = self.isOn ? "已开启" : "已关闭"
        }

        if animated {
            UIView.animate(withDuration: 0.22, animations: apply)
        } else {
            apply()
        }
    }

    func setOn(_ on: Bool, animated: Bool) {
        guard on != isOn else { return }
        isOn = on
        updateUI(animated: animated)
    }

    @objc private func toggleAnimated() {
        isOn.toggle()
        // 切换时给出简短动画
        UIView.animate(withDuration: 0.2, animations: {
            self.updateUI(animated: false)
        }, completion: { _ in
            self.sendActions(for: .valueChanged)
        })
    }
}
