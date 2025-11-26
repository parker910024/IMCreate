//
//  AVPlayerView.swift
//  VEO3
//
//  Created by xjj on 2024/11/24.
//

import UIKit
import SDWebImage
import AVFoundation

extension SDWebImageManager {
    
    func load(image with: URL?) async -> UIImage? {
        guard let with else { return nil }
        do {
            return try await self.loadImage(with: with)
        }
        catch (let exception){
            NSLog("load image exception:\(exception)");
            return nil;
        }
    }
    
    func syncLoadImage(image with: URL?) -> UIImage? {
        if let with = with {
            if with.isFileURL {
                return UIImage(contentsOfFile: with.path);
            }
        }
        let cachedKey = SDWebImageManager.shared.cacheKey(for: with);
        return SDImageCache.shared.imageFromCache(forKey: cachedKey);
    }
    private func loadImage(with url: URL) async throws -> UIImage? {
        try await withCheckedThrowingContinuation { continuation in
            self.loadImage(
                with: url,
                progress: nil
            ) { image, _, error, _, _, _ in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: image)
                }
            }
        }
    }
}

class MediaView: UIView {
    
    private var _imageView = UIImageView();
    private var _placeholder = UIImageView();
    private var _videoPlayerView:UIView?;
    private var _videoPlayerLayer:AVPlayerLayer?;
    private var _player:AVPlayer?;
    private var _videoURL:String = "";
    private var _cacheURL:String = "";
    private var _image:UIImage?;
    private var _audioEnabled = false;
    private var _listened = false;
    private var _blurImageView:UIImageView?;
    private var _xframe:CGRect = .zero;
    
    
    var identifier:Int?;
    
