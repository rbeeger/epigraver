//
//  Created by Robert Beeger on 12.08.18.
//  Copyright © 2018 Robert Beeger. All rights reserved.
//

import Foundation
import ScreenSaver
import os

class Main: ScreenSaverView {
    private let textDisplays: [NSTextField]
    private var textDisplayBoxes: [NSBox]
    private var current: Int

    var selectedAppearance: Appearance!
    var selectedAnimator: Animator!
    var selectedCommand: String!

    override init?(frame: NSRect, isPreview: Bool) {
        textDisplays = [NSTextField(), NSTextField()]
        textDisplayBoxes = [NSBox(), NSBox()]
        current = 0

        // Need to do preview detection ourselves beecause isPreview is always true on Cataline
        // Found in https://github.com/JohnCoates/Aerial
        super.init(frame: frame, isPreview: frame.width < 400 && frame.height < 300)

        selectConfiguration()

        wantsLayer = true

        let backgroundBox = NSBox()
        backgroundBox.translatesAutoresizingMaskIntoConstraints = false
        backgroundBox.boxType = .custom
        backgroundBox.borderWidth = 0.0
        backgroundBox.fillColor = selectedAppearance.backgroundNSColor

        addSubview(backgroundBox)

        backgroundBox.topAnchor.constraint(equalTo: topAnchor).isActive = true
        backgroundBox.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        backgroundBox.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        backgroundBox.rightAnchor.constraint(equalTo: rightAnchor).isActive = true

        configureDisplay(index: 0)
        configureDisplay(index: 1)

        let timingFunction = CAMediaTimingFunction(
            controlPoints: 0.25, .random(in: 0.2...1.0), 0.75, .random(in: 0.2...1.0))
        selectedAnimator.setup(boxes: textDisplayBoxes, with: timingFunction)

        if !isPreview {
            // https://www.jwz.org/blog/2023/10/xscreensaver-6-08-out-now/
            DistributedNotificationCenter.default.addObserver(
                self,
                selector: #selector(willStop),
                name: Notification.Name("com.apple.screensaver.willstop"), object: nil
            )
        }
    }

    @objc func willStop() {
        NSApplication.shared.terminate(self)
    }

    func resetAnimator(animator: Animator) {
        stopAnimation()

        current = 0

        textDisplayBoxes[0].removeFromSuperview()
        textDisplayBoxes[1].removeFromSuperview()

        textDisplayBoxes = [NSBox(), NSBox()]

        configureDisplay(index: 0)
        configureDisplay(index: 1)

        selectedAnimator = animator
        let timingFunction = CAMediaTimingFunction(
            controlPoints: 0.25, .random(in: 0.2...1.0), 0.75, .random(in: 0.2...1.0))
        selectedAnimator.setup(boxes: textDisplayBoxes, with: timingFunction)

        startAnimation()
    }

    func selectConfiguration() {
        let configurationSelector = ConfigurationSelector()
        selectedAppearance = configurationSelector.appearances.randomElement()!
        selectedAnimator = configurationSelector.animators.randomElement()!
        selectedCommand = configurationSelector.command
        animationTimeInterval = isPreview ? 10 : configurationSelector.animationInterval
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureDisplay(index: Int) {
        let box = textDisplayBoxes[index]
        addSubview(box)

        box.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1.0).isActive = true
        box.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1.0).isActive = true
        box.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        box.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true

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
        if isPreview {
            textDisplay.font = NSFont(name: "HoeflerText-Regular", size: 13)
        } else {
            textDisplay.font = NSFont(name: selectedAppearance.fontName, size: selectedAppearance.fontSize)
        }

        textDisplay.centerYAnchor.constraint(equalTo: box.centerYAnchor).isActive = true
        textDisplay.centerXAnchor.constraint(equalTo: box.centerXAnchor).isActive = true
        textDisplay.widthAnchor.constraint(equalTo: box.widthAnchor, multiplier: 0.8).isActive = true
    }

    override var hasConfigureSheet: Bool {
        true
    }
    override var configureSheet: NSWindow? {
        ConfigurationSheet.shared
    }

    let previewEpigraphs = [
        "Do or do not, there is no try.\n-- Yoda",
        "To be, or not to be: that is the question.\n-- Hamlet",
        "Revenge is a dish best served cold\n-- Klingon proverb"
    ]

    override func animateOneFrame() {
        let output = nextOutput()
        let next = 1 - current
        textDisplays[next].attributedStringValue = NSAttributedString(string: output)

        selectedAnimator.animate(nextActiveIndex: next)
        self.current = next

        super.animateOneFrame()
    }

    func nextOutput() -> String {
        let output: String
        if isPreview {
            output = previewEpigraphs.randomElement()!
        } else {
            let task = Process()
            task.launchPath = "/bin/zsh"
            task.arguments = ["-c", selectedCommand]
            let pipe = Pipe()
            task.standardOutput = pipe
            task.standardError = pipe
            task.launch()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            output = String(data: data, encoding: String.Encoding.utf8)!
        }
        return output
    }
}
