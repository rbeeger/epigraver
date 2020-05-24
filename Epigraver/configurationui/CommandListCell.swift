//
// Created by Robert Beeger on 06.10.19.
// Copyright (c) 2019 Robert Beeger. All rights reserved.
//

import Foundation
import AppKit
import os

class CommandListCell: NSTableCellView {
    private lazy var label: NSTextField = {
        let field = NSTextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.isEditable = false
        field.isSelectable = false
        field.font = NSFont.systemFont(ofSize: 14)
        field.isBordered = false
        field.backgroundColor = .clear
        field.textColor = .black
        field.maximumNumberOfLines = 2
        field.alignment = .left
        field.lineBreakMode = .byWordWrapping

        return field
    }()

    var commandConfiguration: Command? {
        didSet {
            guard let commandConfiguration = commandConfiguration else {
                label.stringValue = ""
                label.textColor = .black
                return
            }
            label.stringValue = commandConfiguration.name
        }
    }

    override var backgroundStyle: BackgroundStyle {
        didSet {
            switch backgroundStyle {
            case .normal, .lowered: label.textColor = .black
            case .emphasized, .raised: label.textColor = .white
            default: label.textColor = .black
            }
        }
    }

    init() {
        super.init(frame: .zero)

        addSubview(label)

        label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2).isActive = true
        label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2).isActive = true
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
