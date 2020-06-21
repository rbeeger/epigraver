//
// Created by Robert Beeger on 12.04.20.
// Copyright (c) 2020 Robert Beeger. All rights reserved.
//

import Foundation
import os

class ConfigurationSelector {
    private typealias Me = ConfigurationSelector

    let command: String
    let appearances: [Appearance]
    let animators: [Animator]
    let animationInterval: TimeInterval

    init(configuration: Configuration = SaverConfiguration.shared) {
        let entry = configuration.scheduleEntries
                .filter { configuration.currentTime.inRange(from: $0.from, to: $0.to) }
                .filter { $0.weekdays.contains(configuration.currentWeekday) }
                .filter { $0.wifiName.count == 0 || $0.wifiName == configuration.currentWifi  }
                .filter { $0.networkLocation.count == 0 || $0.networkLocation == configuration.currentNetworkLocation }
                .first

        if let cmdId = entry?.commandId, let cmd = configuration.commands.first(where: { $0.id ==  cmdId }) {
            command = cmd.command
            animationInterval = TimeInterval(cmd.animationInterval)
        } else {
            command = "echo No command found!"
            animationInterval = 60
        }

        let appearanceIds: [String] = entry?.appearanceIds ?? []

        var appr = appearanceIds.compactMap { id in configuration.appearances.first { $0.id == id  }}
        if appr.count == 0 {
            appr.append(configuration.defaultAppearances.first!)
        }
        appearances = appr

        let animatorTypes: [String] = entry?.animatorTypes ?? []
        var anm = animatorTypes
            .compactMap { typeName in configuration.availableAnimators.first {$0.typeName == typeName } }

        if anm.count == 0 {
            anm.append(configuration.availableAnimators.first!)
        }
        animators = anm
    }
}
