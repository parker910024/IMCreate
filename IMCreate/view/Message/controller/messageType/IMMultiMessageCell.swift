//
//  IMImageMessageCell 2.swift
//  IMCreate
//
//  Created by x on 2025/11/26.
//

import PhotosUI


struct MediaItem: Decodable {
    var media:String = "";
    var width:CGFloat = 1;
    var height:CGFloat = 1;
    
    var imageURL:URL? {
        if (media.hasSuffix("mp4") || media.hasSuffix("mov")) {
            return nil
        }
        if media.hasPrefix("http") {
            return URL(string: media);
        }
        return URL(fileURLWithPath: media);
    }
    
    var videoURL:URL? {
        if (media.hasSuffix("mp4") || media.hasSuffix("mov")) {
            if media.hasPrefix("http") {
                return URL(string: media);
            }
            return URL(fileURLWithPath: media);
        }
        return nil;
    }    
}


func loadVideoURL(result: PHPickerResult, completion: @escaping (URL?) -> Void) {
    let provider = result.itemProvider
    
    if provider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
        provider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { url, error in
            guard let url = url else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            // 拷贝到 app 内可访问位置
            let targetURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mov")
            try? FileManager.default.copyItem(at: url, to: targetURL)
            completion(targetURL)
        }
    } else if provider.hasItemConformingToTypeIdentifier(UTType.video.identifier) {
        provider.loadFileRepresentation(forTypeIdentifier: UTType.video.identifier) { url, error in
            guard let url = url else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            // 拷贝到 app 内可访问位置
            let targetURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mp4")
            try? FileManager.default.copyItem(at: url, to: targetURL)
            completion(targetURL)
        }
    } else {
        completion(nil)
    }
}

func loadImage(result: PHPickerResult, completion: @escaping (UIImage?) -> Void) {
    let provider = result.itemProvider
    
    if provider.canLoadObject(ofClass: UIImage.self) {
        provider.loadObject(ofClass: UIImage.self) { object, error in
            completion(object as? UIImage)
        }
    } else {
        completion(nil)
    }
}

func loadImageData(result: PHPickerResult, completion: @escaping (Data?) -> Void) {
    let provider = result.itemProvider
    if let type = provider.registeredTypeIdentifiers.first {
        provider.loadDataRepresentation(forTypeIdentifier: type) { data, error in
            completion(data)
        }
    } else {
        completion(nil)
    }
}

func getVideoSize(from asset: AVAsset) -> CGSize? {
    guard let track = asset.tracks(withMediaType: .video).first else {
        return nil
    }
    let size = track.naturalSize.applying(track.preferredTransform)
    return CGSize(width: abs(size.width), height: abs(size.height))
}

func parsePickerResult(_ results: [PHPickerResult]) -> [MediaItem] {
    var pickers = [MediaItem]();
    let sem = DispatchSemaphore(value: 0);
    for result in results {
        let provider = result.itemProvider
        if provider.canLoadObject(ofClass: UIImage.self) {
            loadImage(result: result) { image in
                if let image, let relative = AppDownloader.shared.save(image: image) {
                    let abs = AppDownloader.shared.absolutePath(relative: relative);
                    var cc = MediaItem(media: abs);
                    cc.width = image.size.width;
                    cc.height = image.size.height;
                    pickers.append(cc);
                }
                sem.signal();
            }
            sem.wait();
        }
        
        // 视频
        if provider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
            loadVideoURL(result: result) { url in
                if let url {
                    var cc = MediaItem(media: url.path);
                    if let size = getVideoSize(from: AVURLAsset(url: url)) {
                        cc.width = size.width;
                        cc.height = size.height;
                    }
                    pickers.append(cc);
                }
                sem.signal();
            }
            sem.wait();
        }
    }
    return pickers;
}



class IMMultiMessageCell: UITableViewCell, ImageDataSource {
    func numberOfImages() -> Int {
        self.images.count;
    }
    
