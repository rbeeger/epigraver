//
//  Created by Robert Beeger on 27.06.20.
//  Copyright © 2020 Robert Beeger. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    class ScreenSaverTester: Main {
        var animationFrame = 0

        init() {
            super.init(frame: .zero, isPreview: false)!
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func selectConfiguration() {
            selectedAppearance = Appearance(
                foregroundColor: 0xF7F5E0,
                backgroundColor: 0x1C4A5C,
                fontName: "HoeflerText-Regular",
                fontSize: 25)
            selectedAnimator = HorizontalSlideAnimator()
            animationTimeInterval = 10
        }

        override func nextOutput() -> String {
            animationFrame += 1
            return """
                   Animationframe \(animationFrame)

                   Lorem ipsum dolor sit amet, consectetur adipisici elit,
                   sed eiusmod tempor incidunt ut labore et dolore magna aliqua.
                   Ut enim ad minim veniam, quis nostrud exercitation ullamco
                   laboris nisi ut aliquid ex ea commodi consequat.
                   """
        }

        override var isPreview: Bool {
            false
        }

        override func resetAnimator(animator: Animator) {
            animationFrame = 0
            super.resetAnimator(animator: animator)
        }
    }

    private lazy var screensaverView: ScreenSaverTester = {
        let view = ScreenSaverTester()
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

    private lazy var animatorPopupButton: NSPopUpButton = {
        let view = NSPopUpButton(frame: .zero, pullsDown: false)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addItems(withTitles: animators.map { $0.typeName })
        view.target = self
        view.action = #selector(animatorSelected)

        return view
    }()

    private lazy var bottomBar: NSBox = {
        let view = NSBox()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.titlePosition = .noTitle

        view.addSubview(animatorPopupButton)

        animatorPopupButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 8).isActive = true
        animatorPopupButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8).isActive = true
        animatorPopupButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        return view
    }()

    private let animators: [Animator] = [
        HorizontalSlideAnimator(),
        VerticalSlideAnimator(),
        ZoomAnimator(),
        RotateAnimator(),
        Rotate3DXAnimator(),
        Rotate3DYAnimator(),
        FadeAnimator()
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(screensaverView)
        view.addSubview(bottomBar)

        screensaverView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        screensaverView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        screensaverView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        screensaverView.bottomAnchor.constraint(equalTo: bottomBar.topAnchor).isActive = true

        bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bottomBar.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        screensaverView.startAnimation()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @objc
    private func animatorSelected() {
        guard let selectedAnimatorName = animatorPopupButton.titleOfSelectedItem else {
            return
        }

        screensaverView.resetAnimator(animator: animators.first { $0.typeName == selectedAnimatorName } ?? animators[0])
    }
}
