import UIKit
import SDWebImage
import SwiftUI

protocol ImageDataSource: AnyObject {
    func numberOfImages() -> Int
    func imageItem(at index:Int) -> ImageItem
    func sourceView(at index:Int) -> MediaView?;
}

extension Array {
    func randomItem() -> Element {
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }
}

public class PreviewViewController:UIPageViewController, ImageViewerTransitionViewControllerConvertible {
    
    var fullscreen: Bool {
        true;
    }
    
    unowned var initialSourceView: MediaView?
    var sourceView: MediaView? {
        guard let vc = viewControllers?.first as? ImageViewerController else {
            return nil
        }
        let v = initialIndex == vc.index ? initialSourceView : imageDatasource?.sourceView(at: vc.index)
        if initialIndex != vc.index {
            initialSourceView?.alpha = 1.0;
        }
        return v;
    }
    
    var targetView: MediaView? {
        guard let vc = viewControllers?.first as? ImageViewerController else {
            return nil
        }
        return vc.imageView
    }
    
    weak var imageDatasource:ImageDataSource?
    let imageLoader:XImageLoader
    
    var initialIndex = 0
    
    var theme:ImageViewerTheme = .light {
        didSet {
            navItem.leftBarButtonItem?.tintColor = theme.tintColor
            navItem.rightBarButtonItem?.tintColor = theme.tintColor
            backgroundView?.backgroundColor = theme.color
        }
    }
    
    var imageContentMode: UIView.ContentMode = .scaleAspectFill
    var options:[ImageViewerOption] = []
    
    private var onRightNavBarTapped:((Int) -> Void)?
    
    private(set) lazy var navBar:UINavigationBar = {
        let _navBar = UINavigationBar(frame: .zero)
        _navBar.isTranslucent = true
        _navBar.setBackgroundImage(UIImage(), for: .default)
        _navBar.shadowImage = UIImage()
        return _navBar
    }()
    
    private(set) lazy var backgroundView:UIView? = {
        let _v = UIView()
        _v.backgroundColor = theme.color
        _v.alpha = 1.0
        return _v
    }()
    
    private(set) lazy var navItem = UINavigationItem()
    
    private let imageViewerPresentationDelegate: ImageViewerTransitionPresentationManager
    private var currentIndex:Int = 0;
  
    init(sourceView:MediaView, imageDataSource: ImageDataSource?, imageLoader: XImageLoader, options:[ImageViewerOption] = [], initialIndex:Int = 0) {
        self.initialSourceView = sourceView
        self.initialIndex = initialIndex
        self.currentIndex = initialIndex
        self.options = options
        self.imageDatasource = imageDataSource
        self.imageLoader = imageLoader
        let pageOptions = [UIPageViewController.OptionsKey.interPageSpacing: 20]
        
        var _imageContentMode = imageContentMode
        options.forEach {
            switch $0 {
            case .contentMode(let contentMode):
                _imageContentMode = contentMode
            default:
                break
            }
        }
        imageContentMode = _imageContentMode
        
        self.imageViewerPresentationDelegate = ImageViewerTransitionPresentationManager(imageContentMode: imageContentMode)
        super.init(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: pageOptions)
        
        transitioningDelegate = imageViewerPresentationDelegate
        modalPresentationStyle = .custom
        modalPresentationCapturesStatusBarAppearance = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addNavBar() {
        // Add Navigation Bar
        let closeBarButton = UIBarButtonItem(
            title: NSLocalizedString("Close", comment: "Close button title"),
            style: .plain,
            target: self,
            action: #selector(dismiss(_:)))
        
        navItem.leftBarButtonItem = closeBarButton
        navItem.leftBarButtonItem?.tintColor = theme.tintColor
        navItem.rightBarButtonItem?.tintColor = theme.tintColor
        navBar.items = [navItem]
        navBar.insert(to: view)
    }
    
    private func addBackgroundView() {
        guard let backgroundView = backgroundView else { return }
        view.addSubview(backgroundView)
        backgroundView.bindFrameToSuperview()
        view.sendSubviewToBack(backgroundView)
    }
    
    var alpha:((_ alpha:CGFloat)->Void)?;
    
    private func applyOptions() {
        
        options.forEach {
            switch $0 {
            case .theme(let theme):
                self.theme = theme
            case .contentMode(let contentMode):
                self.imageContentMode = contentMode
            case .closeIcon(let icon):
                navItem.leftBarButtonItem?.image = icon
            case .rightNavItemTitle(let title, let onTap):
                navItem.rightBarButtonItem = UIBarButtonItem(
                    title: title,
                    style: .plain,
                    target: self,
                    action: #selector(diTapRightNavBarItem(_:)))
                onRightNavBarTapped = onTap
            case .rightNavItemIcon(let icon, let tintColor, let onTap):
                navItem.rightBarButtonItem = UIBarButtonItem(
                    image: icon,
                    style: .plain,
                    target: self,
                    action: #selector(diTapRightNavBarItem(_:)))
                navItem.rightBarButtonItem?.tintColor = tintColor;
                onRightNavBarTapped = onTap
            }
        }
    }
    
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        addBackgroundView()
        addNavBar()
        applyOptions()
        
        dataSource = self
        delegate = self;
        
        alpha = { [weak self] alpha in
            guard let self = self else { return ; }
            self.navBar.alpha = alpha;
        }
        
        if let imageDatasource = imageDatasource {
            let initialVC:ImageViewerController = .init(
                index: initialIndex,
                imageItem: imageDatasource.imageItem(at: initialIndex),
                imageLoader: imageLoader)
            initialVC.alpha = alpha;
            setViewControllers([initialVC], direction: .forward, animated: true)
        }
    }
    
    @objc func didDeleteTask(_ notification:Notification){
        dismiss(animated: true);
    }
    
    
    @objc
    private func dismiss(_ sender:UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    deinit {
        initialSourceView?.alpha = 1.0
    }
    
    @objc
    func diTapRightNavBarItem(_ sender:UIBarButtonItem) {
        guard let onTap = onRightNavBarTapped,
              let _firstVC = viewControllers?.first as? ImageViewerController
        else { return }
        onTap(_firstVC.index)
    }
    
    override public var preferredStatusBarStyle: UIStatusBarStyle {
        if theme == .dark {
            return .lightContent
        }
        return .default
    }
}

extension PreviewViewController:UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if finished {
            guard let currentIndex = self.viewControllers?.first as? ImageViewerController else {
                return;
            }
            self.currentIndex = currentIndex.index;
        }
        
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController,
                                   viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let vc = viewController as? ImageViewerController else { return nil }
        guard let imageDatasource = imageDatasource else { return nil }
        guard vc.index > 0 else { return nil }
        
        let newIndex = vc.index - 1
        let v = ImageViewerController(
            index: newIndex,
            imageItem:  imageDatasource.imageItem(at: newIndex),
            imageLoader: vc.imageLoader)
        v.alpha = alpha;
        return v;
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let vc = viewController as? ImageViewerController else { return nil }
        guard let imageDatasource = imageDatasource else { return nil }
        guard vc.index <= (imageDatasource.numberOfImages() - 2) else { return nil }
        
        let newIndex = vc.index + 1
        let v = ImageViewerController(
            index: newIndex,
            imageItem: imageDatasource.imageItem(at: newIndex),
            imageLoader: vc.imageLoader)
        v.alpha = alpha;
        return v;
    }
}
