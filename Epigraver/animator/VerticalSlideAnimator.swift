//
//  Created by Robert Beeger on 22.09.18.
//  Copyright © 2018 Robert Beeger. All rights reserved.
//

import Foundation
import AppKit

class VerticalSlideAnimator: Animator {
    private var animationConstraints: [NSLayoutConstraint] = []
    private weak var view: NSView?
    private var boxes: [NSBox]?

    func setup(boxes: [NSBox], on view: NSView) {
        boxes[0].widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.0).isActive = true
        boxes[0].heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1.0).isActive = true
        boxes[0].centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        animationConstraints.append(boxes[0].centerYAnchor.constraint(equalTo: view.centerYAnchor))
        animationConstraints[0].isActive = true

        boxes[1].widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.0).isActive = true
        boxes[1].heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1.0).isActive = true
        boxes[1].centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        animationConstraints.append(boxes[1].centerYAnchor.constraint(equalTo: view.centerYAnchor,
                                                                      constant: -(NSScreen.main?.frame.height ?? 1000)))
        animationConstraints[1].isActive = true

        boxes[1].alphaValue = 0.0
        self.view = view
        self.boxes = boxes
    }

    func animate(nextActiveIndex: Int) {
        guard let boxes = self.boxes, let view = self.view else {
            return
        }
        let moveDistance = NSScreen.main?.frame.height ?? 1000

        let currentlyActiveIndex = 1 - nextActiveIndex

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 5
            context.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
            context.allowsImplicitAnimation = true
            boxes[nextActiveIndex].alphaValue = 1.0
            boxes[currentlyActiveIndex].alphaValue = 0.0
            animationConstraints[nextActiveIndex].constant = 0.0
            animationConstraints[currentlyActiveIndex].constant = currentlyActiveIndex == 0
                    ? moveDistance
                    : -moveDistance
            view.layoutSubtreeIfNeeded()
        }, completionHandler: {
        })
    }
}
