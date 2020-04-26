//
// Created by Robert Beeger on 2019-02-10.
// Copyright (c) 2019 Robert Beeger. All rights reserved.
//

import Foundation
import ScreenSaver
import os
import CoreWLAN
import CoreFoundation
import SystemConfiguration

class Configuration {
    static let shared = Configuration()
    private typealias Me = Configuration
    private static let scheduleDefaultsKey = "schedule"
    private static let commandsDefaultsKey = "commands"
    private static let appearancesDefaultsKey = "appearances"

    struct Time: Codable, Comparable {
        var hours: Int
        var minutes: Int

        var date: Date {
            get {
                DateComponents(calendar: Me.shared.calendar, hour: hours, minute: minutes).date ?? Date()
            }
            set {
                hours = Me.shared.calendar.component(.hour, from: newValue)
                minutes = Me.shared.calendar.component(.minute, from: newValue)
            }
        }

        init(hours: Int, minutes: Int) {
            self.hours = hours
            self.minutes = minutes
        }

        init(date: Date) {
            self.hours = Me.shared.calendar.component(.hour, from: date)
            self.minutes = Me.shared.calendar.component(.minute, from: date)
        }

        func inRange(from: Time, to: Time) -> Bool {
            if from <= to {
                return from <= self && self <= to
            } else {
                return from <= self || self <= to
            }
        }

        static func < (lhs: Time, rhs: Time) -> Bool {
            lhs.hours < rhs.hours || lhs.hours == rhs.hours && lhs.minutes < rhs.minutes
        }

        static func == (lhs: Time, rhs: Time) -> Bool {
            lhs.hours == rhs.hours && lhs.minutes == rhs.minutes
        }
    }

    struct ScheduleEntry: Codable {
        var id: String = UUID().uuidString
        var weekdays: [Int]
        var from: Time
        var to: Time
        var wifiName: String
        var networkLocation: String
        var commandId: String
        var appearanceIds: [String]
        var animatorTypes: [String]
    }

    struct Command: Codable {
        var id: String = UUID().uuidString
        var name: String
        var command: String
    }

    struct Appearance: Codable {
        var id: String = UUID().uuidString
        var foregroundColor: Int
        var backgroundColor: Int
        var fontName: String
        var fontSize: CGFloat

        var backgroundNSColor: NSColor {
            NSColor(hex: backgroundColor)
        }

        var foregroundNSColor: NSColor {
            NSColor(hex: foregroundColor)
        }
    }

    private let defaults: ScreenSaverDefaults
    private let jsonDecoder: JSONDecoder
    private let jsonEncoder: JSONEncoder

    let availableAnimators: [Animator] = [
        HorizontalSlideAnimator(),
        VerticalSlideAnimator(),
        ZoomAnimator(),
        RotateAnimator(),
        Rotate3DXAnimator(),
        Rotate3DYAnimator()
    ]

    var scheduleEntries: [ScheduleEntry] = []
    var commands: [Command] = []

    let defaultAppearances = [
        Appearance(foregroundColor: 0xF7F5E0, backgroundColor: 0x1C4A5C, fontName: "HoeflerText-Regular", fontSize: 25),
        Appearance(foregroundColor: 0x17D6DE, backgroundColor: 0x733021, fontName: "HoeflerText-Regular", fontSize: 25),
        Appearance(foregroundColor: 0x7DBF54, backgroundColor: 0x2E3345, fontName: "HoeflerText-Regular", fontSize: 25),
        Appearance(foregroundColor: 0xF7E51C, backgroundColor: 0x24665C, fontName: "HoeflerText-Regular", fontSize: 25),
        Appearance(foregroundColor: 0xEDCFBD, backgroundColor: 0x5C172E, fontName: "HoeflerText-Regular", fontSize: 25)
    ]

    var appearances: [Appearance] = []

    var currentTime: Time {
        Time(date: Date())
    }

    var currentWeekday: Int {
        calendar.component(.weekday, from: Date()) - 1
    }

    var currentWifi: String? {
        CWWiFiClient.shared().interface()?.ssid()?.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var currentNetworkLocation: String? {
        if let prefs = SCPreferencesCreate(nil, "epigraver" as CFString, nil) {
            if let current = SCNetworkSetCopyCurrent(prefs) {
                if let name = SCNetworkSetGetName(current) {
                    return (name as String).trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
        }
        return nil
    }

    var availableNetworkLocations: [String] {
        var result = [String]()
        if let prefs = SCPreferencesCreate(nil, "epigraver" as CFString, nil) {
            if let all = SCNetworkSetCopyAll(prefs) as? [SCNetworkSet] {
                for networkSet in all {
                    if let name = SCNetworkSetGetName(networkSet) {
                        result.append(name as String)
                    }
                }
            }
        }
        return result
    }

    var calendar: Calendar

    func load() {
        if let scheduleData = defaults.data(forKey: Me.scheduleDefaultsKey) {
            scheduleEntries = (try? jsonDecoder.decode([ScheduleEntry].self, from: scheduleData)) ?? []
        } else {
            scheduleEntries = []
        }
        if let commandData = defaults.data(forKey: Me.commandsDefaultsKey) {
            commands = (try? jsonDecoder.decode([Command].self, from: commandData)) ?? []
        } else {
            commands = []
        }
        if let appearanceData = defaults.data(forKey: Me.appearancesDefaultsKey) {
            appearances = (try? jsonDecoder.decode([Appearance].self, from: appearanceData)) ?? []
        } else {
            appearances = defaultAppearances
        }
        if appearances.count == 0 {
            appearances = defaultAppearances
        }
    }

    func save() {
        if let encodedSchedule = try? jsonEncoder.encode(scheduleEntries) {
            defaults.set(encodedSchedule, forKey: Me.scheduleDefaultsKey)
        }

        if let encodedCommands = try? jsonEncoder.encode(commands) {
            defaults.set(encodedCommands, forKey: Me.commandsDefaultsKey)
        }

        if let encodedAppearances = try? jsonEncoder.encode(appearances) {
            defaults.set(encodedAppearances, forKey: Me.appearancesDefaultsKey)
        }

        defaults.synchronize()
    }

    private init() {
        calendar = Calendar.current
        calendar.locale = NSLocale.autoupdatingCurrent

        defaults = ScreenSaverDefaults(forModuleWithName: Bundle.main.bundleIdentifier!)!
        jsonDecoder = JSONDecoder()
        jsonEncoder = JSONEncoder()

        load()
    }
}
