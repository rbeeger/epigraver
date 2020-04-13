//
// Created by Robert Beeger on 12.04.20.
// Copyright (c) 2020 Robert Beeger. All rights reserved.
//

import Foundation
import os

class ConfigurationSelector {
    private typealias Me = ConfigurationSelector

    let command: String
    let appearances: [Configuration.Appearance]
    let animators: [Animator]

    init() {
        let entry = Configuration.shared.scheduleEntries
                .filter { Configuration.Time(date: Date()).inRange(from: $0.from, to: $0.to) }
                .filter { Me.onWifi($0.wifiName)  }
                .filter { Me.onNetworkLocation($0.networkLocation)  }
                .first
        if let cmdId = entry?.commandId, let cmd = Configuration.shared.commands.first(where: { $0.id ==  cmdId }) {
            command = cmd.command
        } else {
            command = "echo No command found!"
        }

        let appearanceIds: [String] = entry?.appearanceIds ?? []

        var appr = appearanceIds.compactMap { id in Configuration.shared.appearances.first { $0.id == id  }}
        if appr.count == 0 {
            appr.append(Configuration.shared.defaultAppearances.first!)
        }
        appearances = appr

        let animatorTypes: [String] = entry?.animatorTypes ?? []
        var anm = animatorTypes.compactMap { typeName in Configuration.shared.availableAnimators.first {$0.typeName() == typeName }}

        if anm.count == 0 {
            anm.append(Configuration.shared.availableAnimators.first!)
        }
        animators = anm
    }

    private static func onWifi(_ wifiName: String ) -> Bool {
        return wifiName.count == 0 || wifiName == Configuration.shared.currentWifi
    }

    private static func onNetworkLocation(_ networkLocation: String ) -> Bool {
        return networkLocation.count == 0 || networkLocation == Configuration.shared.currentNetworkLocation
    }
}
