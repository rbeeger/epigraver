//
//  Created by Robert Beeger on 22.09.18.
//  Copyright © 2018 Robert Beeger. All rights reserved.
//

import Foundation
import AppKit

protocol Animator {
    func setup(boxes: [NSBox], on view: NSView)
    func animate(nextActiveIndex: Int)
    func typeName() -> String
}
 extension Animator {
     func typeName() -> String {
         String(describing: type(of: self))
     }
 }
