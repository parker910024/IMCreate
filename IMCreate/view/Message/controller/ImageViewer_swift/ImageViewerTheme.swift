import UIKit

public enum ImageViewerTheme {
    case light
    case dark
    
    var color:UIColor {
        UIColor(red: 245/255.0, green: 245/255.0, blue: 249/255.0, alpha: 1.0)
    }
    
    var tintColor:UIColor {
        switch self {
            case .light:
                return .black
            case .dark:
                return .white
        }
    }
}
