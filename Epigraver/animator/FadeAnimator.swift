//
//  Created by Robert Beeger on 28.06.20.
//  Copyright © 2020 Robert Beeger. All rights reserved.
//

import Foundation
import AppKit

class FadeAnimator: Animator {
    private weak var view: NSView?
    private var boxes: [NSBox]?

    let typeName = "Fade"

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
            boxes[currentlyActiveIndex].alphaValue = 0.0
            boxes[nextActiveIndex].alphaValue = 1.0

        }, completionHandler: {
        })
    }
}
