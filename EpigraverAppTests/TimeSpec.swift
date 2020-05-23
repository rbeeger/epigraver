//
//  TimeSpec.swift
//  EpigraverAppTests
//
//  Created by Robert Beeger on 23.05.20.
//  Copyright © 2020 Robert Beeger. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import EpigraverApp

class TimeSpec: QuickSpec {
    typealias Config = EpigraverApp.Configuration

    override func spec() {
        describe("Time") {
            context("created from hours and minutes") {
                var time: Config.Time!
                beforeEach {
                    time = Config.Time(hours: 12, minutes: 14)
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
                        expect(time) == Config.Time(hours: 13, minutes: 35)
                    }
                }
            }

            context("created from a Date") {
                var time: Config.Time!
                beforeEach {
                    let date = DateComponents(calendar: Calendar.current, hour: 13, minute: 35).date!
                    time = Config.Time(date: date)
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
                let time = Config.Time(hours: 15, minutes: 43)

                it("is in the range from 12:14 and 16:00") {
                    expect(time.inRange(
                        from: Config.Time(hours: 12, minutes: 14),
                        to: Config.Time(hours: 16, minutes: 00))) == true
                }

                it("is in the range from 12:14 and 15:43") {
                    expect(time.inRange(
                        from: Config.Time(hours: 12, minutes: 14),
                        to: Config.Time(hours: 15, minutes: 43))) == true
                }

                it("is in the range from 15:43 and 16:00") {
                    expect(time.inRange(
                        from: Config.Time(hours: 15, minutes: 43),
                        to: Config.Time(hours: 16, minutes: 00))) == true
                }

                it("is in the range from 23:00 and 16:00") {
                    expect(time.inRange(
                        from: Config.Time(hours: 23, minutes: 00),
                        to: Config.Time(hours: 16, minutes: 00))) == true
                }

                it("is not in the range from 15:44 and 16:00") {
                    expect(time.inRange(
                        from: Config.Time(hours: 15, minutes: 44),
                        to: Config.Time(hours: 16, minutes: 00))) == false
                }

                it("is not in the range from 23:00 and 6:00") {
                    expect(time.inRange(
                        from: Config.Time(hours: 23, minutes: 00),
                        to: Config.Time(hours: 6, minutes: 00))) == false
                }

                it("equals 15:43") {
                    expect(time) == Config.Time(hours: 15, minutes: 43)
                }

                it("is smaller than 16:00") {
                    expect(time) < Config.Time(hours: 16, minutes: 00)
                }

                it("is greater than 11:00") {
                    expect(time) > Config.Time(hours: 11, minutes: 00)
                }
            }
        }
    }
}
