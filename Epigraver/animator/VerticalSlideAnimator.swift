//
//  Created by Robert Beeger on 22.09.18.
//  Copyright © 2018 Robert Beeger. All rights reserved.
//

import Foundation
import AppKit

class VerticalSlideAnimator: Animator {
    private weak var view: NSView?
    private var boxes: [NSBox]?
    private var timingFunction: CAMediaTimingFunction?
    private var firstFrame = true

    let typeName = "Vertical Slide"

    func setup(boxes: [NSBox], with timingFunction: CAMediaTimingFunction) {
        boxes[1].alphaValue = 0.0
        firstFrame = true

        self.boxes = boxes
        self.timingFunction = timingFunction
    }

    func animate(nextActiveIndex: Int) {
        guard let boxes = self.boxes else {
            return
        }
        let currentlyActiveIndex = 1 - nextActiveIndex
        let moveDistance = boxes[0].frame.height * (currentlyActiveIndex == 0 ? -1 : 1)

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 5
            context.timingFunction = timingFunction ?? CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
            context.allowsImplicitAnimation = true
            boxes[currentlyActiveIndex].layer!.transform = CATransform3DConcat(
                boxes[currentlyActiveIndex].layer!.transform,
                CATransform3DMakeTranslation(0, moveDistance, 0))
            boxes[currentlyActiveIndex].alphaValue = 0.0
            boxes[nextActiveIndex].layer!.transform =  CATransform3DConcat(
                boxes[nextActiveIndex].layer!.transform,
                CATransform3DMakeTranslation(0, firstFrame ? 0 :moveDistance, 0))
            boxes[nextActiveIndex].alphaValue = 1.0

            firstFrame = false
        }, completionHandler: {
        })
    }
}
