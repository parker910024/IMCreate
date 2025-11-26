import Foundation
import SDWebImage

protocol XImageLoader {
    func loadImage(_ url: URL, placeholder: UIImage?, imageView: MediaView, completion: @escaping (_ image: UIImage?) -> Void)
}

struct SDWebImageLoader: XImageLoader {
    func loadImage(_ url: URL, placeholder: UIImage?, imageView: MediaView, completion: @escaping (UIImage?) -> Void) {
        let cachedKey = SDWebImageManager.shared.cacheKey(for: url);
        if let image = SDImageCache.shared.imageFromCache(forKey: cachedKey) {
            imageView.image = image;
            completion(image);
            return;
        }
        imageView.imageView.sd_setImage(with: url, placeholderImage: placeholder, options: [], progress: nil) {(img, err, type, url) in
            DispatchQueue.main.async {
                imageView.image = img;
                completion(img)
            }
        }
    }
}
