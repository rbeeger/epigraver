//
//  Created by Robert Beeger on 28.06.20.
//  Copyright © 2020 Robert Beeger. All rights reserved.
//

import Foundation
import AppKit

class PulseAnimator: Animator {
    private var boxes: [NSBox]?

    let typeName = "Pulse"

    func setup(boxes: [NSBox], on view: NSView) {
        boxes[1].alphaValue = 0.0

        self.boxes = boxes
    }

    func animate(nextActiveIndex: Int) {
        guard let boxes = self.boxes else {
            return
        }
        let currentlyActiveIndex = 1 - nextActiveIndex
        let xTranslate = boxes[0].frame.width / 6
        let yTranslate = boxes[0].frame.height * 20

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 5
            context.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
            context.allowsImplicitAnimation = true
            boxes[currentlyActiveIndex].layer?.transform = CATransform3DConcat(
                CATransform3DMakeTranslation(-xTranslate, yTranslate, 0),
                CATransform3DMakeScale(6, 0.02, 1))
            boxes[currentlyActiveIndex].alphaValue = 0.0
            boxes[nextActiveIndex].layer?.transform = CATransform3DIdentity
            boxes[nextActiveIndex].alphaValue = 1.0
        }, completionHandler: {
            boxes[currentlyActiveIndex].layer?.transform = CATransform3DConcat(
                CATransform3DMakeTranslation(-xTranslate, yTranslate, 0),
                CATransform3DMakeScale(6, 0.02, 1))
        })
    }
}
