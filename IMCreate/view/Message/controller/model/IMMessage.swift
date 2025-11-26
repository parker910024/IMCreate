//
//  IMMessage.swift
//  IMCreate
//
//  Created by mac密码1234 on 2025/11/25.
//


import Foundation

struct IMMessageType {
    var text: String?
    var img:Bool?
    var imageUrls: [URL]?
    var isOutgoing: Bool
    
    var medias:[MediaItem] = [];
    

    init(text: String, isOutgoing: Bool = true) {
        self.text = text
        self.imageUrls = nil
        self.isOutgoing = isOutgoing
    }
    init(imageUrls: [URL], isOutgoing: Bool = true) {
        self.text = nil
        self.imageUrls = imageUrls
        self.isOutgoing = isOutgoing
    }
    
    
    init(medias:[MediaItem], isOutgoing: Bool = true) {
        self.medias = medias;
        self.isOutgoing = isOutgoing;
    }
    
}
