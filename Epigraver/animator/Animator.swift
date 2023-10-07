//
//  Created by Robert Beeger on 22.09.18.
//  Copyright © 2018 Robert Beeger. All rights reserved.
//

import Foundation
import AppKit

protocol Animator {
    func setup(boxes: [NSBox], with timingFunction: CAMediaTimingFunction)
    func animate(nextActiveIndex: Int)
    var typeName: String { get }
}
