//
// Created by Robert Beeger on 2019-02-02.
// Copyright (c) 2019 Robert Beeger. All rights reserved.
//

import Foundation
import AppKit
import os

class CommandConfigurationViewController: NSViewController {
    private let entryColumnIdentifier = NSUserInterfaceItemIdentifier(rawValue: "entryColumn")

    private lazy var table: NSTableView = {
        let view = NSTableView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.dataSource = self
        view.delegate = self

        let column = NSTableColumn(identifier: entryColumnIdentifier)
        column.title = ""
        column.width = 150
        column.isEditable = false
        view.addTableColumn(column)

        view.headerView = nil
        view.rowHeight = 55
        return view
    }()

    private lazy var tableScroller: NSScrollView = {
        let view = NSScrollView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.documentView = table
        return view
    }()

    private lazy var buttonBar: NSSegmentedControl = {
        let view = NSSegmentedControl(labels: ["+", "-"], trackingMode: .momentary, target: self, action: #selector(addOrRemoveCommand))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isContinuous = false

        return view
    }()

    private lazy var nameLabel: NSTextField = {
        let view = NSTextField(labelWithString: "Name")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alignment = .right

        return view
    }()

    private lazy var nameField: NSTextField = {
        let view = NSTextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alignment = .left
        view.isBordered = true
        view.target = self
        view.delegate = self

        return view
    }()

    private lazy var commandLabel: NSTextField = {
        let view = NSTextField(labelWithString: "Command")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alignment = .right

        return view
    }()

    private lazy var commandField: NSTextField = {
        let view = NSTextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alignment = .left
        view.isBordered = true
        view.delegate = self

        return view
    }()

    private lazy var previewTextDisplay: NSTextField = {
        let view = NSTextField(string: "Do or do not, there is no try.\n-- Yoda")
        view.translatesAutoresizingMaskIntoConstraints = false

        view.isEditable = false
        view.isSelectable = false
        view.textColor = NSColor(hex: Configuration.shared.appearances[0].foregroundColor)
        view.backgroundColor = .clear
        view.drawsBackground = true
        view.isBordered = false
        view.isBezeled = false
        view.alignment = .left
        view.lineBreakMode = .byWordWrapping

        return view
    }()

    private lazy var previewBox: NSBox = {
        let view = NSBox(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.titlePosition = .noTitle
        view.boxType = .custom
        view.borderColor = .black
        view.borderType = .lineBorder
        view.borderWidth = 1
        view.fillColor = NSColor(hex: Configuration.shared.appearances[0].backgroundColor)

        view.addSubview(previewTextDisplay)

        previewTextDisplay.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        previewTextDisplay.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8).isActive = true
        previewTextDisplay.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8).isActive = true

        previewTextDisplay.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        return view
    }()

    private lazy var testButton: NSButton = {
        let view = NSButton(title: "Test", target: self, action: #selector(test))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var entryBox: NSBox = {
        let box = NSBox(frame: .zero)
        box.translatesAutoresizingMaskIntoConstraints = false
        box.titlePosition = .noTitle

        box.addSubview(nameLabel)
        box.addSubview(nameField)
        box.addSubview(commandLabel)
        box.addSubview(commandField)
        box.addSubview(testButton)
        box.addSubview(previewBox)

        nameLabel.leadingAnchor.constraint(equalTo: box.leadingAnchor, constant: 8).isActive = true
        nameLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: nameField.centerYAnchor).isActive = true

        nameField.topAnchor.constraint(equalTo: box.topAnchor, constant: 8).isActive = true
        nameField.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 8).isActive = true
        nameField.trailingAnchor.constraint(equalTo: box.trailingAnchor, constant: -8).isActive = true

        commandLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor).isActive = true
        commandLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor).isActive = true
        commandLabel.centerYAnchor.constraint(equalTo: commandField.centerYAnchor).isActive = true

        commandField.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 8).isActive = true
        commandField.leadingAnchor.constraint(equalTo: nameField.leadingAnchor).isActive = true
        commandField.trailingAnchor.constraint(equalTo: nameField.trailingAnchor).isActive = true

        testButton.topAnchor.constraint(equalTo: commandField.bottomAnchor, constant: 16).isActive = true
        testButton.trailingAnchor.constraint(equalTo: box.trailingAnchor, constant: -8).isActive = true
        testButton.widthAnchor.constraint(equalToConstant: 200).isActive = true

        previewBox.topAnchor.constraint(equalTo: testButton.bottomAnchor, constant: 8).isActive = true
        previewBox.leadingAnchor.constraint(equalTo: box.leadingAnchor, constant: 8).isActive = true
        previewBox.trailingAnchor.constraint(equalTo: box.trailingAnchor, constant: -8).isActive = true
        previewBox.bottomAnchor.constraint(equalTo: box.bottomAnchor, constant: -8).isActive = true

        return box
    }()

    init() {
        super.init(nibName: nil, bundle: nil)
        self.title = "Commands"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        view.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(tableScroller)
        view.addSubview(buttonBar)
        view.addSubview(entryBox)

        tableScroller.topAnchor.constraint(equalTo: view.topAnchor, constant: 8).isActive = true
        tableScroller.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8).isActive = true
        tableScroller.widthAnchor.constraint(equalToConstant: 150).isActive = true

        buttonBar.topAnchor.constraint(equalTo: tableScroller.bottomAnchor, constant: 8).isActive = true
        buttonBar.leadingAnchor.constraint(equalTo: tableScroller.leadingAnchor).isActive = true
        buttonBar.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8).isActive = true

        entryBox.topAnchor.constraint(equalTo: view.topAnchor, constant: 8).isActive = true
        entryBox.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8).isActive = true
        entryBox.leadingAnchor.constraint(equalTo: tableScroller.trailingAnchor, constant: 8).isActive = true
        entryBox.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8).isActive = true

        view.widthAnchor.constraint(equalToConstant: 730).isActive = true
        view.heightAnchor.constraint(equalToConstant: 420).isActive = true

        changeUI(toEnabled: false)
    }

    override func loadView() {
        view = NSView()
    }

    override func viewWillAppear() {
        super.viewWillAppear()

        view.bottomAnchor.constraint(equalTo: view.superview!.bottomAnchor).isActive = true
        view.centerXAnchor.constraint(equalTo: view.superview!.centerXAnchor).isActive = true

        let selectedRow = min(Configuration.shared.commands.count - 1, max(0, table.selectedRow))
        table.reloadData()
        table.selectRowIndexes(IndexSet(integer: selectedRow), byExtendingSelection: false)
    }

    @objc func addOrRemoveCommand() {
        switch buttonBar.selectedSegment {
        case 0: addCommand()
        case 1: removeCommand()
        default: break
        }
    }

    private func addCommand() {
        Configuration.shared.commands.append(Configuration.Command(name: "new command", command: ""))
        table.reloadData()
        table.selectRowIndexes(IndexSet(integer: Configuration.shared.commands.count - 1), byExtendingSelection: false)
        table.scrollRowToVisible(Configuration.shared.commands.count - 1)
    }

    private func removeCommand() {
        guard table.selectedRow >= 0,
              table.selectedRow < Configuration.shared.commands.count,
              Configuration.shared.commands.count > 1
                else { return }

        let oldSelectedRow = table.selectedRow
        Configuration.shared.commands.remove(at: table.selectedRow)
        table.reloadData()
        let newSelectedRow = min(Configuration.shared.commands.count - 1, oldSelectedRow)
        table.selectRowIndexes(IndexSet(integer: newSelectedRow), byExtendingSelection: false)
        table.scrollRowToVisible(newSelectedRow)
    }

    @objc func test() {
        guard table.selectedRow >= 0 else {
            return
        }
        let currentConfig = Configuration.shared.commands[table.selectedRow]

        let task = Process()
        task.launchPath = "/bin/zsh"
        task.arguments = ["-c", currentConfig.command]
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        task.launch()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: String.Encoding.utf8)!
        previewTextDisplay.attributedStringValue = NSAttributedString(string: output)
    }

    private func changeUI(toEnabled enabled: Bool) {
        entryBox.alphaValue = enabled ? 1.0 : 0.4
        nameField.isEnabled = enabled
        commandField.isEnabled = enabled
        testButton.isEnabled = enabled
    }

    private func updateUI() {
        guard table.selectedRow >= 0 else {
            changeUI(toEnabled: false)
            return
        }
        changeUI(toEnabled: true)
        let config = Configuration.shared.commands[table.selectedRow]

        nameField.stringValue = config.name
        commandField.stringValue = config.command

        table.reloadData(forRowIndexes: IndexSet(integer: table.selectedRow), columnIndexes: IndexSet(integer: 0))
    }
}

extension CommandConfigurationViewController: NSTableViewDataSource {
    public func numberOfRows(in tableView: NSTableView) -> Int {
        return Configuration.shared.commands.count
    }

    public func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return Configuration.shared.commands[row]
    }
}

extension CommandConfigurationViewController: NSTableViewDelegate {
    public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let view = (tableView.makeView(withIdentifier: entryColumnIdentifier, owner: self) as? CommandListCell) ?? CommandListCell()
        view.commandConfiguration = Configuration.shared.commands[row]
        view.identifier = entryColumnIdentifier
        return view
    }

    public func tableViewSelectionDidChange(_ notification: Notification) {
        updateUI()
    }
}

extension CommandConfigurationViewController: NSTextFieldDelegate {
    public func controlTextDidChange(_ obj: Notification) {
        guard let sendingField = obj.object as? NSTextField else { return }
        var config = Configuration.shared.commands[table.selectedRow]
        switch sendingField {
        case nameField: config.name = nameField.stringValue
        case commandField: config.command = commandField.stringValue
        default: break
        }
        Configuration.shared.commands[table.selectedRow] = config
        updateUI()
    }
}

