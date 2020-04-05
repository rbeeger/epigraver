//
// Created by Robert Beeger on 05.10.19.
// Copyright (c) 2019 Robert Beeger. All rights reserved.
//

import Foundation
import AppKit

extension NSColor {
    var hex: Int {
        return (Int)(redComponent * 255) << 16 | (Int)(greenComponent * 255) << 8 | (Int)(blueComponent * 255) << 0
    }

    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let red = CGFloat((hex >> 16) & 0xff) / 255.0
        let green = CGFloat((hex >> 8) & 0xff) / 255.0
        let blue = CGFloat(hex & 0xff) / 255.0
        self.init(deviceRed: red, green: green, blue: blue, alpha: alpha)
    }
}