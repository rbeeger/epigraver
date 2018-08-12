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
    private let textDisplay: NSTextField

    override init?(frame: NSRect, isPreview: Bool) {
        textDisplay = NSTextField()
        super.init(frame: frame, isPreview: isPreview)
        
        animationTimeInterval = 60
        
        let box = NSBox()
        box.boxType = .custom
        box.fillColor = NSColor(red:0.118, green:0.29, blue: 0.365, alpha:  1)
        
        box.translatesAutoresizingMaskIntoConstraints = false
        addSubview(box)
        box.topAnchor.constraint(equalTo: topAnchor).isActive = true
        box.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        box.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        box.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        addSubview(textDisplay)
        textDisplay.translatesAutoresizingMaskIntoConstraints = false
        textDisplay.isEditable = false
        textDisplay.isSelectable = false
        textDisplay.textColor = NSColor(red:0.97, green:0.96, blue:0.88, alpha:1.00)
        textDisplay.backgroundColor = box.fillColor
        textDisplay.drawsBackground = true
        textDisplay.isBordered = false
        textDisplay.isBezeled = false
        textDisplay.maximumNumberOfLines = 40
        textDisplay.font = NSFont(name: "Hoefler Text", size: 25)

        textDisplay.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        textDisplay.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        textDisplay.widthAnchor.constraint(equalToConstant: 1000).isActive = true
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func animateOneFrame() {
        let task = Process()
        task.launchPath = "/usr/local/bin/fortune"
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: String.Encoding.utf8)!
        textDisplay.attributedStringValue = NSAttributedString(string: output)

        super.animateOneFrame()
    }
}
