//
// Created by Robert Beeger on 2018-11-11.
// Copyright (c) 2018 Robert Beeger. All rights reserved.
//

import Foundation
import AppKit
import os

class ConfigurationSheet: NSWindow {
    static let shared = ConfigurationSheet()

    private lazy var tabView: NSTabView = {
        let view = NSTabView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTabViewItem(NSTabViewItem(viewController: ScheduleConfigurationViewController()))
        view.addTabViewItem(NSTabViewItem(viewController: CommandConfigurationViewController()))
        view.addTabViewItem(NSTabViewItem(viewController: AppearanceConfigurationViewController()))

        return view
    }()

    private lazy var okButton: NSButton = {
        let button = NSButton(title: "OK", target: self, action: #selector(confirmChanges))
        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()

    private lazy var cancelButton: NSButton = {
        let button = NSButton(title: "Cancel", target: self, action: #selector(cancelChanges))
        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()

    init() {
        super.init(contentRect: NSRect(x: 0, y: 0, width: 750, height: 500),
                styleMask: [], backing: .buffered, defer: false)

        self.isReleasedWhenClosed = false

        let view = self.contentView!
        view.wantsLayer = true

        view.addSubview(tabView)
        view.addSubview(okButton)
        view.addSubview(cancelButton)

        tabView.topAnchor.constraint(equalTo: view.topAnchor, constant: 8).isActive = true
        tabView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8).isActive = true
        tabView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8).isActive = true
        tabView.bottomAnchor.constraint(equalTo: okButton.topAnchor, constant: -8).isActive = true

        okButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8).isActive = true
        okButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8).isActive = true

        cancelButton.centerYAnchor.constraint(equalTo: okButton.centerYAnchor).isActive = true
        cancelButton.trailingAnchor.constraint(equalTo: okButton.leadingAnchor, constant: -8).isActive = true

        Configuration.shared.load()
    }

    @objc
    func confirmChanges() {
        guard let parent = sheetParent else {
            fatalError("No parent")
        }
        Configuration.shared.save()
        parent.endSheet(self)
    }

    @objc
    func cancelChanges() {
        guard let parent = sheetParent else {
            fatalError("No parent")
        }
        Configuration.shared.load()
        parent.endSheet(self)
    }
}
