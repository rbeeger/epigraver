//
// Created by Robert Beeger on 06.10.19.
// Copyright (c) 2019 Robert Beeger. All rights reserved.
//

import Foundation
import AppKit
import os

class ScheduleListCell: NSTableCellView {
    private lazy var label: NSTextField = {
        let field = NSTextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.isEditable = false
        field.isSelectable = false
        field.font = NSFont.systemFont(ofSize: 12)
        field.isBordered = false
        field.backgroundColor = .clear
        field.textColor = .black
        field.maximumNumberOfLines = 0
        field.alignment = .center
        field.lineBreakMode = .byWordWrapping

        return field
    }()

    var scheduleEntryConfiguration: Configuration.ScheduleEntry? {
        didSet {
            guard let scheduleEntryConfiguration = scheduleEntryConfiguration else {
                label.stringValue = ""
                return
            }

            var labelText = Configuration.shared.calendar.veryShortStandaloneWeekdaySymbols.enumerated()
                    .map({scheduleEntryConfiguration.weekdays.contains($0.offset) ? $0.element : "-"})
                    .joined(separator: " ") +
                    "\n"

            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .none
            dateFormatter.timeStyle = .short
            labelText += dateFormatter.string(from: scheduleEntryConfiguration.from.date) +
                    " - " +
                    dateFormatter.string(from: scheduleEntryConfiguration.to.date) +
                    "\n"
            labelText += Configuration.shared.commands
                    .first(where: {$0.id == scheduleEntryConfiguration.commandId})?.name ?? "no command"
            label.stringValue = labelText
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
