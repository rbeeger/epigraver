//
//  Created by Robert Beeger on 24.05.20.
//  Copyright © 2020 Robert Beeger. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import EpigraverApp

class ConfigurationSelectorSpec: QuickSpec {
    struct ConfigurationSelection: Equatable {
        var command: String
        var appearanceIds: [String]
        var animatorTypes: [String]
        var animationInterval: TimeInterval

        init(entry: ScheduleEntry, configuration: TestConfiguration) {
            command = configuration.commands.first(where: {$0.id == entry.commandId})?.command ?? "not found"
            appearanceIds = entry.appearanceIds
            animatorTypes = entry.animatorTypes
            animationInterval =
                TimeInterval(configuration.commands.first(where: {$0.id == entry.commandId})?.animationInterval ?? 4711)
        }

        init(selector: ConfigurationSelector) {
            command = selector.command
            appearanceIds = selector.appearances.map { $0.id }
            animatorTypes = selector.animators.map { $0.typeName() }
            animationInterval = selector.animationInterval
        }

        init(command: String, appearanceIds: [String], animatorTypes: [String], animationInterval: TimeInterval) {
            self.command = command
            self.appearanceIds = appearanceIds
            self.animatorTypes = animatorTypes
            self.animationInterval = animationInterval
        }
    }

