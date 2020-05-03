//
// Created by Robert Beeger on 2019-02-02.
// Copyright (c) 2019 Robert Beeger. All rights reserved.
//

import Foundation
import AppKit
import os

class ScheduleConfigurationViewController: NSViewController {
    typealias Me = ScheduleConfigurationViewController
    private static let entryColumnIdentifier = NSUserInterfaceItemIdentifier(rawValue: "entryColumn")
    private static let schedulesEntriesTag = 1
    private static let weekdaysTag = 2
    private static let appearancesTag = 3
    private static let animatorsTag = 4

    private lazy var scheduleEntriesTable: NSTableView = {
        let view = NSTableView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tag = Me.schedulesEntriesTag
        view.delegate = self
        view.dataSource = self

        let column = NSTableColumn(identifier: Me.entryColumnIdentifier)
        column.title = ""
        column.isEditable = false
        view.addTableColumn(column)

        view.headerView = nil
        view.rowHeight = 120
        return view
    }()

    private lazy var scheduleEntriesTableScroller: NSScrollView = {
        let view = NSScrollView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.documentView = scheduleEntriesTable
        return view
    }()

    private lazy var buttonBar: NSSegmentedControl = {
        let view = NSSegmentedControl(images: [
            NSImage(named: NSImage.addTemplateName)!,
            NSImage(named: NSImage.removeTemplateName)!,
            NSImage(named: NSImage.touchBarGoUpTemplateName)!,
            NSImage(named: NSImage.touchBarGoDownTemplateName)!], trackingMode: .momentary,
                target: self, action: #selector(changeScheduleEntry))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isContinuous = false

        return view
    }()

    private lazy var weekdaysLabel: NSTextField = {
        let view = NSTextField(labelWithString: "on")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alignment = .left

        return view
    }()

    private lazy var weekdaysTable: NSTableView = {
        let view = NSTableView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tag = Me.weekdaysTag
        view.delegate = self
        view.dataSource = self
        view.allowsMultipleSelection = true

        let column = NSTableColumn(identifier: Me.entryColumnIdentifier)
        column.title = ""
        column.isEditable = false
        view.addTableColumn(column)

        view.headerView = nil
        view.rowHeight = 20
        return view
    }()

    private lazy var weekdaysTableScroller: NSScrollView = {
        let view = NSScrollView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.documentView = weekdaysTable
        return view
    }()

    private lazy var timeLabel: NSTextField = {
        let view = NSTextField(labelWithString: "Time")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alignment = .right

        return view
    }()

    private lazy var timeFromLabel: NSTextField = {
        let view = NSTextField(labelWithString: "from")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alignment = .left

        return view
    }()

    private lazy var timeFromPicker: NSDatePicker = {
        let view = NSDatePicker(frame: .zero)
        view.calendar = Configuration.shared.calendar
        view.translatesAutoresizingMaskIntoConstraints = false
        view.datePickerStyle = .textFieldAndStepper
        view.datePickerMode = .single
        view.datePickerElements = .hourMinute
        view.locale = NSLocale.autoupdatingCurrent
        view.target = self
        view.action = #selector(changeFrom)

        return view
    }()

    private lazy var timeToLabel: NSTextField = {
        let view = NSTextField(labelWithString: "to")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alignment = .left

        return view
    }()

    private lazy var timeToPicker: NSDatePicker = {
        let view = NSDatePicker(frame: .zero)
        view.calendar = Configuration.shared.calendar
        view.translatesAutoresizingMaskIntoConstraints = false
        view.datePickerStyle = .textFieldAndStepper
        view.datePickerMode = .single
        view.datePickerElements = .hourMinute
        view.locale = NSLocale.autoupdatingCurrent
        view.target = self
        view.action = #selector(changeTo)

        return view
    }()

    private lazy var timeStack: NSStackView = {
        let view = NSStackView(views: [
            timeFromLabel,
            timeFromPicker,
            timeToLabel,
            timeToPicker,
            weekdaysLabel,
            weekdaysTableScroller
        ])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.orientation = .horizontal

        return view
    }()

    private lazy var wifiLabel: NSTextField = {
        let view = NSTextField(labelWithString: "WiFi Name")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alignment = .right

        return view
    }()

    private lazy var wifiCombo: NSComboBox = {
        let view = NSComboBox()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isEditable = true

        return view
    }()

    private lazy var networkLocationLabel: NSTextField = {
        let view = NSTextField(labelWithString: "Network Location")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alignment = .right

        return view
    }()

    private lazy var networkLocationCombo: NSComboBox = {
        let view = NSComboBox()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isEditable = false

        return view
    }()

    private lazy var commandLabel: NSTextField = {
        let view = NSTextField(labelWithString: "Command")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alignment = .right

        return view
    }()

    private lazy var commandCombo: NSComboBox = {
        let view = NSComboBox()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isEditable = false

        return view
    }()

    private lazy var appearancesLabel: NSTextField = {
        let view = NSTextField(labelWithString: "Appearances")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alignment = .left

        return view
    }()

    private lazy var appearancesTable: NSTableView = {
        let view = NSTableView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tag = Me.appearancesTag
        view.delegate = self
        view.dataSource = self
        view.allowsMultipleSelection = true

        let column = NSTableColumn(identifier: Me.entryColumnIdentifier)
        column.title = ""
        column.isEditable = false
        view.addTableColumn(column)

        view.headerView = nil
        view.rowHeight = 60
        return view
    }()

    private lazy var appearancesTableScroller: NSScrollView = {
        let view = NSScrollView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.documentView = appearancesTable
        return view
    }()

    private lazy var animatorsLabel: NSTextField = {
        let view = NSTextField(labelWithString: "Animators")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alignment = .left

        return view
    }()

    private lazy var animatorsTable: NSTableView = {
        let view = NSTableView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tag = Me.animatorsTag
        view.delegate = self
        view.dataSource = self
        view.allowsMultipleSelection = true

        let column = NSTableColumn(identifier: Me.entryColumnIdentifier)
        column.title = ""
        column.isEditable = false
        view.addTableColumn(column)

        view.headerView = nil
        view.rowHeight = 20
        return view
    }()

    private lazy var animatorsTableScroller: NSScrollView = {
        let view = NSScrollView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.documentView = animatorsTable
        return view
    }()

    private lazy var entryBox: NSBox = {
        let box = NSBox(frame: .zero)
        box.translatesAutoresizingMaskIntoConstraints = false
        box.titlePosition = .noTitle

        box.addSubview(timeLabel)
        box.addSubview(timeStack)
        box.addSubview(wifiLabel)
        box.addSubview(wifiCombo)
        box.addSubview(networkLocationLabel)
        box.addSubview(networkLocationCombo)
        box.addSubview(commandLabel)
        box.addSubview(commandCombo)
        box.addSubview(appearancesLabel)
        box.addSubview(appearancesTableScroller)
        box.addSubview(animatorsLabel)
        box.addSubview(animatorsTableScroller)

        timeLabel.leadingAnchor.constraint(equalTo: box.leadingAnchor, constant: 8).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 150).isActive = true
        timeLabel.centerYAnchor.constraint(equalTo: timeStack.centerYAnchor).isActive = true

        timeStack.topAnchor.constraint(equalTo: box.topAnchor, constant: 8).isActive = true
        timeStack.leadingAnchor.constraint(equalTo: timeLabel.trailingAnchor, constant: 8).isActive = true
        timeStack.trailingAnchor.constraint(equalTo: box.trailingAnchor, constant: -8).isActive = true
        timeStack.heightAnchor.constraint(equalToConstant: 150).isActive = true

        wifiLabel.leadingAnchor.constraint(equalTo: timeLabel.leadingAnchor).isActive = true
        wifiLabel.trailingAnchor.constraint(equalTo: timeLabel.trailingAnchor).isActive = true
        wifiLabel.centerYAnchor.constraint(equalTo: wifiCombo.centerYAnchor).isActive = true

        wifiCombo.topAnchor.constraint(equalTo: timeStack.bottomAnchor, constant: 8).isActive = true
        wifiCombo.leadingAnchor.constraint(equalTo: timeStack.leadingAnchor).isActive = true
        wifiCombo.trailingAnchor.constraint(equalTo: timeStack.trailingAnchor).isActive = true

        networkLocationLabel.leadingAnchor.constraint(equalTo: timeLabel.leadingAnchor).isActive = true
        networkLocationLabel.trailingAnchor.constraint(equalTo: timeLabel.trailingAnchor).isActive = true
        networkLocationLabel.centerYAnchor.constraint(equalTo: networkLocationCombo.centerYAnchor).isActive = true

        networkLocationCombo.topAnchor.constraint(equalTo: wifiCombo.bottomAnchor, constant: 8).isActive = true
        networkLocationCombo.leadingAnchor.constraint(equalTo: timeStack.leadingAnchor).isActive = true
        networkLocationCombo.trailingAnchor.constraint(equalTo: timeStack.trailingAnchor).isActive = true

        commandLabel.leadingAnchor.constraint(equalTo: timeLabel.leadingAnchor).isActive = true
        commandLabel.trailingAnchor.constraint(equalTo: timeLabel.trailingAnchor).isActive = true
        commandLabel.centerYAnchor.constraint(equalTo: commandCombo.centerYAnchor).isActive = true

        commandCombo.topAnchor.constraint(equalTo: networkLocationCombo.bottomAnchor, constant: 16).isActive = true
        commandCombo.leadingAnchor.constraint(equalTo: timeStack.leadingAnchor).isActive = true
        commandCombo.trailingAnchor.constraint(equalTo: timeStack.trailingAnchor).isActive = true

        appearancesLabel.topAnchor.constraint(equalTo: commandCombo.bottomAnchor, constant: 16).isActive = true
        appearancesLabel.leadingAnchor.constraint(equalTo: appearancesTableScroller.leadingAnchor).isActive = true
        appearancesLabel.trailingAnchor.constraint(equalTo: appearancesTableScroller.trailingAnchor).isActive = true

        appearancesTableScroller.topAnchor.constraint(equalTo: appearancesLabel.bottomAnchor,
                constant: 8).isActive = true
        appearancesTableScroller.leadingAnchor.constraint(equalTo: box.leadingAnchor, constant: 8).isActive = true
        appearancesTableScroller.bottomAnchor.constraint(equalTo: box.bottomAnchor, constant: -8).isActive = true

        animatorsLabel.topAnchor.constraint(equalTo: appearancesLabel.topAnchor).isActive = true
        animatorsLabel.leadingAnchor.constraint(equalTo: animatorsTableScroller.leadingAnchor).isActive = true
        animatorsLabel.trailingAnchor.constraint(equalTo: animatorsTableScroller.trailingAnchor).isActive = true

        animatorsTableScroller.topAnchor.constraint(equalTo: appearancesTableScroller.topAnchor).isActive = true
        animatorsTableScroller.bottomAnchor.constraint(equalTo: appearancesTableScroller.bottomAnchor).isActive = true
        animatorsTableScroller.leadingAnchor.constraint(equalTo: appearancesTableScroller.trailingAnchor,
                constant: 8).isActive = true
        animatorsTableScroller.trailingAnchor.constraint(equalTo: timeStack.trailingAnchor).isActive = true
        animatorsTableScroller.widthAnchor.constraint(equalTo: appearancesTableScroller.widthAnchor,
                multiplier: 1.0).isActive = true

        return box
    }()

