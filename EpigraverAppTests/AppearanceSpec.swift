//
//  AppearanceSpec.swift
//  EpigraverAppTests
//
//  Created by Robert Beeger on 23.05.20.
//  Copyright © 2020 Robert Beeger. All rights reserved.
//

import Foundation
import AppKit
import Quick
import Nimble
@testable import EpigraverApp

class AppearanceSpec: QuickSpec {
    typealias Config = EpigraverApp.Configuration

    override func spec() {
        describe("Appearance") {
            let appearance = Config.Appearance(
                foregroundColor: 0xff0000,
                backgroundColor: 0x00ff00,
                fontName: "some",
                fontSize: 26)

            it("creates correct background NSColor") {
                expect(appearance.backgroundNSColor) == NSColor(deviceRed: 0, green: 1, blue: 0, alpha: 1)
            }

            it("creates correct foreground NSColor") {
                expect(appearance.foregroundNSColor) == NSColor(deviceRed: 1, green: 0, blue: 0, alpha: 1)
            }
        }
    }
}
