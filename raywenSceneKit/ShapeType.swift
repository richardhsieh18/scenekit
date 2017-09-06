//
//  ShapeType.swift
//  raywenSceneKit
//
//  Created by chang on 2017/9/6.
//  Copyright © 2017年 chang. All rights reserved.
//

import Foundation

enum ShapeType: Int {
    case box = 0
    case sphere
    case pyramid
    case torus
    case capsule
    case cylinder
    case cone
    case tube
    
    static func random() -> ShapeType {
        let maxValue = tube.rawValue
        let rand = arc4random_uniform(UInt32(maxValue+1))
        return ShapeType(rawValue: Int(rand))!
    }
}