    init() {
        super.init(nibName: nil, bundle: nil)
        self.title = "Schedule"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scheduleEntriesTableScroller)
        view.addSubview(buttonBar)
        view.addSubview(entryBox)

        scheduleEntriesTableScroller.topAnchor.constraint(equalTo: view.topAnchor, constant: 8).isActive = true
        scheduleEntriesTableScroller.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8).isActive = true
        scheduleEntriesTableScroller.widthAnchor.constraint(equalToConstant: 150).isActive = true

        buttonBar.topAnchor.constraint(equalTo: scheduleEntriesTableScroller.bottomAnchor, constant: 8).isActive = true
        buttonBar.leadingAnchor.constraint(equalTo: scheduleEntriesTableScroller.leadingAnchor).isActive = true
        buttonBar.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8).isActive = true

        entryBox.topAnchor.constraint(equalTo: view.topAnchor, constant: 8).isActive = true
        entryBox.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8).isActive = true
        entryBox.leadingAnchor.constraint(equalTo: scheduleEntriesTableScroller.trailingAnchor,
                constant: 8).isActive = true
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

        changeComboBoxDelegation(toEnabled: false)

        view.bottomAnchor.constraint(equalTo: view.superview!.bottomAnchor).isActive = true
        view.centerXAnchor.constraint(equalTo: view.superview!.centerXAnchor).isActive = true

        weekdaysTable.reloadData()
        wifiCombo.removeAllItems()
        if let currentWifi = Configuration.shared.currentWifi {
            wifiCombo.addItems(withObjectValues: ["", currentWifi])
        }
        networkLocationCombo.removeAllItems()
        networkLocationCombo.addItems(withObjectValues: [""] + Configuration.shared.availableNetworkLocations)
        commandCombo.removeAllItems()
        commandCombo.addItems(withObjectValues: Configuration.shared.commands.map {$0.name})

        appearancesTable.reloadData()

        let selectedRow = min(Configuration.shared.scheduleEntries.count - 1, max(0, scheduleEntriesTable.selectedRow))
        scheduleEntriesTable.reloadData()
        scheduleEntriesTable.selectRowIndexes(IndexSet(integer: selectedRow), byExtendingSelection: false)

        changeComboBoxDelegation(toEnabled: true)
    }

    private func changeComboBoxDelegation(toEnabled enabled: Bool) {
        networkLocationCombo.delegate = enabled ? self : nil
        wifiCombo.delegate = enabled ? self : nil
        commandCombo.delegate = enabled ? self : nil
    }

    @objc func changeScheduleEntry() {
        switch buttonBar.selectedSegment {
        case 0: addSchedule()
        case 1: removeSchedule()
        case 2: moveSchedule(up: true)
        case 3: moveSchedule(up: false)
        default: break
        }
    }

    private func addSchedule() {
        Configuration.shared.scheduleEntries.append(Configuration.ScheduleEntry(
                weekdays: Array(0..<Configuration.shared.calendar.shortStandaloneWeekdaySymbols.count),
                from: Configuration.Time(hours: 0, minutes: 0),
                to: Configuration.Time(hours: 23, minutes: 59),
                wifiName: "",
                networkLocation: "",
                commandId: Configuration.shared.commands.first?.id ?? "",
                appearanceIds: Configuration.shared.appearances.map { $0.id  },
                animatorTypes: Configuration.shared.availableAnimators.map {String(describing: type(of: $0))}
        ))
        scheduleEntriesTable.reloadData()
        scheduleEntriesTable.selectRowIndexes(IndexSet(integer: Configuration.shared.scheduleEntries.count - 1),
                byExtendingSelection: false)
        scheduleEntriesTable.scrollRowToVisible(Configuration.shared.scheduleEntries.count - 1)
    }

    private func removeSchedule() {
        guard scheduleEntriesTable.selectedRow >= 0,
              scheduleEntriesTable.selectedRow < Configuration.shared.scheduleEntries.count
                else { return }

        let oldSelectedRow = scheduleEntriesTable.selectedRow
        Configuration.shared.scheduleEntries.remove(at: scheduleEntriesTable.selectedRow)
        scheduleEntriesTable.reloadData()
        let newSelectedRow = min(Configuration.shared.scheduleEntries.count - 1, oldSelectedRow)
        scheduleEntriesTable.selectRowIndexes(IndexSet(integer: newSelectedRow), byExtendingSelection: false)
        scheduleEntriesTable.scrollRowToVisible(newSelectedRow)
    }

    private func moveSchedule(up: Bool) {
        let oldSelectedRow = scheduleEntriesTable.selectedRow

        guard oldSelectedRow >= 0,
              oldSelectedRow < Configuration.shared.scheduleEntries.count,
              Configuration.shared.scheduleEntries.count > 1,
              oldSelectedRow > 0 && up || oldSelectedRow < (Configuration.shared.scheduleEntries.count - 1) && !up
                else { return }

        let removed = Configuration.shared.scheduleEntries.remove(at: scheduleEntriesTable.selectedRow)
        let newSelectedRow = oldSelectedRow + (up ? -1 : 1 )
        Configuration.shared.scheduleEntries.insert(removed, at: newSelectedRow)

        scheduleEntriesTable.reloadData()
        scheduleEntriesTable.selectRowIndexes(IndexSet(integer: newSelectedRow), byExtendingSelection: false)
        scheduleEntriesTable.scrollRowToVisible(newSelectedRow)
    }

    private func changeUI(toEnabled enabled: Bool) {
        entryBox.alphaValue = enabled ? 1.0 : 0.4
        timeFromPicker.isEnabled = enabled
        timeToPicker.isEnabled = enabled
        weekdaysTable.isEnabled = enabled
        wifiCombo.isEnabled = enabled
        networkLocationCombo.isEnabled = enabled
        commandCombo.isEnabled = enabled
        appearancesTable.isEnabled = enabled
        animatorsTable.isEnabled = enabled
    }

    private func updateUI() {
        guard scheduleEntriesTable.selectedRow >= 0 else {
            changeUI(toEnabled: false)
            return
        }
        changeUI(toEnabled: true)
        changeComboBoxDelegation(toEnabled: false)

        let config = Configuration.shared.scheduleEntries[scheduleEntriesTable.selectedRow]

        timeFromPicker.dateValue = config.from.date
        timeToPicker.dateValue = config.to.date
        weekdaysTable.selectRowIndexes(IndexSet(config.weekdays), byExtendingSelection: false)

        commandCombo.stringValue = Configuration.shared.commands.first(where: { $0.id == config.commandId })?.name ?? ""
        wifiCombo.stringValue = config.wifiName
        networkLocationCombo.stringValue = config.networkLocation

        appearancesTable.selectRowIndexes(IndexSet(config.appearanceIds.compactMap { appearanceId in
            Configuration.shared.appearances.firstIndex { $0.id == appearanceId }
        }), byExtendingSelection: false)

        animatorsTable.selectRowIndexes(IndexSet(config.animatorTypes.compactMap { animatorType in
            Configuration.shared.availableAnimators.firstIndex { $0.typeName() == animatorType }
        }), byExtendingSelection: false)

        changeComboBoxDelegation(toEnabled: true)

        reloadCurrentScheduledEntryInfo()
    }

    private func reloadCurrentScheduledEntryInfo() {
        guard scheduleEntriesTable.selectedRow >= 0 else {
            return
        }

        scheduleEntriesTable.reloadData(
                forRowIndexes: IndexSet(integer: scheduleEntriesTable.selectedRow),
                columnIndexes: IndexSet(integer: 0))
    }

    @objc private func changeFrom() {
        guard scheduleEntriesTable.selectedRow >= 0 else {
            return
        }

        Configuration.shared.scheduleEntries[scheduleEntriesTable.selectedRow].from.date = timeFromPicker.dateValue
        reloadCurrentScheduledEntryInfo()
    }

    @objc private func changeTo() {
        guard scheduleEntriesTable.selectedRow >= 0 else {
            return
        }

        Configuration.shared.scheduleEntries[scheduleEntriesTable.selectedRow].to.date = timeToPicker.dateValue
        reloadCurrentScheduledEntryInfo()
    }

    private func selectWeekdays() {
        guard scheduleEntriesTable.selectedRow >= 0 else {
            return
        }

        Configuration.shared.scheduleEntries[scheduleEntriesTable.selectedRow].weekdays =
                weekdaysTable.selectedRowIndexes.sorted()
        reloadCurrentScheduledEntryInfo()
    }

    private func selectAppearances() {
        guard scheduleEntriesTable.selectedRow >= 0 else {
            return
        }

        Configuration.shared.scheduleEntries[scheduleEntriesTable.selectedRow].appearanceIds =
                appearancesTable.selectedRowIndexes.map { Configuration.shared.appearances[$0].id }
    }

    private func selectAnimators() {
        guard scheduleEntriesTable.selectedRow >= 0 else {
            return
        }

        Configuration.shared.scheduleEntries[scheduleEntriesTable.selectedRow].animatorTypes =
                animatorsTable.selectedRowIndexes.map { Configuration.shared.availableAnimators[$0].typeName() }
    }

}

