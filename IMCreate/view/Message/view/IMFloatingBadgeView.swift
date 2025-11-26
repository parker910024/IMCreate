//
//  IMFloatingBadgeView.swift
//  IMCreate
//
//  Created by admin on 2025/11/24.
//

import UIKit

final class IMFloatingBadgeView: UIView {
    // 数据源
    private var items: [String]
    private var icons: [UIImage]?

    private weak var hostWindow: UIWindow?
    private let rightMargin: CGFloat = 0

    static let defaultSize = CGSize(width: 120, height: 36)

    // 内部 UI
    private let scrollView = UIScrollView()
    private let pageControl = UIPageControl()
    private let closeButton = UIButton(type: .system)

    // 新：自定义点容器（可见的圆点）
    private let dotsContainer: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.alignment = .center
        sv.distribution = .fill
        sv.spacing = 3
        sv.translatesAutoresizingMaskIntoConstraints = true
        return sv
    }()

    init(hostWindow: UIWindow, items: [String], icons: [UIImage]? = nil) {
        self.hostWindow = hostWindow
        self.items = items
        self.icons = icons
        super.init(frame: CGRect(origin: .zero, size: IMFloatingBadgeView.defaultSize))
        configureAppearance()
        setupScrollView()
        setupPages()
        setupCloseButton()
        setupPageControl()
        setupDotsContainer()
        DispatchQueue.main.async { [weak self] in
            self?.anchorToRightFixedY()
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not implemented") }

    // 外观：左侧圆角，右侧直角
    private func configureAppearance() {
        backgroundColor = UIColor(white: 1.0, alpha: 1)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.12
        layer.shadowRadius = 8
        clipsToBounds = false

        let cornerRadius: CGFloat = 18
        layer.cornerRadius = cornerRadius
        if #available(iOS 11.0, *) {
            layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        }
    }

    // ScrollView 配置
    private func setupScrollView() {
        scrollView.frame = bounds
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = false
        scrollView.alwaysBounceHorizontal = true
        scrollView.delegate = self
        scrollView.backgroundColor = .clear
        addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = true
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    // 根据 items 创建每页卡片（使用当前 scrollView 宽度与高度）
    private func setupPages() {
        // 清除旧页面，避免重复添加
        scrollView.subviews.forEach { $0.removeFromSuperview() }

        // 使用 scrollView 的当前宽度/高度；若为0则退回默认值（layoutSubviews 会再次调用）
        let w = max(scrollView.bounds.width, IMFloatingBadgeView.defaultSize.width)
        let h = max(scrollView.bounds.height, IMFloatingBadgeView.defaultSize.height)

        for (i, title) in items.enumerated() {
            let pageFrame = CGRect(x: CGFloat(i) * w, y: 0, width: w, height: h)
            let page = UIView(frame: pageFrame)
            page.backgroundColor = .clear

            // icon
            let iconSize: CGFloat = 18
            let iconX: CGFloat = 9
            let iconY = (h - iconSize) / 2
            let iconView = UIImageView(frame: CGRect(x: iconX, y: iconY, width: iconSize, height: iconSize))
            iconView.contentMode = .scaleAspectFill
            iconView.layer.cornerRadius = iconSize / 2
            iconView.clipsToBounds = true
            if let icons = icons, i < icons.count {
                iconView.image = icons[i]
            } else {
                iconView.image = UIImage(named: "tempIcon") ?? UIImage(systemName: "circle.fill")
                iconView.tintColor = .systemBlue
            }
            page.addSubview(iconView)

            // title
            let titleX: CGFloat = 31
            let titleW: CGFloat = w - titleX - 22 // 留空间给 close 按钮和右侧边距
            let titleLabel = UILabel(frame: CGRect(x: titleX, y: (h - 20)/2, width: titleW, height: 20))
            titleLabel.font = UIFont.systemFont(ofSize: 12)
            titleLabel.textColor = UIColor(white: 0.15, alpha: 1)
            titleLabel.text = title
            titleLabel.lineBreakMode = .byTruncatingTail
            page.addSubview(titleLabel)

            scrollView.addSubview(page)
        }
        // 确保 contentSize 高度与 scrollView 实际高度一致，避免垂直滚动
        scrollView.contentSize = CGSize(width: CGFloat(items.count) * w, height: 1)
    }

    // 关闭按钮（固定在最右侧，覆盖在所有页上）
    private func setupCloseButton() {
        let w = IMFloatingBadgeView.defaultSize.width
        let h = IMFloatingBadgeView.defaultSize.height
        closeButton.frame = CGRect(x: w - 20, y: (h - 10)/2, width: 10, height: 10)
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = UIColor(white: 0.44, alpha: 1)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        addSubview(closeButton)
    }

    // 点状指示器，配置但不设置 frame（frame 在 layoutSubviews 中计算）
    private func setupPageControl() {
        pageControl.numberOfPages = items.count
        pageControl.currentPage = 0
        pageControl.isUserInteractionEnabled = false
        // 保留颜色用于无障碍或备份
        pageControl.pageIndicatorTintColor = UIColor(hex: "#D8D8D8")
        pageControl.currentPageIndicatorTintColor = UIColor(hex: "#68C8CA")
        addSubview(pageControl)
        bringSubviewToFront(pageControl)
    }

    private func setupDotsContainer() {
        addSubview(dotsContainer)
        bringSubviewToFront(dotsContainer)
        // 初次构建
        updateDots()
    }

    // 使用自定义小圆点替代系统渲染问题
    private func updateDots() {
        // 清除旧点
        dotsContainer.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let selectedColor = UIColor(hex: "#68C8CA")
        let normalColor = UIColor(hex: "#D8D8D8")
        let dotSize: CGFloat = 4
        let pageCount = max(1, items.count)

        for i in 0..<pageCount {
            let dot = UIView()
            dot.translatesAutoresizingMaskIntoConstraints = false
            dot.widthAnchor.constraint(equalToConstant: dotSize).isActive = true
            dot.heightAnchor.constraint(equalToConstant: dotSize).isActive = true
            dot.layer.cornerRadius = dotSize / 2
            dot.layer.masksToBounds = true
            dot.backgroundColor = (i == pageControl.currentPage) ? selectedColor : normalColor
            dotsContainer.addArrangedSubview(dot)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // 为 pageControl 留出高度（dotsContainer 使用相同区域）
        let pcH: CGFloat = 6
        let pcBottomSpacing: CGFloat = 4
        let scrollViewHeight = max(0, bounds.height - pcH - pcBottomSpacing)
        scrollView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: scrollViewHeight)

        // 重新布局 pages（使用当前 scrollView 尺寸）
        setupPages()

        // 关闭按钮布局（相对于当前 bounds）
        let h = bounds.height
        closeButton.frame = CGRect(x: bounds.width - 20, y: (h - 10) / 2, width: 10, height: 10)
        bringSubviewToFront(closeButton)

        // 指示点配置：点尺寸 4×4，间隙 3（中心到中心间距 = 7）
        let dotWidth: CGFloat = 4
        let gap: CGFloat = 3
        let pageCount = max(1, items.count)
        let totalW = CGFloat(pageCount) * dotWidth + CGFloat(max(0, pageCount - 1)) * gap
        let maxW = bounds.width - 8
        var finalW = min(totalW, maxW)

        pageControl.numberOfPages = pageCount
        pageControl.currentPage = min(pageControl.currentPage, max(0, pageCount - 1))

        // 确保 dotsContainer 至少为 totalW（使用 stack 本身大小，不依赖 intrinsic）
        finalW = min(max(finalW, totalW), maxW)

        // 布局 dotsContainer（居中），并向下偏移 4pt
        let extraDown: CGFloat = 2
        let dotsY = bounds.height - pcH - pcBottomSpacing + extraDown
        dotsContainer.frame = CGRect(x: (bounds.width - finalW) / 2,
                                     y: dotsY,
                                     width: finalW,
                                     height: pcH)
        dotsContainer.isHidden = false
        bringSubviewToFront(dotsContainer)

        // 隐藏系统 pageControl 的视觉（保留逻辑）
        pageControl.frame = dotsContainer.frame
        pageControl.isHidden = true

        // 更新自定义点的颜色/数量
        updateDots()
    }

    @objc private func closeTapped() {
        if let win = hostWindow {
            IMFloatManager.shared.unload(in: win)
        } else {
            removeFromSuperview()
        }
    }

    private func anchorToRightFixedY() {
        guard let window = hostWindow else { return }
        let winBounds = window.bounds
        let safe = window.safeAreaInsets

        let x = winBounds.width - IMFloatingBadgeView.defaultSize.width - rightMargin - safe.right
        let minY = safe.top + 8
        let maxY = winBounds.height - IMFloatingBadgeView.defaultSize.height - safe.bottom - 8
        let fixedY: CGFloat = 272
        let y = max(minY, min(fixedY, maxY))

        let originInWindow = CGPoint(x: x, y: y)

        if let superview = superview {
            frame.origin = superview.convert(originInWindow, from: window)
        } else {
            frame.origin = originInWindow
        }
    }

    func show() {
        isHidden = false
        anchorToRightFixedY()
    }

    func hide() {
        isHidden = true
    }
}

extension IMFloatingBadgeView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 使用 scrollView 的实际宽度计算页码
        let w = max(scrollView.bounds.width, 1)
        let page = Int(round(scrollView.contentOffset.x / w))
        let newPage = max(0, min(page, max(0, items.count - 1)))
        if pageControl.currentPage != newPage {
            pageControl.currentPage = newPage
            // 更新自定义点高亮
            updateDots()
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDidScroll(scrollView)
    }
}

