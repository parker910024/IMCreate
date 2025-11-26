import UIKit
import SDWebImage
import AVFoundation

class ImageViewerController:UIViewController, UIGestureRecognizerDelegate {
    
    var imageView: MediaView = MediaView(frame: .zero)
    let imageLoader: XImageLoader
    
    var backgroundView:UIView? {
        guard let _parent = parent as? PreviewViewController
            else { return nil}
        return _parent.backgroundView
    }
    
    var index:Int = 0
    var imageItem:ImageItem!

    var navBar:UINavigationBar? {
        guard let _parent = parent as? PreviewViewController
            else { return nil}
        return _parent.navBar
    }
    
    private var scrollView:UIScrollView!
    
    private var lastLocation:CGPoint = .zero
    private var isAnimating:Bool = false
    private var maxZoomScale:CGFloat = 1.0
    
    init(
        index: Int,
        imageItem:ImageItem,
        imageLoader: XImageLoader) {

        self.index = index
        self.imageItem = imageItem
        self.imageLoader = imageLoader
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        let view = UIView()
    
        view.backgroundColor = .clear
        self.view = view
        
        scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
        
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        view.addSubview(scrollView)
        scrollView.bindFrameToSuperview()
        scrollView.backgroundColor = .clear
        scrollView.addSubview(imageView)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        switch imageItem {
        case .image(let img):
            imageView.image = img
            imageView.layoutIfNeeded()
        case .url(let url, let placeholder):
            imageLoader.loadImage(url, placeholder: placeholder, imageView: imageView) { [weak self] (image) in
                self?.layout()
            }
        case .style(let img):
            guard let imageURL = img.imageURL else { return ; }
            imageLoader.loadImage(imageURL, placeholder: nil, imageView: imageView) { [weak self] (image) in
                self?.layout()
            }
        default:
            break
        }
        
        addGestureRecognizers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        var videoURL:URL?;
        switch imageItem {
        case .style(let img):
            videoURL = img.videoURL;
        default:
            break
        }
        self.imageView.setVideoSource(videoURL: videoURL, audioEnabled: true);
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.imageView.setVideoPlayer(playing: false);
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        var size:CGSize = .init(width: 1, height: 1);
        switch imageItem {
        case .style(let img):
            size = .init(width: img.width, height: img.height);
        default:
            break
        }
        let frame = AVMakeRect(aspectRatio: size, insideRect: CGRect(origin: .zero, size: self.view.frame.size));
        self.imageView.frame = frame;
        layout()
    }
    
    private func layout() {
        updateConstraintsForSize(view.bounds.size)
        updateMinMaxZoomScaleForSize(view.bounds.size)
    }
    
    // MARK: Add Gesture Recognizers
    func addGestureRecognizers() {
        
        let panGesture = UIPanGestureRecognizer(
            target: self, action: #selector(didPan(_:)))
        panGesture.cancelsTouchesInView = false
        panGesture.delegate = self
        scrollView.addGestureRecognizer(panGesture)
//        
//        let pinchRecognizer = UITapGestureRecognizer(
//            target: self, action: #selector(didPinch(_:)))
//        pinchRecognizer.numberOfTapsRequired = 1
//        pinchRecognizer.numberOfTouchesRequired = 2
//        scrollView.addGestureRecognizer(pinchRecognizer)
//        
//        let singleTapGesture = UITapGestureRecognizer(
//            target: self, action: #selector(didSingleTap(_:)))
//        singleTapGesture.numberOfTapsRequired = 1
//        singleTapGesture.numberOfTouchesRequired = 1
//        scrollView.addGestureRecognizer(singleTapGesture)
//        
//        let doubleTapRecognizer = UITapGestureRecognizer(
//            target: self, action: #selector(didDoubleTap(_:)))
//        doubleTapRecognizer.numberOfTapsRequired = 2
//        doubleTapRecognizer.numberOfTouchesRequired = 1
//        scrollView.addGestureRecognizer(doubleTapRecognizer)
//        
//        singleTapGesture.require(toFail: doubleTapRecognizer)
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)
    }
    
    @objc
    func didPan(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard
            isAnimating == false,
            scrollView.zoomScale == scrollView.minimumZoomScale
            else { return }
        
        let container:UIView! = imageView
        if gestureRecognizer.state == .began {
            lastLocation = container.center
        }
        
        if gestureRecognizer.state != .cancelled {
            let translation: CGPoint = gestureRecognizer
                .translation(in: view)
            container.center = CGPoint(
                x: lastLocation.x + translation.x,
                y: lastLocation.y + translation.y)
        }
        
        let diffY = view.center.y - container.center.y
        
        let alpha = (1.0 - abs(diffY/view.center.y)) * (1.0 - abs(diffY/view.center.y));
        
        backgroundView?.alpha = alpha;
        self.alpha?(alpha);
        
        if gestureRecognizer.state == .ended {
            if abs(diffY) > 60 {
                dismiss(animated: true)
            } else {
                executeCancelAnimation()
            }
        }
    }
    
