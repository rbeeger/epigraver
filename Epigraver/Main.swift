//
//  Created by Robert Beeger on 12.08.18.
//  Copyright © 2018 Robert Beeger. All rights reserved.
//

import Foundation
import ScreenSaver
import os

class Main: ScreenSaverView {
    private let textDisplays: [NSTextField]
    private let boxes: [NSBox]
    private var current: Int

    private let selectedAppearance: Configuration.Appearance
    private let selectedAnimator: Animator
    private let selectedCommand: String

    override init?(frame: NSRect, isPreview: Bool) {
        textDisplays = [NSTextField(), NSTextField()]
        boxes = [NSBox(), NSBox()]
        current = 0

        let configurationSelector = ConfigurationSelector()
        selectedAppearance = configurationSelector.appearances.randomElement()!
        selectedAnimator = configurationSelector.animators.randomElement()!
        selectedCommand = configurationSelector.command

        super.init(frame: frame, isPreview: isPreview)

        wantsLayer = true
        animationTimeInterval = 60

        let box = NSBox()
        box.boxType = .custom
        box.borderWidth = 0.0
        box.fillColor = selectedAppearance.backgroundNSColor

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

        selectedAnimator.setup(boxes: boxes, on: self)
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

        box.addSubview(textDisplay)

        textDisplay.translatesAutoresizingMaskIntoConstraints = false
        textDisplay.isEditable = false
        textDisplay.isSelectable = false
        textDisplay.textColor = selectedAppearance.foregroundNSColor
        textDisplay.backgroundColor = .clear
        textDisplay.drawsBackground = true
        textDisplay.isBordered = false
        textDisplay.isBezeled = false
        textDisplay.maximumNumberOfLines = 0
        textDisplay.font = NSFont(name: selectedAppearance.fontName, size: selectedAppearance.fontSize)

        textDisplay.centerYAnchor.constraint(equalTo: box.centerYAnchor).isActive = true
        textDisplay.centerXAnchor.constraint(equalTo: box.centerXAnchor).isActive = true
        textDisplay.widthAnchor.constraint(equalToConstant: 1000).isActive = true
    }

    override var hasConfigureSheet: Bool {
        true
    }
    override var configureSheet: NSWindow? {
        ConfigurationSheet.shared
    }

    override func animateOneFrame() {
        let task = Process()
        task.launchPath = "/bin/zsh"
        task.arguments = ["-c", selectedCommand]
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        task.launch()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: String.Encoding.utf8)!
        let next = 1 - current
        textDisplays[next].attributedStringValue = NSAttributedString(string: output)

        selectedAnimator.animate(nextActiveIndex: next)
        self.current = next

        super.animateOneFrame()
    }
}
