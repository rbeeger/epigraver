//
// Created by Robert Beeger on 2019-02-02.
// Copyright (c) 2019 Robert Beeger. All rights reserved.
//

import Foundation
import AppKit
import os

class CommandConfigurationViewController: NSViewController {
    private let nameColumnIdentifier = NSUserInterfaceItemIdentifier(rawValue: "nameColumn")
    private let pathColumnIdentifier = NSUserInterfaceItemIdentifier(rawValue: "pathColumn")
    private let argumentsColumnIdentifier = NSUserInterfaceItemIdentifier(rawValue: "argumentsColumn")

    private lazy var table: NSTableView = {
        let view = NSTableView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        view.dataSource = self

        let nameColumn = NSTableColumn(identifier: nameColumnIdentifier)
        nameColumn.title = "Name"
        nameColumn.width = 70
        view.addTableColumn(nameColumn)

        let pathColumn = NSTableColumn(identifier: pathColumnIdentifier)
        pathColumn.title = "Path"
        pathColumn.width = 200
        view.addTableColumn(pathColumn)

        let argumentsColumn = NSTableColumn(identifier: argumentsColumnIdentifier)
        argumentsColumn.title = "Arguments"
        argumentsColumn.width = 180
        view.addTableColumn(argumentsColumn)

        return view
    }()

    private var commandConfigurations: [Configuration.Command] = []

    init() {
        super.init(nibName: nil, bundle: nil)
        self.title = "Commands"

        commandConfigurations.append(Configuration.Command(name: "fortune", path: "/usr/local/bin/fortune", arguments: ""))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        os_log("######  view did load 0")

        view.addSubview(table)

        table.topAnchor.constraint(equalTo: view.topAnchor, constant: 8).isActive = true
        table.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8).isActive = true
        table.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8).isActive = true
        table.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8).isActive = true
    }

    override func loadView() {
        view = NSView()
    }
}

extension CommandConfigurationViewController: NSTableViewDataSource {
    public func numberOfRows(in tableView: NSTableView) -> Int {
        return commandConfigurations.count
    }

    public func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        let command = commandConfigurations[row]
        switch tableColumn?.identifier {
        case nameColumnIdentifier : return command.name
        case pathColumnIdentifier : return command.path
        case argumentsColumnIdentifier : return command.arguments
        default: return ""
        }
    }

    public func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
        var command = commandConfigurations[row]
        let valueString = object as? String ?? ""

        switch tableColumn?.identifier {
        case nameColumnIdentifier : command.name = valueString
        case pathColumnIdentifier : command.path = valueString
        case argumentsColumnIdentifier : command.arguments = valueString
        default: break
        }

        commandConfigurations[row] = command
    }
}

extension CommandConfigurationViewController: NSTableViewDelegate {

}