    var alpha:((_ alpha:CGFloat)->Void)?;
    
    @objc
    func didPinch(_ recognizer: UITapGestureRecognizer) {
        var newZoomScale = scrollView.zoomScale / 1.5
        newZoomScale = max(newZoomScale, scrollView.minimumZoomScale)
        scrollView.setZoomScale(newZoomScale, animated: true)
    }
    
    @objc
    func didSingleTap(_ recognizer: UITapGestureRecognizer) {
        
        let currentNavAlpha = self.navBar?.alpha ?? 0.0
        UIView.animate(withDuration: 0.235) {
            self.navBar?.alpha = currentNavAlpha > 0.5 ? 0.0 : 1.0
        }
    }
    
    @objc
    func didDoubleTap(_ recognizer:UITapGestureRecognizer) {
        let pointInView = recognizer.location(in: imageView)
        zoomInOrOut(at: pointInView)
    }
    
    func gestureRecognizerShouldBegin(
        _ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard scrollView.zoomScale == scrollView.minimumZoomScale,
            let panGesture = gestureRecognizer as? UIPanGestureRecognizer
            else { return false }
        
        let velocity = panGesture.velocity(in: scrollView)
        return abs(velocity.y) > abs(velocity.x)
    }
    
    
}

// MARK: Adjusting the dimensions
extension ImageViewerController {
    
    func updateMinMaxZoomScaleForSize(_ size: CGSize) {
        
        let targetSize = imageView.bounds.size
        if targetSize.width == 0 || targetSize.height == 0 {
            return
        }
        
        let minScale = min(
            size.width/targetSize.width,
            size.height/targetSize.height)
        let maxScale = max(
            (size.width + 1.0) / targetSize.width,
            (size.height + 1.0) / targetSize.height)
        
        scrollView.minimumZoomScale = minScale
        scrollView.zoomScale = minScale
        maxZoomScale = maxScale
        scrollView.maximumZoomScale = maxZoomScale * 1.1
    }
    
    
    func zoomInOrOut(at point:CGPoint) {
        let newZoomScale = scrollView.zoomScale == scrollView.minimumZoomScale
            ? maxZoomScale : scrollView.minimumZoomScale
        let size = scrollView.bounds.size
        let w = size.width / newZoomScale
        let h = size.height / newZoomScale
        let x = point.x - (w * 0.5)
        let y = point.y - (h * 0.5)
        let rect = CGRect(x: x, y: y, width: w, height: h)
        scrollView.zoom(to: rect, animated: true)
    }
    
    func updateConstraintsForSize(_ size: CGSize) {
        guard let image = self.imageView.image else { return ; }
        let frame = AVMakeRect(aspectRatio: image.size, insideRect: CGRect(origin: .zero, size: size));
        self.imageView.frame = frame;
    }
    
    @objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        if scrollView.zoomScale > 1.0 {
            scrollView.setZoomScale(1.0, animated: true)
        } else {
            let pointInView = gesture.location(in: imageView)
            let newZoomScale = scrollView.maximumZoomScale
            let width = scrollView.bounds.size.width / newZoomScale
            let height = scrollView.bounds.size.height / newZoomScale
            let rectToZoom = CGRect(x: pointInView.x - width / 2,
                                    y: pointInView.y - height / 2,
                                    width: width,
                                    height: height)
            scrollView.zoom(to: rectToZoom, animated: true)
        }
    }
    
}

// MARK: Animation Related stuff
extension ImageViewerController {
    
    private func executeCancelAnimation() {
        self.isAnimating = true
        UIView.animate(
            withDuration: 0.237,
            animations: {
                self.imageView.center = self.view.center
                self.backgroundView?.alpha = 1.0
        }) {[weak self] _ in
            self?.isAnimating = false
        }
    }
}

extension ImageViewerController:UIScrollViewDelegate {
    
  
    // MARK: - UIScrollViewDelegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        imageView.center = centerOfScrollViewContent(scrollView)
    }

    // MARK: - 辅助函数
    private func centeredFrame(for image: UIImage, in boundsSize: CGSize) -> CGRect {
        let imageSize = image.size
        let minScale = min(boundsSize.width / imageSize.width, boundsSize.height / imageSize.height)

        let width = imageSize.width * minScale
        let height = imageSize.height * minScale
        let x = (boundsSize.width - width) / 2.0
        let y = (boundsSize.height - height) / 2.0

        return CGRect(x: x, y: y, width: width, height: height)
    }

    private func centerOfScrollViewContent(_ scrollView: UIScrollView) -> CGPoint {
        let offsetX = max((scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5, 0)
        let offsetY = max((scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5, 0)
        return CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX,
                       y: scrollView.contentSize.height * 0.5 + offsetY)
    }
}