    override func spec() {
        describe("Configuration Selector") {
            let command0Id = "command0"
            let command1Id = "command1"
            let command2Id = "command2"
            let command3Id = "command3"
            let command4Id = "command4"
            let defaultAppearanceId = "defaultAppearance"
            let appearance0Id = "appearance0"
            let appearance1Id = "appearance1"
            let wifi0 = "wifi0"
            let wifi1 = "wifi1"
            let network0 = "network0"
            let network1 = "network1"
            var configuration: TestConfiguration!

            beforeEach {
                let commands = [
                    Command(id: command0Id, name: "command0", command: "command0 action", animationInterval: 10),
                    Command(id: command1Id, name: "command1", command: "command1 action", animationInterval: 20),
                    Command(id: command2Id, name: "command2", command: "command2 action", animationInterval: 30),
                    Command(id: command3Id, name: "command3", command: "command3 action", animationInterval: 40),
                    Command(id: command4Id, name: "command4", command: "command4 action", animationInterval: 50)
                ]
                let animators: [Animator] = [
                    ZoomAnimator(),
                    RotateAnimator(),
                    HorizontalSlideAnimator()
                ]
                let defaulAppearances = [
                    Appearance(id: defaultAppearanceId,
                               foregroundColor: 0xff0000,
                               backgroundColor: 0xff0000,
                               fontName: "default",
                               fontSize: 10)
                ]
                let appearances = [
                    Appearance(id: appearance0Id,
                               foregroundColor: 0xff0000,
                               backgroundColor: 0xff0000,
                               fontName: "0",
                               fontSize: 22),
                    Appearance(id: appearance1Id,
                               foregroundColor: 0xff0000,
                               backgroundColor: 0xff0000,
                               fontName: "1",
                               fontSize: 22)
                ]
                let scheduleEntries = [
                    ScheduleEntry(weekdays: [1, 2],
                                  from: Time(hours: 00, minutes: 00),
                                  to: Time(hours: 23, minutes: 59),
                                  wifiName: "",
                                  networkLocation: "",
                                  commandId: command0Id,
                                  appearanceIds: [appearance0Id],
                                  animatorTypes: [animators[2].typeName()]),
                    ScheduleEntry(weekdays: [2, 3],
                                  from: Time(hours: 11, minutes: 00),
                                  to: Time(hours: 12, minutes: 59),
                                  wifiName: wifi0,
                                  networkLocation: "",
                                  commandId: command1Id,
                                  appearanceIds: [appearance1Id, appearance0Id],
                                  animatorTypes: [animators[1].typeName()]),
                    ScheduleEntry(weekdays: [3],
                                  from: Time(hours: 11, minutes: 00),
                                  to: Time(hours: 12, minutes: 59),
                                  wifiName: wifi1,
                                  networkLocation: "",
                                  commandId: command2Id,
                                  appearanceIds: [appearance1Id],
                                  animatorTypes: [animators[1].typeName(), animators[2].typeName()]),
                    ScheduleEntry(weekdays: [3],
                                  from: Time(hours: 11, minutes: 00),
                                  to: Time(hours: 12, minutes: 59),
                                  wifiName: "",
                                  networkLocation: network0,
                                  commandId: command3Id,
                                  appearanceIds: [appearance1Id],
                                  animatorTypes: [animators[1].typeName()]),
                    ScheduleEntry(weekdays: [3],
                                  from: Time(hours: 11, minutes: 00),
                                  to: Time(hours: 12, minutes: 59),
                                  wifiName: "",
                                  networkLocation: network1,
                                  commandId: command4Id,
                                  appearanceIds: [appearance1Id],
                                  animatorTypes: [animators[1].typeName()]),
                    ScheduleEntry(weekdays: [4],
                                  from: Time(hours: 22, minutes: 00),
                                  to: Time(hours: 02, minutes: 00),
                                  wifiName: wifi0,
                                  networkLocation: network1,
                                  commandId: command4Id,
                                  appearanceIds: [appearance0Id],
                                  animatorTypes: [animators[2].typeName()])
                ]
                configuration = TestConfiguration(
                    currentTime: Time(hours: 11, minutes: 25),
                    currentWeekday: 1,
                    currentWifi: wifi0,
                    currentNetworkLocation: network0,
                    availableNetworkLocations: [network0, network1],
                    scheduleEntries: scheduleEntries,
                    commands: commands,
                    appearances: appearances,
                    defaultAppearances: defaulAppearances,
                    availableAnimators: animators)
            }

            it("selects entry 0 on weekday 1 at 11:12") {
                configuration.currentTime = Time(hours: 11, minutes: 12)
                configuration.currentWeekday = 1
                expect(ConfigurationSelection(selector: ConfigurationSelector(configuration: configuration)))
                    == ConfigurationSelection(entry: configuration.scheduleEntries[0], configuration: configuration)
            }

            it("selects entry 0 on weekday 2 at 11:12") {
                configuration.currentTime = Time(hours: 11, minutes: 12)
                configuration.currentWeekday = 2
                expect(ConfigurationSelection(selector: ConfigurationSelector(configuration: configuration)))
                    == ConfigurationSelection(entry: configuration.scheduleEntries[0], configuration: configuration)
            }

            it("selects entry 1 on weekday 3 at 11:12") {
                configuration.currentTime = Time(hours: 11, minutes: 12)
                configuration.currentWeekday = 3
                expect(ConfigurationSelection(selector: ConfigurationSelector(configuration: configuration)))
                    == ConfigurationSelection(entry: configuration.scheduleEntries[1], configuration: configuration)
            }

            it("selects entry 2 on weekday 3 at 11:12 in wifi1") {
                configuration.currentTime = Time(hours: 11, minutes: 12)
                configuration.currentWeekday = 3
                configuration.currentWifi = wifi1
                expect(ConfigurationSelection(selector: ConfigurationSelector(configuration: configuration)))
                    == ConfigurationSelection(entry: configuration.scheduleEntries[2], configuration: configuration)
            }

            it("selects entry 3 on weekday 3 at 11:12 in network0") {
                configuration.currentTime = Time(hours: 11, minutes: 12)
                configuration.currentWeekday = 3
                configuration.currentWifi = nil
                configuration.currentNetworkLocation = network0
                expect(ConfigurationSelection(selector: ConfigurationSelector(configuration: configuration)))
                    == ConfigurationSelection(entry: configuration.scheduleEntries[3], configuration: configuration)
            }

            it("selects entry 4 on weekday 3 at 11:12 in network1") {
                configuration.currentTime = Time(hours: 11, minutes: 12)
                configuration.currentWeekday = 3
                configuration.currentWifi = nil
                configuration.currentNetworkLocation = network1
                expect(ConfigurationSelection(selector: ConfigurationSelector(configuration: configuration)))
                    == ConfigurationSelection(entry: configuration.scheduleEntries[4], configuration: configuration)
            }

            it("selects entry 5 on weekday 4 at 01:00 in wifi0 and network1") {
                configuration.currentTime = Time(hours: 01, minutes: 00)
                configuration.currentWeekday = 4
                configuration.currentWifi = wifi0
                configuration.currentNetworkLocation = network1
                expect(ConfigurationSelection(selector: ConfigurationSelector(configuration: configuration)))
                    == ConfigurationSelection(entry: configuration.scheduleEntries[5], configuration: configuration)
            }

            it("selects a generated entry with a default command if referenced command does not exist") {
                configuration.currentTime = Time(hours: 11, minutes: 12)
                configuration.currentWeekday = 1
                configuration.commands = []
                expect(ConfigurationSelection(selector: ConfigurationSelector(configuration: configuration)))
                    == ConfigurationSelection(command: "echo No command found!",
                                              appearanceIds: [appearance0Id],
                                              animatorTypes: [configuration.availableAnimators[2].typeName()],
                                              animationInterval: 60)
            }

            it("selects a generated entry with a default appearance if referenced appearance does not exist") {
                configuration.currentTime = Time(hours: 11, minutes: 12)
                configuration.currentWeekday = 1
                configuration.appearances = []
                expect(ConfigurationSelection(selector: ConfigurationSelector(configuration: configuration)))
                    == ConfigurationSelection(command: "command0 action",
                                              appearanceIds: [defaultAppearanceId],
                                              animatorTypes: [configuration.availableAnimators[2].typeName()],
                                              animationInterval: 10)
            }

            it("selects a generated entry with the first available animator if referenced animator does not exist") {
                configuration.currentTime = Time(hours: 11, minutes: 12)
                configuration.currentWeekday = 1
                configuration.availableAnimators = [ZoomAnimator()]
                expect(ConfigurationSelection(selector: ConfigurationSelector(configuration: configuration)))
                    == ConfigurationSelection(command: "command0 action",
                                              appearanceIds: [appearance0Id],
                                              animatorTypes: [configuration.availableAnimators[0].typeName()],
                                              animationInterval: 10)
            }

            it("selects a generated fallback entry if there is no entry available for the current time") {
                configuration.currentTime = Time(hours: 11, minutes: 12)
                configuration.currentWeekday = 6
                expect(ConfigurationSelection(selector: ConfigurationSelector(configuration: configuration)))
                    == ConfigurationSelection(command: "echo No command found!",
                                              appearanceIds: [defaultAppearanceId],
                                              animatorTypes: [configuration.availableAnimators[0].typeName()],
                                              animationInterval: 60)
            }

            it("selects a generated fallback entry on weekday 4 at 01:00 in wifi1 and network1") {
                configuration.currentTime = Time(hours: 01, minutes: 00)
                configuration.currentWeekday = 4
                configuration.currentWifi = wifi1
                configuration.currentNetworkLocation = network1
                expect(ConfigurationSelection(selector: ConfigurationSelector(configuration: configuration)))
                    == ConfigurationSelection(command: "echo No command found!",
                                              appearanceIds: [defaultAppearanceId],
                                              animatorTypes: [configuration.availableAnimators[0].typeName()],
                                              animationInterval: 60)
            }

            it("selects a generated fallback entry on weekday 4 at 01:00 in wifi0 and network0") {
                configuration.currentTime = Time(hours: 01, minutes: 00)
                configuration.currentWeekday = 4
                configuration.currentWifi = wifi0
                configuration.currentNetworkLocation = network0
                expect(ConfigurationSelection(selector: ConfigurationSelector(configuration: configuration)))
                    == ConfigurationSelection(command: "echo No command found!",
                                              appearanceIds: [defaultAppearanceId],
                                              animatorTypes: [configuration.availableAnimators[0].typeName()],
                                              animationInterval: 60)
            }
        }
    }
}