// 辅助扩展与方法（文件底部）
private extension UIColor {
    /// 支持 "\#RRGGBB" 或 "RRGGBB" 格式
    convenience init(hex: String) {
        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if s.hasPrefix("#") { s.removeFirst() }
        var rgb: UInt64 = 0
        Scanner(string: s).scanHexInt64(&rgb)
        let r: CGFloat = s.count == 6 ? CGFloat((rgb >> 16) & 0xFF) / 255.0 : 0
        let g: CGFloat = s.count == 6 ? CGFloat((rgb >> 8) & 0xFF) / 255.0 : 0
        let b: CGFloat = s.count == 6 ? CGFloat(rgb & 0xFF) / 255.0 : 0
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}

private func dotImage(color: UIColor, size: CGSize = CGSize(width: 4, height: 4), cornerRadius: CGFloat = 2) -> UIImage? {
    let format = UIGraphicsImageRendererFormat()
    format.opaque = false
    format.scale = UIScreen.main.scale
    let renderer = UIGraphicsImageRenderer(size: size, format: format)
    let img = renderer.image { _ in
        let rect = CGRect(origin: .zero, size: size)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
        color.setFill()
        path.fill()
    }
    // 保留原始渲染模式
    return img.withRenderingMode(.alwaysOriginal)
}
