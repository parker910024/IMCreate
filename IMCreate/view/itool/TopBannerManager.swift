//
//  TopBannerManager.swift
//  IMCreate
//
//  Created by admin on 2025/11/25.
//

import UIKit
import AudioToolbox
import AVFoundation

final class IMTopBannerManager {
    static let shared = IMTopBannerManager()
    private init() {}

    private var queue: [TopBannerItem] = []
    private let lock = DispatchQueue(label: "com.example.IMTopBannerManager")
    private var isShowing = false
    private var bannerView: IMTopBannerView?

    // 声音控制
    private(set) var soundEnabled: Bool = true
    private var soundID: SystemSoundID = 0
    private var soundLoaded: Bool = false
    private let candidateSoundNames = ["banner"] // 尝试 banner.caf / banner.wav / banner.aif
    private let fallbackSystemSoundID: SystemSoundID = 1007 // 回退到系统短音效

    func setSoundEnabled(_ enabled: Bool) {
        soundEnabled = enabled
        if enabled {
            loadSoundIfNeeded()
        } else {
            disposeSound()
        }
    }

    func push(item: TopBannerItem) {
        lock.async {
            self.queue.removeAll()
            self.queue.append(item)

            DispatchQueue.main.async {
                if self.isShowing {
                    self.bannerView?.dismiss(animated: true, fast: true) {
                        self.lock.async { self.isShowing = false }
                        self.showNextIfNeeded()
                    }
                } else {
                    self.showNextIfNeeded()
                }
            }
        }
    }

    private func showNextIfNeeded() {
        lock.async {
            guard !self.queue.isEmpty, !self.isShowing else { return }
            let item = self.queue.removeFirst()
            self.isShowing = true
            DispatchQueue.main.async {
                guard let window = Self.findKeyWindow() else {
                    self.lock.async { self.isShowing = false }
                    return
                }

                if self.soundEnabled {
                    self.loadSoundIfNeeded()
                    self.prepareAudioSessionIfNeeded()
                    self.playSound()
                }

                let view = self.bannerView ?? IMTopBannerView()
                self.bannerView = view
                view.configure(with: item)
                view.show(in: window, animated: true, duration: item.duration)

                DispatchQueue.main.asyncAfter(deadline: .now() + item.duration + 0.05) {
                    self.lock.async {
                        self.isShowing = false
                        DispatchQueue.main.async { self.showNextIfNeeded() }
                    }
                }
            }
        }
    }

    func clearAll() {
        lock.async {
            self.queue.removeAll()
            DispatchQueue.main.async {
                self.bannerView?.dismiss(animated: true, fast: true) {
                    self.lock.async { self.isShowing = false }
                }
            }
        }
    }

    // MARK: - Sound helpers

    private func loadSoundIfNeeded() {
        guard !soundLoaded else { return }
        // 先尝试从 bundle 加载
        for name in candidateSoundNames {
            if let url = Bundle.main.url(forResource: name, withExtension: "caf")
                ?? Bundle.main.url(forResource: name, withExtension: "wav")
                ?? Bundle.main.url(forResource: name, withExtension: "aif") {
                var sid: SystemSoundID = 0
                let status = AudioServicesCreateSystemSoundID(url as CFURL, &sid)
                if status == kAudioServicesNoError && sid != 0 {
                    soundID = sid
                    soundLoaded = true
                    return
                }
            }
        }

        // bundle 中找不到可用文件 -> 使用系统自带短音效作为回退
        soundID = fallbackSystemSoundID
        soundLoaded = true
    }

    private func playSound() {
        guard soundEnabled && soundLoaded else { return }
        // 如果 soundID 为 0，直接返回
        guard soundID != 0 else { return }
        AudioServicesPlaySystemSound(soundID)
    }

    private func disposeSound() {
        // 仅释放我们通过 AudioServicesCreateSystemSoundID 创建的 soundID
        if soundLoaded && soundID != 0 && soundID != fallbackSystemSoundID {
            AudioServicesDisposeSystemSoundID(soundID)
        }
        soundID = 0
        soundLoaded = false
    }

    // 尝试激活音频会话以便在静音模式下也能播放（根据需求可移除）
    private func prepareAudioSessionIfNeeded() {
        // 若不希望绕过静音，请注释掉此方法的调用
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, options: [.duckOthers])
            try AVAudioSession.sharedInstance().setActive(true, options: [])
        } catch {
            // 忽略错误，不影响主流程
        }
    }

    deinit {
        disposeSound()
        // 可选：恢复音频会话状态
        try? AVAudioSession.sharedInstance().setActive(false, options: [])
    }

    private static func findKeyWindow() -> UIWindow? {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }
        } else {
            return UIApplication.shared.keyWindow
        }
    }
}
