//
//  Created by Robert Beeger on 22.09.18.
//  Copyright © 2018 Robert Beeger. All rights reserved.
//

import Foundation
import AppKit

class RotateAnimator: Animator {
    private var boxes: [NSBox]?

    let typeName = "Rotate"

    func setup(boxes: [NSBox], on view: NSView) {
        boxes[1].alphaValue = 0.0

        self.boxes = boxes
    }

    func animate(nextActiveIndex: Int) {
        guard let boxes = self.boxes else {
            return
        }
        let currentlyActiveIndex = 1 - nextActiveIndex

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 5
            context.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
            context.allowsImplicitAnimation = true
            boxes[currentlyActiveIndex].layer?.setAffineTransform(CGAffineTransform(rotationAngle: 1.7 * .pi))
            boxes[currentlyActiveIndex].alphaValue = 0.0
            boxes[nextActiveIndex].layer?.setAffineTransform(CGAffineTransform(rotationAngle: 0))
            boxes[nextActiveIndex].alphaValue = 1.0
        }, completionHandler: {
            boxes[currentlyActiveIndex].layer?.setAffineTransform(CGAffineTransform(rotationAngle: 0.3 * .pi))
        })
    }
}
