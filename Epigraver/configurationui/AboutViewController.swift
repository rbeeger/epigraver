//
// Created by Robert Beeger on 06.06.20.
// Copyright (c) 2020 Robert Beeger. All rights reserved.
//

import Foundation
import AppKit
import WebKit
import os

class AboutViewController: NSViewController {
    private lazy var webView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        let view = WKWebView(frame: .zero, configuration: webConfiguration)
        view.navigationDelegate = self

        return view
    }()

    init() {
        super.init(nibName: nil, bundle: nil)
        self.title = "About"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        os_log(.info, "############# Load %{public}@", Bundle.main.description)

        let bundle = Bundle(for: AboutViewController.self)

        guard let htmlUrl = bundle.url(forResource: "about", withExtension: "html"),
              var urlComponents = URLComponents(url: htmlUrl, resolvingAgainstBaseURL: true) else {
            os_log(.info, "############# Not loaded")
            return
        }

        let version = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "unknown"

        urlComponents.queryItems = [
            URLQueryItem(name: "version", value: version)
        ]

        webView.load(URLRequest(url: urlComponents.url!))
    }
}

extension AboutViewController: WKNavigationDelegate {
    public func webView(_ webView: WKWebView,
                        decidePolicyFor navigationAction: WKNavigationAction,
                        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }
        if url.description.lowercased().starts(with: "http://") ||
                   url.description.lowercased().starts(with: "https://") {
            decisionHandler(.cancel)
            NSWorkspace.shared.open(url)
        } else {
            decisionHandler(.allow)
        }
    }
}