    var placeholderInset:UIEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 0) {
        didSet {
            let width = min(self.bounds.width / 2, self.bounds.height / 2);
            _placeholder.frame = .init(x: (self.bounds.width - width)/2 + placeholderInset.left, y: (self.bounds.height - width)/2 - 20.0 + placeholderInset.bottom, width: width - placeholderInset.left - placeholderInset.right, height: width - placeholderInset.top - placeholderInset.bottom);
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder);
        setup();
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        setup();
    }
    
    var imageView:UIImageView {
        return _imageView;
    }
    
    var cacheURL:URL? {
        if _cacheURL.count == 0 {
            return nil;
        }
        return URL(fileURLWithPath: _cacheURL);
    }
    
    var audioEnabled: Bool {
        get {
            _audioEnabled
        }
        set {
            _audioEnabled = newValue
            _player?.isMuted = !newValue;
        }
    }
    
    var cornerRadius:CGFloat = 0.0 {
        didSet {
            updateAspectRatio();
        }
    }
    
    @objc dynamic var image: UIImage? = nil {
        didSet {
            _imageView.image = image;
            _blurImageView?.image = image;
            self._placeholder.isHidden = image != nil;
        }
    }
    
    var imageURL: URL? = nil {
        didSet {
            
            if imageURL == nil {
                self._placeholder.isHidden = true;
                self._placeholder.stopAnimating();
                return;
            }
            
            if let image = SDWebImageManager.shared.syncLoadImage(image: imageURL) {
                self.image = image;
                self._placeholder.isHidden = true;
                self._placeholder.stopAnimating();
            }
            else {
                self._placeholder.isHidden = false;
                self._placeholder.startAnimating();
                self._imageView.sd_setImage(with: imageURL) { [weak self] image, exception, type, url in
                    guard let self = self else {
                        return;
                    }
                    if image == nil {
                        return;
                    }
                    self._placeholder.stopAnimating();
                    self._placeholder.isHidden = true;
                    self.image = image;
                };
            }
        }
    }
    
    override var contentMode: UIView.ContentMode {
        get {
            super.contentMode;
        }
        set {
            super.contentMode = newValue;
            _imageView.contentMode = newValue;
            _videoPlayerLayer?.videoGravity = newValue == .scaleAspectFit ? .resizeAspect : .resizeAspectFill;
        }
    }
    
    private func setup(){
        self.backgroundColor = .clear;
        _imageView.contentMode = self.contentMode;
        _imageView.isUserInteractionEnabled = true;
        self.clipsToBounds = true;
        insertSubview(_imageView, at: 0);
        
        NotificationCenter.default.addObserver(self, selector: #selector(videoDownloadFinished(_:)), name: .init(AppDownloader.kApplicationDidDownloadVideoNotifition), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(videoPlayerDidFinished(_:)), name: AVPlayerItem.didPlayToEndTimeNotification, object: nil)
        addSubview(_placeholder);
        _placeholder.contentMode = .scaleAspectFit;
        _placeholder.image = UIImage(named: "x-placeholder");
    }
    
    @objc func videoDownloadFinished(_ notification:Notification){
        guard let videoURL = notification.object as? String else { return ; }
        if videoURL == _videoURL {
            self.setupVideoPlayer(videoURL: URL(string: videoURL)!);
        }
    }
    
    @objc func videoPlayerDidFinished(_ notification:Notification){
        guard let playerItem = notification.object as? AVPlayerItem else { return ; }
        guard let asset = playerItem.asset as? AVURLAsset else { return ; }
        if asset.url.path != _cacheURL || _player == nil {
            return;
        }
        _player?.seek(to: .zero);
        _player?.play();
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard _xframe != self.bounds else { return; }
        updateAspectRatio();
        _xframe = self.bounds;
        let width = min(self.bounds.width / 2, self.bounds.height / 2);
        _placeholder.frame = .init(x: (self.bounds.width - width)/2 + placeholderInset.left, y: (self.bounds.height - width)/2 - 20.0 + placeholderInset.bottom, width: width, height: width);
    }
    
    var aspectRatio:CGFloat = 0.0 {
        didSet {
            updateAspectRatio();
        }
    }
    
    private func setupVideoPlayer(videoURL:URL){
        _videoURL = videoURL.absoluteString;
        if !videoURL.absoluteString.hasSuffix("mp4") {
            return;
        }
        guard let url = AppDownloader.shared.cache(forURL: videoURL.absoluteString) else {
            Task {
                await AppDownloader.shared.download(video: videoURL.absoluteString);
            }
            return;
        }
        _cacheURL = url.path;
        _player = AVPlayer(playerItem: AVPlayerItem(url: url));
        _player?.isMuted = !_audioEnabled;
        
        _videoPlayerLayer = AVPlayerLayer(player: _player);
        _videoPlayerLayer?.frame = self.bounds;
        _videoPlayerLayer?.videoGravity = self.contentMode == .scaleAspectFit ? .resizeAspect : .resizeAspectFill;
        
        _videoPlayerView = UIView(frame: self.bounds);
        _videoPlayerView?.layer.addSublayer(_videoPlayerLayer!);
        self.insertSubview(_videoPlayerView!, aboveSubview: _imageView);
        _player?.play();
        
        updateAspectRatio();
        _placeholder.isHidden = true;
        _placeholder.stopAnimating();
    }
    
    
    private func updateAspectRatio(){
        if aspectRatio > 0.001 {
            let frame = AVMakeRect(aspectRatio: .init(width: aspectRatio, height: 1.0), insideRect: self.bounds);
            _imageView.frame = frame;
            _videoPlayerView?.frame = frame;
            _videoPlayerLayer?.frame = .init(origin: .zero, size: frame.size);
            
            _imageView.layer.cornerRadius = cornerRadius;
            _imageView.clipsToBounds = true;
            
            _videoPlayerView?.layer.cornerRadius = cornerRadius;
            _videoPlayerView?.clipsToBounds = true;
        }
        else {
            _imageView.frame = self.bounds;
            _videoPlayerLayer?.frame = self.bounds;
            _videoPlayerView?.frame = self.bounds;
        }
    }
    
    private func clearVideoPlayer(){
        _videoURL = "";
        _cacheURL = "";
        _player?.pause();
        _player?.replaceCurrentItem(with: nil);
        _player = nil;
        _videoPlayerView?.removeFromSuperview();
        _videoPlayerLayer?.removeFromSuperlayer();
    }
    
    func setVideoSource(videoURL:URL?, audioEnabled:Bool) {
        _videoURL = "";
        _audioEnabled = audioEnabled;
        clearVideoPlayer();
        if let videoURL = videoURL {
            if videoURL.isFileURL {
                _videoURL = videoURL.absoluteString;
            }
            setupVideoPlayer(videoURL: videoURL);
        }
    }
    
    func setVideoPlayer(playing:Bool) {
        if !playing {
            _player?.pause();
            _player?.replaceCurrentItem(with: nil);
            _player = nil;
            _videoPlayerView?.removeFromSuperview();
            _videoPlayerLayer?.removeFromSuperlayer();
        }
        else {
            if _player == nil && _videoURL.count > 0 {
                setupVideoPlayer(videoURL: URL(string: _videoURL)!);
            }
        }
    }
}
