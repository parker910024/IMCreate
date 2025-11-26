//
//  IMMessageModels.swift
//  IMCreate
//
//  Created by admin on 2025/11/24.
//

import Foundation
import UIKit


struct IMMiniApp {
    let id: String
    let name: String
    let color: UIColor
}

struct IMMessage {
    let id: String
    let name: String
    let lastText: String
    let timeText: String
    let avatarColor: UIColor
}