    func imageItem(at index: Int) -> ImageItem {
        return ImageItem.style(self.images[index]);
    }
    
    func sourceView(at index: Int) -> MediaView? {
        
        if index == 0 {
            self.largeImageView
        }
        else if index == 1 {
            self.secondImageView
        }
        else {
            self.thirdImageView
        }
    }
    
    static let reuseIdentifier = "IMMultiMessageCell"

    private let avatarImageView = UIImageView()
    private let bubbleContainer = UIView()
    private let readStatusLabel = UILabel()

    private var imageUrls: [URL] = []
    // 新增：缓存已加载的图片，按 URL 存储
    private var loadedImages: [URL: UIImage] = [:]

    // layout constants
    private var avatarSize: CGFloat {
        return Self.kAvatarSize;
    }
    private let bubbleMaxWidth: CGFloat = 300
    private let itemSpacing: CGFloat = 6
    private let minItemWidth: CGFloat = 80
    
    static let kAvatarSize:CGFloat = 41;
    
    private var avatarLeading: NSLayoutConstraint!
    private var avatarTrailing: NSLayoutConstraint!
    
    private var message = IMMessageType(medias: [])
    
    private var largeImageView:MediaView = MediaView(frame: .zero);
    private var secondImageView:MediaView = MediaView(frame: .zero);
    private var thirdImageView:MediaView = MediaView(frame: .zero);
    

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {

        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none

        // avatar
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.layer.cornerRadius = avatarSize/2
        avatarImageView.clipsToBounds = true
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.backgroundColor = UIColor(white: 0.9, alpha: 1)

        bubbleContainer.translatesAutoresizingMaskIntoConstraints = false
        bubbleContainer.layer.cornerRadius = 8
        bubbleContainer.clipsToBounds = true

        contentView.addSubview(avatarImageView)
        contentView.addSubview(bubbleContainer)
        contentView.addSubview(readStatusLabel)


        readStatusLabel.font = UIFont.systemFont(ofSize: 12)
        readStatusLabel.translatesAutoresizingMaskIntoConstraints = false

        avatarLeading = avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15)
        avatarTrailing = avatarImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15)

        NSLayoutConstraint.activate([
            avatarImageView.widthAnchor.constraint(equalToConstant: avatarSize),
            avatarImageView.heightAnchor.constraint(equalToConstant: avatarSize),
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),

            bubbleContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),

            readStatusLabel.topAnchor.constraint(equalTo: bubbleContainer.bottomAnchor, constant: 5),
            readStatusLabel.trailingAnchor.constraint(equalTo: bubbleContainer.trailingAnchor),
            readStatusLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])

        let initialCap = bubbleContainer.widthAnchor.constraint(lessThanOrEqualToConstant: bubbleMaxWidth)
        initialCap.isActive = true

        // default outgoing
        avatarTrailing.isActive = true

        readStatusLabel.textAlignment = .right
        
        largeImageView.contentMode = .scaleAspectFill;
        secondImageView.contentMode = .scaleAspectFill;
        thirdImageView.contentMode = .scaleAspectFill;
        
        contentView.addSubview(largeImageView);
        contentView.addSubview(secondImageView);
        contentView.addSubview(thirdImageView);

        contentView.layoutIfNeeded()
        contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapGesture(_:))))
    }
    
    weak var viewController:UIViewController?;

    @objc func tapGesture(_ gesture:UITapGestureRecognizer){
        
        guard let vc = viewController else { return ; }
        
        var index = 0;
        var sourceView = self.largeImageView;
        
        let location = gesture.location(in: self.contentView);
        if self.largeImageView.frame.contains(location) {
            index = 0;
        } else if self.secondImageView.frame.contains(location) {
            index = 1;
            sourceView = self.secondImageView;
        }
        else if self.thirdImageView.frame.contains(location) {
            index = 2;
            sourceView = self.thirdImageView;
        }
        
        let imageCarousel = PreviewViewController(
            sourceView: sourceView,
            imageDataSource: self,
            imageLoader: SDWebImageLoader(),
            options: [.theme(.light), .rightNavItemIcon(UIImage(), UIColor.black, onTap: { x in
                
            }), .closeIcon(UIImage(systemName: "arrowshape.turn.up.backward")!)],
            initialIndex: index)
        vc.present(imageCarousel, animated: true)
    }
    
    var images:[MediaItem] = [];
    
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageUrls = []
        loadedImages.removeAll() // 清空缓存，避免重用时混乱
        readStatusLabel.text = nil
        avatarImageView.image = nil
    }

    func configure(message:IMMessageType, avatar: UIImage?, readStatus: String?) {
        self.message = message;
        avatarImageView.image = avatar
        if avatar != nil { avatarImageView.backgroundColor = .clear }
        readStatusLabel.text = readStatus

        avatarLeading.isActive = false
        avatarTrailing.isActive = false

        if message.isOutgoing {
            avatarTrailing.isActive = true
            bubbleContainer.backgroundColor = UIColor(hex: "#C4D7F8")
        } else {
            avatarLeading.isActive = true
            bubbleContainer.backgroundColor = .white
        }

        // safe width
        let parentWidth: CGFloat = (contentView.bounds.width > 0) ? contentView.bounds.width : UIScreen.main.bounds.width
        let maxW = min(bubbleMaxWidth, parentWidth - (avatarSize + 15 + 12))
        
        let c = bubbleContainer.widthAnchor.constraint(lessThanOrEqualToConstant: maxW)
        c.isActive = true
        
        let maxHeight = UIScreen.main.bounds.height / 2.5;
        let maxWidth = UIScreen.main.bounds.width - avatarSize - 10 - 10 - 10;
        let screenWidth = UIScreen.main.bounds.width;
        let leftX:CGFloat = avatarSize + 10 + 10 + 10;
        
        var containerMaxSize = CGSize(width: maxWidth, height: maxHeight);

        self.largeImageView.frame = .zero;
        self.secondImageView.frame = .zero;
        self.thirdImageView.frame = .zero;
        if message.medias.count == 1 {
            
            if message.medias[0].height < containerMaxSize.height {
                containerMaxSize.height = message.medias[0].height;
            }
            
            let xs = AVMakeRect(aspectRatio: .init(width: message.medias[0].width, height: message.medias[0].height), insideRect: .init(origin: .zero, size: containerMaxSize));
            self.largeImageView.frame = .init(x: screenWidth - leftX - xs.width, y: 10, width: xs.width, height: xs.height)
            self.largeImageView.imageURL = message.medias[0].imageURL;
            self.largeImageView.setVideoSource(videoURL: message.medias[0].videoURL, audioEnabled: false);
            self.largeImageView.layer.cornerRadius = 12;
            self.largeImageView.clipsToBounds = true;
            
            self.images = message.medias;
            
        } else if message.medias.count == 2 {
            let image1 = message.medias[0];
            let image2 = message.medias[1];
            
            let width1 = image1.width;
            let height1 = image1.height;
            
            let height2 = image1.height;
            let width2 = image2.width * height2 / image2.height;
            
            if height2 < containerMaxSize.height {
                containerMaxSize.height = height2;
            }
            let sw = image1.width + width2;
            let sh = height2;
            let xs = AVMakeRect(aspectRatio: .init(width: sw, height: sh), insideRect: .init(origin: .zero, size: containerMaxSize));
            
            self.largeImageView.frame = .init(x: screenWidth - leftX - (xs.width), y: 10, width: width1 / sw * (xs.width), height: xs.height)
            self.largeImageView.imageURL = message.medias[0].imageURL;
            self.largeImageView.setVideoSource(videoURL: message.medias[0].videoURL, audioEnabled: false);
            self.largeImageView.layer.cornerRadius = 12;
            self.largeImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
            self.largeImageView.clipsToBounds = true;
            
            self.secondImageView.frame = .init(x:  self.largeImageView.frame.maxX, y: 10, width: width2 / sw * (xs.width), height: xs.height)
            self.secondImageView.imageURL = message.medias[1].imageURL;
            self.secondImageView.setVideoSource(videoURL: message.medias[1].videoURL, audioEnabled: false);
            self.secondImageView.layer.cornerRadius = 12;
            self.secondImageView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
            self.secondImageView.clipsToBounds = true;
            
            self.images = message.medias;
            
        } else if message.medias.count == 3 {
            
            var maxRatioIndex = 0;
            var ratio = 0.0;
            
            for (index, item) in message.medias.enumerated() {
                if item.height / item.width > ratio {
                    ratio = item.height / item.width;
                    maxRatioIndex = index;
                }
            }
            var ccs = Array(repeating: MediaItem(), count: 3);
            if maxRatioIndex == 0 {
                ccs[0] = message.medias[0];
                ccs[1] = message.medias[1];
                ccs[2] = message.medias[2];
            } else if maxRatioIndex == 1 {
                ccs[0] = message.medias[1];
                ccs[1] = message.medias[0];
                ccs[2] = message.medias[2];
            } else {
                ccs[0] = message.medias[2];
                ccs[1] = message.medias[0];
                ccs[2] = message.medias[1];
            }
         
            let height0 = ccs[0].height;
            let width0 = ccs[0].width;
            
            let height_1:CGFloat = height0 * (ccs[1].height/(ccs[1].height + ccs[2].height));
            let height_2:CGFloat = height0 * (ccs[2].height/(ccs[1].height + ccs[2].height));
            
            var width_1:CGFloat = height_1 * ccs[1].width/ccs[1].height;
            var width_2:CGFloat = height_2 * ccs[2].width/ccs[2].height;
            
            if width_1 > width_2 {
                width_1 = width_2;
            }
            else {
                width_2 = width_1;
            }
            
            let sw = width0 + width_2;
            let sh = height0;
            let xs = AVMakeRect(aspectRatio: .init(width: sw, height: sh), insideRect: .init(origin: .zero, size: containerMaxSize));
            
            let image1 = ccs[0];
            let image2 = ccs[1];
            let image3 = ccs[2];
            
            self.images = ccs;
            
            self.largeImageView.frame = .init(x: screenWidth - leftX - (xs.width), y: 10, width: image1.width / sw * (xs.width), height: xs.height)
            self.largeImageView.imageURL = image1.imageURL;
            self.largeImageView.setVideoSource(videoURL: image1.videoURL, audioEnabled: false);
            self.largeImageView.layer.cornerRadius = 12;
            self.largeImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
            self.largeImageView.clipsToBounds = true;
            
            self.secondImageView.frame = .init(x:  self.largeImageView.frame.maxX, y: 10, width: (1 - image1.width / sw) * (xs.width), height: xs.height * height_1/(height_1+height_2))
            self.secondImageView.imageURL = image2.imageURL;
            self.secondImageView.setVideoSource(videoURL: image2.videoURL, audioEnabled: false);
            self.secondImageView.layer.cornerRadius = 12;
            self.secondImageView.layer.maskedCorners = [.layerMaxXMinYCorner]
            self.secondImageView.clipsToBounds = true;
            
            self.thirdImageView.frame = .init(x:  self.largeImageView.frame.maxX, y: self.secondImageView.frame.maxY, width: (1 - image1.width / sw) * (xs.width), height: xs.height*height_2/(height_1+height_2))
            self.thirdImageView.imageURL = image3.imageURL;
            self.thirdImageView.setVideoSource(videoURL: image3.videoURL, audioEnabled: false);
            self.thirdImageView.layer.cornerRadius = 12;
            self.thirdImageView.layer.maskedCorners = [.layerMaxXMaxYCorner]
            self.thirdImageView.clipsToBounds = true;
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    // 查找父 UITableView
    private func enclosingTableView() -> UITableView? {
        var v: UIView? = self
        while let view = v {
            if let table = view as? UITableView { return table }
            v = view.superview
        }
        return nil
    }
}

