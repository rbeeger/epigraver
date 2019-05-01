//
// Created by Robert Beeger on 2019-02-02.
// Copyright (c) 2019 Robert Beeger. All rights reserved.
//

import Foundation
import AppKit
import os

class ScheduleConfigurationViewController: NSViewController {
    init() {
        super.init(nibName: nil, bundle: nil)
        self.title = "Schedule"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        os_log("######  view did load 0")
    }

    override func loadView() {
        view = NSView()
    }
}