extension ScheduleConfigurationViewController: NSTableViewDataSource {
    public func numberOfRows(in tableView: NSTableView) -> Int {
        switch tableView.tag {
        case Me.schedulesEntriesTag: return Configuration.shared.scheduleEntries.count
        case Me.weekdaysTag: return Configuration.shared.calendar.shortStandaloneWeekdaySymbols.count
        case Me.appearancesTag: return Configuration.shared.appearances.count
        case Me.animatorsTag: return Configuration.shared.availableAnimators.count
        default: return 0
        }
    }
}

extension ScheduleConfigurationViewController: NSTableViewDelegate {
    public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        switch tableView.tag {
        case Me.schedulesEntriesTag:
            let view = (tableView.makeView(
                    withIdentifier: Me.entryColumnIdentifier,
                    owner: self) as? ScheduleListCell) ?? ScheduleListCell()
            view.scheduleEntryConfiguration = Configuration.shared.scheduleEntries[row]
            view.identifier = Me.entryColumnIdentifier
            return view
        case Me.weekdaysTag:
            let view = (tableView.makeView(
                    withIdentifier: Me.entryColumnIdentifier,
                    owner: self) as? GenericTextListCell) ?? GenericTextListCell()
            view.text = Configuration.shared.calendar.standaloneWeekdaySymbols[row]
            view.identifier = Me.entryColumnIdentifier
            return view
        case Me.appearancesTag:
            let view = (tableView.makeView(
                    withIdentifier: Me.entryColumnIdentifier,
                    owner: self) as? AppearanceListCell) ?? AppearanceListCell()
            view.appearanceConfiguration = Configuration.shared.appearances[row]
            view.identifier = Me.entryColumnIdentifier
            return view
        case Me.animatorsTag:
            let view = (tableView.makeView(
                    withIdentifier: Me.entryColumnIdentifier,
                    owner: self) as? GenericTextListCell) ?? GenericTextListCell()
            view.text = Configuration.shared.availableAnimators[row].typeName()
            view.identifier = Me.entryColumnIdentifier
            return view
        default: return NSTableCellView()
        }
    }

    public func tableViewSelectionDidChange(_ notification: Notification) {
        guard let table = notification.object as? NSTableView else {
            return
        }
        switch table.tag {
        case Me.schedulesEntriesTag: updateUI()
        case Me.weekdaysTag: selectWeekdays()
        case Me.appearancesTag: selectAppearances()
        case Me.animatorsTag: selectAnimators()
        default: break
        }
    }
}

