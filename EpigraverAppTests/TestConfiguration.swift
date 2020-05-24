//
//  Created by Robert Beeger on 24.05.20.
//  Copyright © 2020 Robert Beeger. All rights reserved.
//

import Foundation
@testable import EpigraverApp

struct TestConfiguration: Configuration {
    var currentTime: Time
    var currentWeekday: Int
    var currentWifi: String?
    var currentNetworkLocation: String?
    var availableNetworkLocations: [String]
    var scheduleEntries: [ScheduleEntry]
    var commands: [Command]
    var appearances: [Appearance]
    var defaultAppearances: [Appearance]
    var availableAnimators: [Animator]
}
