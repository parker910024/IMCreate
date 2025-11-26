//
//  AppConfig.swift
//  IMCreate
//
//  Created by admin on 2025/11/24.
//

import UIKit

struct AppConfig {
    // 状态栏高度（运行时读取）
    static var statusBarHeight: CGFloat {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let height = scene.statusBarManager?.statusBarFrame.height {
            return height
        }
        return UIApplication.shared.statusBarFrame.height
    }
    
    static var screenBounds: CGRect { UIScreen.main.bounds }
    static var screenWidth: CGFloat { screenBounds.width }
    static var screenHeight: CGFloat { screenBounds.height }

    // 导航栏高度（标准）
    static let navBarHeight: CGFloat = 44.0

    // 包含状态栏的顶部总高
    static var topBarHeight: CGFloat { statusBarHeight + navBarHeight }

    // TabBar 高度（包含安全区 bottom）
    static var tabBarHeight: CGFloat {
        var bottomSafe: CGFloat = 0
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first {
            bottomSafe = window.safeAreaInsets.bottom
        }
        return 49.0 + bottomSafe
    }

    // 主题颜色
    static let tabbarSelected = UIColor(hex: "#4ACCF0")
    static let tabbarUnselected = UIColor(hex: "#999999")
}

// UIColor 十六进制扩展
extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexStr = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hexStr.hasPrefix("#") { hexStr.removeFirst() }
        if hexStr.count == 3 { // 支持短格式 e.g. FFF
            var full = ""
            for ch in hexStr { full.append("\(ch)\(ch)") }
            hexStr = full
        }
        var rgb: UInt64 = 0
        Scanner(string: hexStr).scanHexInt64(&rgb)
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
}
