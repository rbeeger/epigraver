//
// Created by Robert Beeger on 06.10.19.
// Copyright (c) 2019 Robert Beeger. All rights reserved.
//

import Foundation
import AppKit

class AppearanceListCell: NSView {
    private lazy var fontLabel: NSTextField = {
        let field = NSTextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.isEditable = false
        field.isSelectable = false
        field.font = NSFont.systemFont(ofSize: 14)
        field.isBordered = false
        field.backgroundColor = .clear
        field.textColor = .black
        field.alignment = .center
        field.lineBreakMode = .byWordWrapping

        return field
    }()

    private lazy var backgroundBox: NSBox = {
        let box = NSBox()
        box.translatesAutoresizingMaskIntoConstraints = false
        box.boxType = .custom
        box.borderWidth = 1
        box.cornerRadius = 5
        box.borderColor = .black
        box.titlePosition = .noTitle

        return box
    }()

    var appearanceConfiguration: Appearance? {
        didSet {
            guard let appearanceConfiguration = appearanceConfiguration else {
                fontLabel.stringValue = ""
                fontLabel.textColor = .black
                backgroundBox.fillColor = .white
                return
            }
            fontLabel.stringValue = "\(appearanceConfiguration.fontName) \(Int(appearanceConfiguration.fontSize))"
            fontLabel.textColor = appearanceConfiguration.foregroundNSColor

            backgroundBox.fillColor = appearanceConfiguration.backgroundNSColor
        }
    }

    init(numberOfLines: Int) {
        super.init(frame: .zero)

        fontLabel.maximumNumberOfLines = numberOfLines

        addSubview(backgroundBox)
        addSubview(fontLabel)

        backgroundBox.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        backgroundBox.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8).isActive = true
        backgroundBox.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8).isActive = true
        backgroundBox.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8).isActive = true

        fontLabel.leadingAnchor.constraint(equalTo: backgroundBox.leadingAnchor, constant: 2).isActive = true
        fontLabel.trailingAnchor.constraint(equalTo: backgroundBox.trailingAnchor, constant: -2).isActive = true
        fontLabel.centerYAnchor.constraint(equalTo: backgroundBox.centerYAnchor).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
