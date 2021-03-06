//
// Created by Robert Beeger on 06.10.19.
// Copyright (c) 2019 Robert Beeger. All rights reserved.
//

import Foundation
import AppKit
import os

class GenericTextListCell: NSTableCellView {
    private lazy var label: NSTextField = {
        let field = NSTextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.isEditable = false
        field.isSelectable = false
        field.font = NSFont.systemFont(ofSize: 14)
        field.isBordered = false
        field.backgroundColor = .clear
        field.textColor = .black
        field.maximumNumberOfLines = 1
        field.alignment = .left

        return field
    }()

    var text: String {
        didSet {
            label.stringValue = text
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
        self.text = ""
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
