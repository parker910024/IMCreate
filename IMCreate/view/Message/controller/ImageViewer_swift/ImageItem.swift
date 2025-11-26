import UIKit

enum ImageItem {
    case image(UIImage?)
    case style(MediaItem)
    case url(URL, placeholder: UIImage?)
}
