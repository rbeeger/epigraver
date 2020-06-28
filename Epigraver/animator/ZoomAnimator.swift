//
//  Created by Robert Beeger on 22.09.18.
//  Copyright © 2018 Robert Beeger. All rights reserved.
//

import Foundation
import AppKit

class ZoomAnimator: Animator {
    private var boxes: [NSBox]?

    let typeName = "Zoom"

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
            boxes[currentlyActiveIndex].layer?.setAffineTransform(CGAffineTransform(scaleX: 1.7, y: 1.7))
            boxes[currentlyActiveIndex].alphaValue = 0.0
            boxes[nextActiveIndex].layer?.setAffineTransform(CGAffineTransform(scaleX: 1.0, y: 1.0))
            boxes[nextActiveIndex].alphaValue = 1.0
        }, completionHandler: {
            boxes[currentlyActiveIndex].layer?.setAffineTransform(CGAffineTransform(scaleX: 0.3, y: 0.3))
        })
    }
}
