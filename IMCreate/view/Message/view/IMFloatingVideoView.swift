//
//  IMFloatingVideoView.swift
//  IMCreate
//
//  Created by admin on 2025/11/25.
//


import UIKit
import AVFoundation

final class IMFloatingVideoView: UIView {
    static let `default` = CGSize(width: 178, height: 107)

    private weak var hostWindow: UIWindow?
    private let contentPlaceholder = UIImageView()
    private let playButton = UIButton(type: .custom)
    private let closeButton = UIButton(type: .system)
    private var panGesture: UIPanGestureRecognizer!
    private let margin: CGFloat = 8.0
    private(set) var fixedSize: CGSize
    private var videoURL: URL?

    // AVPlayer
    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var playerLayer: AVPlayerLayer?
    private var timeObserver: Any?
    private var playerItemStatusObserver: NSKeyValueObservation?
    private var timeControlStatusObserver: NSKeyValueObservation?

    init(hostWindow: UIWindow? = nil, url: URL? = nil, size: CGSize = IMFloatingVideoView.default, image: UIImage? = nil) {
        self.hostWindow = hostWindow
        self.fixedSize = size
        self.videoURL = url
        super.init(frame: CGRect(origin: .zero, size: size))
        setupAppearance()
        setupPlaceholder(image: image)
        setupButtons()
        setupGestures()
        if let u = url { configure(url: u, autoPlay: false) }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not implemented") }

    deinit {
        cleanupPlayer()
    }

    // MARK: - Public API

    func configure(url: URL?, autoPlay: Bool = false) {
        videoURL = url
        cleanupPlayer()

        guard let url = url else { return }
        // 支持多种格式 (MP4/MOV/HLS 等)，AVPlayer 自动识别
        let asset = AVURLAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        playerItem = item
        player = AVPlayer(playerItem: item)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspectFill
        if let pl = playerLayer {
            layer.insertSublayer(pl, below: playButton.layer)
            setNeedsLayout()
        }

        // 监听状态以更新 UI
        playerItemStatusObserver = item.observe(\.status, options: [.initial, .new]) { [weak self] it, _ in
            DispatchQueue.main.async {
                if it.status == .readyToPlay {
                    // 可选：自动播放
                    if autoPlay { self?.play() }
                } else if it.status == .failed {
                    // 加载失败：保持占位图与 play 状态为暂停
                    self?.updatePlayButton(isPlaying: false)
                }
            }
        }

        timeControlStatusObserver = player?.observe(\.timeControlStatus, options: [.initial, .new]) { [weak self] p, _ in
            DispatchQueue.main.async {
                self?.updatePlayButton(isPlaying: p.timeControlStatus == .playing)
            }
        }

        // 周期性进度监听（可用于进度 UI）
        timeObserver = player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 2), queue: .main) { _ in
            // no-op for now
        }
    }

    func play() {
        guard let player = player else {
            // 若尚未创建 player，可在此尝试 configure 并播放
            if let url = videoURL { configure(url: url, autoPlay: true) }
            return
        }
        player.play()
        updatePlayButton(isPlaying: true)
    }

    func pause() {
        player?.pause()
        updatePlayButton(isPlaying: false)
    }

    func togglePlayPause() {
        if player?.timeControlStatus == .playing {
            pause()
        } else {
            play()
        }
    }

    func show(in containerWindow: UIWindow? = nil, at origin: CGPoint? = nil) {
        guard let window = hostWindow ?? containerWindow ?? Self.findKeyWindow() else { return }
        if superview == nil { window.addSubview(self) }

        let safe = window.safeAreaInsets
        let originPoint: CGPoint
        if let o = origin {
            originPoint = o
        } else {
            let x = window.bounds.width - frame.width - margin - safe.right
            let y = window.bounds.height - frame.height - margin - safe.bottom
            originPoint = CGPoint(x: x, y: y)
        }
        frame.origin = originPoint
        alpha = 0
        transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        UIView.animate(withDuration: 0.22) {
            self.alpha = 1
            self.transform = .identity
        }
    }

    func hide() {
        pause()
        UIView.animate(withDuration: 0.18, animations: {
            self.alpha = 0
            self.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        }) { _ in
            self.removeFromSuperview()
            self.transform = .identity
        }
    }

    func updateContent(image: UIImage?) {
        contentPlaceholder.image = image
    }

    // MARK: - Setup UI

    private func setupAppearance() {
        backgroundColor = .black
        layer.cornerRadius = 10
        layer.masksToBounds = true
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.18
        layer.shadowRadius = 8
        clipsToBounds = false
    }

    private func setupPlaceholder(image: UIImage?) {
        contentPlaceholder.frame = bounds
        contentPlaceholder.contentMode = .scaleAspectFill
        contentPlaceholder.clipsToBounds = true
        contentPlaceholder.image = image
        contentPlaceholder.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(contentPlaceholder)
    }

    private func setupButtons() {
        let playSize: CGFloat = min(56, min(bounds.width, bounds.height) * 0.5)
        playButton.frame = CGRect(x: (bounds.width - playSize)/2, y: (bounds.height - playSize)/2, width: playSize, height: playSize)
        playButton.layer.cornerRadius = playSize / 2
        playButton.backgroundColor = UIColor(white: 0, alpha: 0.45)
        playButton.tintColor = .white
        updatePlayButton(isPlaying: false)
        playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        playButton.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        addSubview(playButton)

        let closeSize: CGFloat = 28
        closeButton.frame = CGRect(x: bounds.width - closeSize - 6, y: 6, width: closeSize, height: closeSize)
        if #available(iOS 13.0, *) {
            closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
            closeButton.tintColor = UIColor(white: 1, alpha: 0.9)
        } else {
            closeButton.setTitle("✕", for: .normal)
            closeButton.setTitleColor(.white, for: .normal)
        }
        closeButton.backgroundColor = UIColor(white: 0, alpha: 0.25)
        closeButton.layer.cornerRadius = closeSize / 2
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        closeButton.autoresizingMask = [.flexibleLeftMargin, .flexibleBottomMargin]
        addSubview(closeButton)
    }

    private func setupGestures() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(panGesture)
        // 点击空白也切换播放
        let tap = UITapGestureRecognizer(target: self, action: #selector(playButtonTapped))
        addGestureRecognizer(tap)
    }

    // MARK: - Actions

    @objc private func playButtonTapped() {
        togglePlayPause()
    }

    @objc private func closeTapped() {
        pause()
        removeFromSuperview()
    }

    // MARK: - Drag & Snap

    @objc private func handlePan(_ g: UIPanGestureRecognizer) {
        guard let window = hostWindow ?? superview?.window ?? Self.findKeyWindow() else { return }
        let translation = g.translation(in: window)
        g.setTranslation(.zero, in: window)

        switch g.state {
        case .began, .changed:
            var newCenter = center
            newCenter.x += translation.x
            newCenter.y += translation.y
            let safe = window.safeAreaInsets
            let halfW = bounds.width / 2
            let halfH = bounds.height / 2
            let minX = safe.left + halfW + margin
            let maxX = window.bounds.width - safe.right - halfW - margin
            let minY = safe.top + halfH + margin
            let maxY = window.bounds.height - safe.bottom - halfH - margin
            newCenter.x = min(max(newCenter.x, minX), maxX)
            newCenter.y = min(max(newCenter.y, minY), maxY)
            center = newCenter
        case .ended, .cancelled, .failed:
            snapToNearestEdge(in: window)
        default: break
        }
    }

    private func snapToNearestEdge(in window: UIWindow) {
        let safe = window.safeAreaInsets
        let halfW = bounds.width / 2
        let minX = safe.left + halfW + margin
        let maxX = window.bounds.width - safe.right - halfW - margin
        let middleX = (minX + maxX) / 2
        let targetX: CGFloat = center.x <= middleX ? minX : maxX

        let minCenterY = safe.top + bounds.height / 2 + margin
        let maxCenterY = window.bounds.height - safe.bottom - bounds.height / 2 - margin
        var targetY = center.y
        targetY = min(max(targetY, minCenterY), maxCenterY)

        let targetCenter = CGPoint(x: targetX, y: targetY)
        UIView.animate(withDuration: 0.28, delay: 0, usingSpringWithDamping: 0.78, initialSpringVelocity: 0.6, options: [.allowUserInteraction, .curveEaseOut], animations: {
            self.center = targetCenter
        }, completion: nil)
    }

    // MARK: - Helpers

    private func updatePlayButton(isPlaying: Bool) {
        if #available(iOS 13.0, *) {
            let name = isPlaying ? "pause.fill" : "play.fill"
            let cfg = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
            playButton.setImage(UIImage(systemName: name, withConfiguration: cfg), for: .normal)
        } else {
            playButton.setTitle(isPlaying ? "▌▌" : "▶︎", for: .normal)
        }
    }

    private func cleanupPlayer() {
        if let obs = timeObserver {
            player?.removeTimeObserver(obs)
            timeObserver = nil
        }
        playerItemStatusObserver?.invalidate()
        timeControlStatusObserver?.invalidate()
        playerItemStatusObserver = nil
        timeControlStatusObserver = nil
        player?.pause()
        player = nil
        playerItem = nil
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentPlaceholder.frame = bounds
        playerLayer?.frame = bounds
        let playSize: CGFloat = min(56, min(bounds.width, bounds.height) * 0.5)
        playButton.frame = CGRect(x: (bounds.width - playSize)/2, y: (bounds.height - playSize)/2, width: playSize, height: playSize)
        let closeSize: CGFloat = 28
        closeButton.frame = CGRect(x: bounds.width - closeSize - 6, y: 6, width: closeSize, height: closeSize)
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
