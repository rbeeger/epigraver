//
//  Created by Robert Beeger on 04.07.20.
//  Copyright © 2020 Robert Beeger. All rights reserved.
//

import Foundation
import AppKit

class RotateZoomedAnimator: Animator {
    private var boxes: [NSBox]?

    let typeName = "Rotate Zoomed"

    func setup(boxes: [NSBox], on view: NSView) {
        boxes[1].alphaValue = 0.0

        self.boxes = boxes
    }

    func animate(nextActiveIndex: Int) {
        guard let boxes = self.boxes else {
            return
        }
        let currentlyActiveIndex = 1 - nextActiveIndex

        boxes[0].layer?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        boxes[1].layer?.anchorPoint = CGPoint(x: 0.5, y: 0.5)

        let translation = CATransform3DMakeTranslation(boxes[0].frame.width / 2, boxes[0].frame.height / 2, 0)

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 5
            context.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
            context.allowsImplicitAnimation = true
            boxes[currentlyActiveIndex].layer?.transform = CATransform3DConcat(
                CATransform3DConcat(
                    CATransform3DMakeRotation(1.4 * .pi, 0, 0, 1),
                    CATransform3DMakeScale(5.3, 5.3, 1.0)),
                translation)
            boxes[currentlyActiveIndex].alphaValue = 0.0
            boxes[nextActiveIndex].layer?.transform = translation
            boxes[nextActiveIndex].alphaValue = 1.0
        }, completionHandler: {
            boxes[currentlyActiveIndex].layer?.transform = CATransform3DConcat(
                CATransform3DConcat(
                    CATransform3DMakeRotation(0.3 * .pi, 0, 0, 1),
                    CATransform3DMakeScale(0.1, 0.1, 1.0)),
                translation)
        })
    }
}
