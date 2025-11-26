//
//  IMFloatManager.swift
//  IMCreate
//
//  Created by admin on 2025/11/24.
//


import Foundation
import UIKit

final class IMFloatManager {
    static let shared = IMFloatManager()
    private init() {}

    private var badgeViews: [ObjectIdentifier: IMFloatingBadgeView] = [:]
    private var videoViews: [ObjectIdentifier: IMFloatingVideoView] = [:]

    var isLoaded: Bool {
        return !badgeViews.isEmpty || !videoViews.isEmpty
    }

    // MARK: - Badge APIs (原有)
    func loadAll(items: [String] = [], icons: [UIImage]? = nil) {
        let windows = currentAppWindows()
        for window in windows {
            load(in: window, items: items, icons: icons)
        }
    }

    func load(in window: UIWindow, items: [String], icons: [UIImage]? = nil) {
        let id = ObjectIdentifier(window)
        if let existing = badgeViews[id] {
            existing.removeFromSuperview()
            badgeViews.removeValue(forKey: id)
        }
        let v = IMFloatingBadgeView(hostWindow: window, items: items, icons: icons)
        v.translatesAutoresizingMaskIntoConstraints = true
        window.addSubview(v)
        window.bringSubviewToFront(v)
        badgeViews[id] = v
    }

    func unload(in window: UIWindow) {
        let id = ObjectIdentifier(window)
        if let v = badgeViews[id] {
            v.removeFromSuperview()
            badgeViews.removeValue(forKey: id)
        }
    }

    // MARK: - Video APIs
    func loadVideo(in window: UIWindow, url: URL, size: CGSize? = nil, at origin: CGPoint? = nil) {
        let id = ObjectIdentifier(window)
        // 如果已存在，先移除旧的
        if let existing = videoViews[id] {
            existing.removeFromSuperview()
            videoViews.removeValue(forKey: id)
        }
        let viewSize = size ?? IMFloatingVideoView.default
        let v = IMFloatingVideoView(hostWindow: window, url: url, size: viewSize, image: nil)
        v.configure(url: url)
        v.translatesAutoresizingMaskIntoConstraints = true
        window.addSubview(v)
        window.bringSubviewToFront(v)
        v.show(in: window, at: origin)
        videoViews[id] = v
    }

    func unloadVideo(in window: UIWindow) {
        let id = ObjectIdentifier(window)
        guard let v = videoViews[id] else { return }
        v.removeFromSuperview()
        videoViews.removeValue(forKey: id)
    }

    // MARK: - Bulk/unload
    func unloadAll() {
        for (_, v) in badgeViews { v.removeFromSuperview() }
        badgeViews.removeAll()
        for (_, v) in videoViews { v.removeFromSuperview() }
        videoViews.removeAll()
    }

    func toggleAll() {
        if isLoaded { unloadAll() } else { loadAll() }
    }

    // 兼容旧调用
    func load(in window: UIWindow) {
        load(in: window, items: [], icons: nil)
    }

    // MARK: - Helpers
    private func currentAppWindows() -> [UIWindow] {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .filter { !$0.isHidden && $0.windowLevel == .normal }
        } else {
            return UIApplication.shared.windows.filter { !$0.isHidden && $0.windowLevel == .normal }
        }
    }
}
