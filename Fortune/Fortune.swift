//
//  Fortune.swift
//  Fortune
//
//  Created by Robert Beeger on 12.08.18.
//  Copyright © 2018 Robert Beeger. All rights reserved.
//

import Foundation
import ScreenSaver

class Fortune: ScreenSaverView {
    private var textDisplays: [NSTextField]
    private var boxes: [NSBox]
    private var xConstraints: [NSLayoutConstraint]
    private var current: Int

    override init?(frame: NSRect, isPreview: Bool) {
        textDisplays = [NSTextField(), NSTextField()]
        boxes = [NSBox(), NSBox()]
        xConstraints = []
        current = 0
        super.init(frame: frame, isPreview: isPreview)

        wantsLayer = true
        animationTimeInterval = 60

        let box = NSBox()
        box.boxType = .custom
        box.borderWidth = 0.0
        box.fillColor = NSColor(red:0.118, green:0.29, blue: 0.365, alpha:  1)

        box.translatesAutoresizingMaskIntoConstraints = false
        addSubview(box)
        box.topAnchor.constraint(equalTo: topAnchor).isActive = true
        box.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        box.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        box.rightAnchor.constraint(equalTo: rightAnchor).isActive = true

        addSubview(boxes[0])
        addSubview(boxes[1])
        configureDisplay(index: 0)
        configureDisplay(index: 1)
        boxes[1].alphaValue = 0.0
        xConstraints.append(boxes[0].centerXAnchor.constraint(equalTo: self.centerXAnchor))
        xConstraints[0].isActive = true
        xConstraints.append(boxes[1].centerXAnchor.constraint(equalTo: self.centerXAnchor,
                constant: -(NSScreen.main()?.frame.width ?? 1000)))
        xConstraints[1].isActive = true
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureDisplay(index: Int) {
        let box = boxes[index]
        let textDisplay = textDisplays[index]

        box.translatesAutoresizingMaskIntoConstraints = false
        box.boxType = .custom
        box.fillColor = .clear
        box.borderColor = .clear
        box.borderWidth = 0.0

        box.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1.0).isActive = true
        box.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1.0).isActive = true
        box.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true

        box.addSubview(textDisplay)

        textDisplay.translatesAutoresizingMaskIntoConstraints = false
        textDisplay.isEditable = false
        textDisplay.isSelectable = false
        textDisplay.textColor = NSColor(red:0.97, green:0.96, blue:0.88, alpha:1.00)
        textDisplay.backgroundColor = .clear
        textDisplay.drawsBackground = true
        textDisplay.isBordered = false
        textDisplay.isBezeled = false
        textDisplay.maximumNumberOfLines = 40
        textDisplay.font = NSFont(name: "Hoefler Text", size: 25)

        textDisplay.centerYAnchor.constraint(equalTo: box.centerYAnchor).isActive = true
        textDisplay.centerXAnchor.constraint(equalTo: box.centerXAnchor).isActive = true
        textDisplay.widthAnchor.constraint(equalToConstant: 1000).isActive = true
    }
    
    override func animateOneFrame() {
        let task = Process()
        task.launchPath = "/usr/local/bin/fortune"
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: String.Encoding.utf8)!
        let next = 1 - current
        textDisplays[next].attributedStringValue = NSAttributedString(string: output)

        let moveDistance = NSScreen.main()?.frame.width ?? 1000

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 5
            context.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            context.allowsImplicitAnimation = true
            boxes[next].alphaValue = 1.0
            boxes[current].alphaValue = 0.0
            xConstraints[next].constant = 0.0
            xConstraints[current].constant = current == 0 ? moveDistance : -moveDistance
            layoutSubtreeIfNeeded()
        }, completionHandler: {
            self.current = next
        })

        super.animateOneFrame()
    }
}
