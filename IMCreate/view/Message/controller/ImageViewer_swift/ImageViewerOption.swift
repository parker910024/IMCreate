import UIKit

public enum ImageViewerOption {
    
    case theme(ImageViewerTheme)
    case contentMode(UIView.ContentMode)
    case closeIcon(UIImage)
    case rightNavItemTitle(String, onTap: ((Int) -> Void)?)
    case rightNavItemIcon(UIImage, _ tintColor:UIColor, onTap: ((Int) -> Void)?)
}
