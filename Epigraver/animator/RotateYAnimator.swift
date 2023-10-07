//
//  Created by Robert Beeger on 22.09.18.
//  Copyright © 2018 Robert Beeger. All rights reserved.
//

import Foundation
import AppKit

class RotateYAnimator: Animator {
    private var boxes: [NSBox]?
    private var timingFunction: CAMediaTimingFunction?

    let typeName = "Rotate Y"

    func setup(boxes: [NSBox], with timingFunction: CAMediaTimingFunction) {
        boxes[1].alphaValue = 0.0

        self.boxes = boxes
        self.timingFunction = timingFunction
    }

    func animate(nextActiveIndex: Int) {
        guard let boxes = self.boxes else {
            return
        }
        let currentlyActiveIndex = 1 - nextActiveIndex

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 5
            context.timingFunction = timingFunction ?? CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
            context.allowsImplicitAnimation = true
            boxes[currentlyActiveIndex].layer?.transform = CATransform3DMakeRotation(1.3 * .pi, 0, 1, 0)
            boxes[currentlyActiveIndex].alphaValue = 0.0
            boxes[nextActiveIndex].layer?.transform = CATransform3DIdentity
            boxes[nextActiveIndex].alphaValue = 1.0
        }, completionHandler: {
            boxes[currentlyActiveIndex].layer?.transform = CATransform3DMakeRotation(1.4 * .pi, 0, 1, 0)
        })
    }
}
