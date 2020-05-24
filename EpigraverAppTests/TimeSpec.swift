//
//  Created by Robert Beeger on 23.05.20.
//  Copyright © 2020 Robert Beeger. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import EpigraverApp

class TimeSpec: QuickSpec {
    override func spec() {
        describe("Time") {
            context("created from hours and minutes") {
                var time: Time!
                beforeEach {
                    time = Time(hours: 12, minutes: 14)
                }

                it("has the set hours") {
                    expect(time.hours) == 12
                }

                it("has the set minutes") {
                    expect(time.minutes) == 14
                }

                it("is converted to a Date with correct components") {
                    expect(Calendar.current.dateComponents([.hour, .minute], from: time.date))
                        == DateComponents(hour: 12, minute: 14)
                }

                context("after setting a date") {
                    beforeEach {
                        time.date = DateComponents(calendar: Calendar.current, hour: 13, minute: 35).date!
                    }

                    it("equals the time from the Date") {
                        expect(time) == Time(hours: 13, minutes: 35)
                    }
                }
            }

            context("created from a Date") {
                var time: Time!
                beforeEach {
                    let date = DateComponents(calendar: Calendar.current, hour: 13, minute: 35).date!
                    time = Time(date: date)
                }

                it("has the set hours") {
                    expect(time.hours) == 13
                }

                it("has the set minutes") {
                    expect(time.minutes) == 35
                }

                it("is converted to a Date with correct components") {
                    expect(Calendar.current.dateComponents([.hour, .minute], from: time.date))
                        == DateComponents(hour: 13, minute: 35)
                }
            }

            context("15:43") {
                let time = Time(hours: 15, minutes: 43)

                it("is in the range from 12:14 and 16:00") {
                    expect(time.inRange(
                        from: Time(hours: 12, minutes: 14),
                        to: Time(hours: 16, minutes: 00))) == true
                }

                it("is in the range from 12:14 and 15:43") {
                    expect(time.inRange(
                        from: Time(hours: 12, minutes: 14),
                        to: Time(hours: 15, minutes: 43))) == true
                }

                it("is in the range from 15:43 and 16:00") {
                    expect(time.inRange(
                        from: Time(hours: 15, minutes: 43),
                        to: Time(hours: 16, minutes: 00))) == true
                }

                it("is in the range from 23:00 and 16:00") {
                    expect(time.inRange(
                        from: Time(hours: 23, minutes: 00),
                        to: Time(hours: 16, minutes: 00))) == true
                }

                it("is not in the range from 15:44 and 16:00") {
                    expect(time.inRange(
                        from: Time(hours: 15, minutes: 44),
                        to: Time(hours: 16, minutes: 00))) == false
                }

                it("is not in the range from 23:00 and 6:00") {
                    expect(time.inRange(
                        from: Time(hours: 23, minutes: 00),
                        to: Time(hours: 6, minutes: 00))) == false
                }

                it("equals 15:43") {
                    expect(time) == Time(hours: 15, minutes: 43)
                }

                it("is smaller than 16:00") {
                    expect(time) < Time(hours: 16, minutes: 00)
                }

                it("is greater than 11:00") {
                    expect(time) > Time(hours: 11, minutes: 00)
                }
            }
        }
    }
}
