//
//  WebServiceManager.swift
//  MultiTask
//
//  Created by rightmeow on 8/23/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import Foundation

protocol WebServiceDelegate: NSObjectProtocol {
    // error
    func webService(_ manager: WebServiceManager, didErr error: Error)
    // auth
    func webServiceDidLogin(_ manager: WebServiceManager, user: Any, session: Any)
    func webServiceDidLogout(_ manager: WebServiceManager)
    func webServiceDidSignup(_ manager: WebServiceManager)
    // posts
    func webSerivceDidCreate(_ manager: WebServiceManager, posts: Any)
    func webServiceDidFetch(_ manager: WebServiceManager, posts: Any)
    func webServiceDidUpdate(_ manager: WebServiceManager, posts: Any)
    func webServiceDidDelete(_ manager: WebServiceManager, posts: Any)
    // comments
    func webServiceDidCreate(_ manager: WebServiceManager, comments: Any)
    func webServiceDidFetch(_ manager: WebServiceManager, comments: Any)
    func webServiceDidUpdate(_ manager: WebServiceManager, comments: Any)
    func webServiceDidDelete(_ manager: WebServiceManager, comments: Any)
}

extension WebServiceDelegate {
    // auth
    func webServiceDidLogin(_ manager: WebServiceManager, user: Any, session: Any) {}
    func webServiceDidLogout(_ manager: WebServiceManager) {}
    func webServiceDidSignup(_ manager: WebServiceManager) {}
    // posts
    func webSerivceDidCreate(_ manager: WebServiceManager, posts: Any) {}
    func webServiceDidFetch(_ manager: WebServiceManager, posts: Any) {}
    func webServiceDidUpdate(_ manager: WebServiceManager, posts: Any) {}
    func webServiceDidDelete(_ manager: WebServiceManager, posts: Any) {}
    // comments
    func webServiceDidCreate(_ manager: WebServiceManager, comments: Any) {}
    func webServiceDidFetch(_ manager: WebServiceManager, comments: Any) {}
    func webServiceDidUpdate(_ manager: WebServiceManager, comments: Any) {}
    func webServiceDidDelete(_ manager: WebServiceManager, comments: Any) {}
}

class WebServiceManager: NSObject {

    weak var delegate: WebServiceDelegate?

    private func appendEndpointToBaseUrl(endpoint: String, baseUrl: String) -> String {
        let completeUrl = baseUrl + endpoint
        return completeUrl
    }

    // MARK: - Get

    func fetch(endpoint: String) {

    }

    // MARK: - Create

    // MARK: - Update

    // MARK: - Delete

    // MARK: - Auth

    // ...

}

// MARK: - Realm Object Server

struct WebServiceConfigurations {

    private static let baseUrl = "52.14.43.212"

    struct endpoint {
        static let frontpage = "/posts/frontpage"
        static let usersub = "/posts/usersub"
    }

}




















