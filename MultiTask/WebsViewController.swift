//
//  WebViewsController.swift
//  MultiTask
//
//  Created by rightmeow on 12/10/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit
import WebKit

class WebsViewController: BaseViewController, WKUIDelegate {

    // MARK: - API

    var url: String? = "https://google.com"

    static let storyboard_id = String(describing: WebsViewController.self)

    @IBOutlet weak var webView: WKWebView!

    private func loadWebSite() {
        guard let urlString = url else { return }
        if let urlLiteral = URL(string: urlString) {
            let urlRequest = URLRequest(url: urlLiteral)
            webView.load(urlRequest)
        }
    }

    private func setupWebView() {
        webView.uiDelegate = self
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupWebView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.loadWebSite()
    }

}