extension ScheduleConfigurationViewController: NSComboBoxDelegate {
    public func controlTextDidChange(_ obj: Notification) {
        guard let sendingComboBox = obj.object as? NSComboBox,
              scheduleEntriesTable.selectedRow >= 0 else {
            return
        }

        applyChange(from: sendingComboBox, with: sendingComboBox.stringValue)
    }

    public func comboBoxSelectionDidChange(_ notification: Notification) {
        guard let sendingComboBox = notification.object as? NSComboBox,
              scheduleEntriesTable.selectedRow >= 0 else {
            return
        }

        applyChange(from: sendingComboBox, with: sendingComboBox.objectValueOfSelectedItem as? String ?? "")
    }

    private func applyChange(from comboBox: NSComboBox, with value: String) {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        var config = Configuration.shared.scheduleEntries[scheduleEntriesTable.selectedRow]

        switch comboBox {
        case wifiCombo: config.wifiName = trimmed
        case networkLocationCombo: config.networkLocation = trimmed
        case commandCombo: config.commandId =
                Configuration.shared.commands.first(where: {$0.name == trimmed})?.id
                        ?? Configuration.shared.commands.first!.id
        default: break
        }

        Configuration.shared.scheduleEntries[scheduleEntriesTable.selectedRow] = config
        reloadCurrentScheduledEntryInfo()
    }
}
