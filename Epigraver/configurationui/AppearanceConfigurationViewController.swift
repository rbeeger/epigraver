//
// Created by Robert Beeger on 2019-02-02.
// Copyright (c) 2019 Robert Beeger. All rights reserved.
//

import Foundation
import AppKit
import os

class AppearanceConfigurationViewController: NSViewController {
    private let entryColumnIdentifier = NSUserInterfaceItemIdentifier(rawValue: "entryColumn")

    private lazy var table: NSTableView = {
        let view = NSTableView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        view.dataSource = self

        let column = NSTableColumn(identifier: entryColumnIdentifier)
        column.title = ""
        column.width = 150
        column.isEditable = false
        view.addTableColumn(column)

        view.headerView = nil
        view.rowHeight = 90
        return view
    }()

    private lazy var tableScroller: NSScrollView = {
        let view = NSScrollView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.documentView = table
        return view
    }()

    private lazy var buttonBar: NSSegmentedControl = {
        let view = NSSegmentedControl(images: [
            NSImage(named: NSImage.addTemplateName)!,
            NSImage(named: NSImage.removeTemplateName)!], trackingMode: .momentary,
                target: self, action: #selector(addOrRemoveAppearance))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isContinuous = false

        return view
    }()

    private lazy var colorsLabel: NSTextField = {
        let view = NSTextField(labelWithString: "Colors")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alignment = .right

        return view
    }()

    private lazy var fontLabel: NSTextField = {
        let view = NSTextField(labelWithString: "Font")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alignment = .right

        return view
    }()

    private lazy var foregroundColorWell: NSColorWell = {
        let view = NSColorWell(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.target = self
        view.action = #selector(foregroundColorChanged)

        return view
    }()

    private lazy var backgroundColorWell: NSColorWell = {
        let view = NSColorWell(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.target = self
        view.action = #selector(backgroundColorChanged)

        return view
    }()

    private lazy var fontDisplay: NSTextField = {
        let view = NSTextField(string: "")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alignment = .center
        view.isBordered = true
        view.isEditable = false
        return view
    }()

    private lazy var fontChangeButton: NSButton = {
        let view = NSButton(title: "Select", target: self, action: #selector(openFontPanel))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var previewTextDisplay: NSTextField = {
        let view = NSTextField(string: "Do or do not, there is no try.\n-- Yoda")
        view.translatesAutoresizingMaskIntoConstraints = false

        view.isEditable = false
        view.isSelectable = false
        view.textColor = .black
        view.backgroundColor = .clear
        view.drawsBackground = true
        view.isBordered = false
        view.isBezeled = false
        view.alignment = .center
        view.lineBreakMode = .byTruncatingTail

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

        view.addSubview(previewTextDisplay)

        previewTextDisplay.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        previewTextDisplay.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8).isActive = true
        previewTextDisplay.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8).isActive = true

        previewTextDisplay.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        return view
    }()

    private lazy var entryBox: NSBox = {
        let box = NSBox(frame: .zero)
        box.translatesAutoresizingMaskIntoConstraints = false
        box.titlePosition = .noTitle

        box.addSubview(colorsLabel)
        box.addSubview(foregroundColorWell)
        box.addSubview(backgroundColorWell)
        box.addSubview(fontLabel)
        box.addSubview(fontDisplay)
        box.addSubview(fontChangeButton)
        box.addSubview(previewBox)

        colorsLabel.leadingAnchor.constraint(equalTo: box.leadingAnchor, constant: 8).isActive = true
        colorsLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        colorsLabel.centerYAnchor.constraint(equalTo: foregroundColorWell.centerYAnchor).isActive = true

        foregroundColorWell.topAnchor.constraint(equalTo: box.topAnchor, constant: 8).isActive = true
        foregroundColorWell.leadingAnchor.constraint(equalTo: colorsLabel.trailingAnchor, constant: 8).isActive = true
        foregroundColorWell.heightAnchor.constraint(equalTo: fontDisplay.heightAnchor).isActive = true

        backgroundColorWell.centerYAnchor.constraint(equalTo: foregroundColorWell.centerYAnchor).isActive = true
        backgroundColorWell.leadingAnchor.constraint(equalTo: foregroundColorWell.trailingAnchor,
                constant: 8).isActive = true
        backgroundColorWell.trailingAnchor.constraint(equalTo: fontDisplay.trailingAnchor).isActive = true
        backgroundColorWell.widthAnchor.constraint(equalTo: foregroundColorWell.widthAnchor).isActive = true
        backgroundColorWell.heightAnchor.constraint(equalTo: foregroundColorWell.heightAnchor).isActive = true

        fontLabel.leadingAnchor.constraint(equalTo: colorsLabel.leadingAnchor).isActive = true
        fontLabel.trailingAnchor.constraint(equalTo: colorsLabel.trailingAnchor).isActive = true
        fontLabel.centerYAnchor.constraint(equalTo: fontDisplay.centerYAnchor).isActive = true

        fontDisplay.topAnchor.constraint(equalTo: foregroundColorWell.bottomAnchor, constant: 8).isActive = true
        fontDisplay.leadingAnchor.constraint(equalTo: foregroundColorWell.leadingAnchor).isActive = true

        fontChangeButton.centerYAnchor.constraint(equalTo: fontDisplay.centerYAnchor).isActive = true
        fontChangeButton.leadingAnchor.constraint(equalTo: fontDisplay.trailingAnchor, constant: 8).isActive = true
        fontChangeButton.trailingAnchor.constraint(equalTo: box.trailingAnchor, constant: -8).isActive = true
        fontChangeButton.widthAnchor.constraint(equalToConstant: 150).isActive = true

        previewBox.topAnchor.constraint(equalTo: fontDisplay.bottomAnchor, constant: 16).isActive = true
        previewBox.leadingAnchor.constraint(equalTo: box.leadingAnchor, constant: 8).isActive = true
        previewBox.trailingAnchor.constraint(equalTo: box.trailingAnchor, constant: -8).isActive = true
        previewBox.bottomAnchor.constraint(equalTo: box.bottomAnchor, constant: -8).isActive = true

        return box
    }()

    init() {
        super.init(nibName: nil, bundle: nil)
        self.title = "Appearances"

        NSFontManager.shared.target = self
        NSFontManager.shared.action = #selector(fontChanged)
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

        let selectedRow = min(Configuration.shared.appearances.count - 1, max(0, table.selectedRow))
        table.reloadData()
        table.selectRowIndexes(IndexSet(integer: selectedRow), byExtendingSelection: false)
    }

    @objc func foregroundColorChanged() {
        Configuration.shared.appearances[table.selectedRow].foregroundColor = foregroundColorWell.color.hex
        updateUI()
    }

    @objc func backgroundColorChanged() {
        Configuration.shared.appearances[table.selectedRow].backgroundColor = backgroundColorWell.color.hex
        updateUI()
    }

    @objc func fontChanged() {
        guard let font = NSFontManager.shared.selectedFont else {
            return
        }

        Configuration.shared.appearances[table.selectedRow].fontName = font.fontName
        Configuration.shared.appearances[table.selectedRow].fontSize = font.pointSize

        updateUI()
    }

    @objc func addOrRemoveAppearance() {
        switch buttonBar.selectedSegment {
        case 0: addAppearance()
        case 1: removeAppearance()
        default: break
        }
    }

    private func addAppearance() {
        Configuration.shared.appearances.append(
                Configuration.Appearance(foregroundColor: 0x000000, backgroundColor: 0xFFFFFF,
                        fontName: "HoeflerText-Regular", fontSize: 25))
        table.reloadData()
        table.selectRowIndexes(IndexSet(integer: Configuration.shared.appearances.count - 1),
                byExtendingSelection: false)
        table.scrollRowToVisible(Configuration.shared.appearances.count - 1)
    }

    private func removeAppearance() {
        guard table.selectedRow >= 0,
              table.selectedRow < Configuration.shared.appearances.count
        else { return }
        let oldSelectedRow = table.selectedRow
        Configuration.shared.appearances.remove(at: oldSelectedRow)
        table.reloadData()
        let newSelectedRow = min(Configuration.shared.appearances.count - 1, oldSelectedRow)
        table.selectRowIndexes(IndexSet(integer: newSelectedRow), byExtendingSelection: false)
        table.scrollRowToVisible(newSelectedRow)
    }

    @objc func openFontPanel() {
        if let font = NSFont(name: Configuration.shared.appearances[table.selectedRow].fontName,
                size: Configuration.shared.appearances[table.selectedRow].fontSize) {
            NSFontManager.shared.setSelectedFont(font, isMultiple: false)
        }
        NSFontManager.shared.orderFrontFontPanel(self)
    }

    private func changeUI(toEnabled enabled: Bool) {
        entryBox.alphaValue = enabled ? 1.0 : 0.4
        foregroundColorWell.isEnabled = enabled
        backgroundColorWell.isEnabled = enabled
        fontDisplay.isEnabled = enabled
    }

    private func updateUI() {
        guard table.selectedRow >= 0 else {
            changeUI(toEnabled: false)
            return
        }
        changeUI(toEnabled: true)
        let config = Configuration.shared.appearances[table.selectedRow]
        foregroundColorWell.color = config.foregroundNSColor
        backgroundColorWell.color = config.backgroundNSColor
        fontDisplay.stringValue = "\(config.fontName) \(Int(config.fontSize))"
        previewBox.fillColor = config.backgroundNSColor
        previewTextDisplay.textColor = config.foregroundNSColor
        previewTextDisplay.font = NSFont(name: config.fontName, size: config.fontSize)

        table.reloadData(forRowIndexes: IndexSet(integer: table.selectedRow), columnIndexes: IndexSet(integer: 0))
    }
}

extension AppearanceConfigurationViewController: NSTableViewDataSource {
    public func numberOfRows(in tableView: NSTableView) -> Int {
        Configuration.shared.appearances.count
    }

    public func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        Configuration.shared.appearances[row]
    }
}

extension AppearanceConfigurationViewController: NSTableViewDelegate {
    public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let view = (tableView.makeView(withIdentifier: entryColumnIdentifier, owner: self) as? AppearanceListCell)
                ?? AppearanceListCell()
        view.appearanceConfiguration = Configuration.shared.appearances[row]
        view.identifier = entryColumnIdentifier
        return view
    }

    public func tableViewSelectionDidChange(_ notification: Notification) {
        updateUI()
    }
}
