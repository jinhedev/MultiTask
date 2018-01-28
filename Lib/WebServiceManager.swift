//
//  WebServiceManager.swift
//  MultiTask
//
//  Created by rightmeow on 8/23/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import Foundation
import Alamofire

/**
 WebServiceType is a user-define enum that specified what type of data response the user expect to get.
 - warning: Expected response may or may not be the actual response. Be warned!
 */
enum WebServiceType {
    case tests
}

protocol WebServiceDelegate: NSObjectProtocol {
    // error
    func webService(_ manager: WebServiceManager, didErr error: Error, type: WebServiceType)
    // get
    func webService(_ manager: WebServiceManager, didFetch result: Any, type: WebServiceType)
    // post
    func webService(_ manager: WebServiceManager, didPost result: Any, type: WebServiceType)
    // patch
    func webService(_ manager: WebServiceManager, didPatch result: Any, type: WebServiceType)
    // delete
    func webService(_ manager: WebServiceManager, didDelete result: Any, type: WebServiceType)
}

extension WebServiceDelegate {
    // get
    func webService(_ manager: WebServiceManager, didFetch data: Any, type: WebServiceType) {}
    // post
    func webService(_ manager: WebServiceManager, didPost data: Any, type: WebServiceType) {}
    // patch
    func webService(_ manager: WebServiceManager, didPatch result: Any, type: WebServiceType) {}
    // delete
    func webService(_ manager: WebServiceManager, didDelete result: Any, type: WebServiceType) {}
}

class WebServiceManager: NSObject {

    weak var delegate: WebServiceDelegate?

    private func appendEndpointToBaseUrl(endpoint: String, baseUrl: String) -> String {
        let completeUrl = baseUrl + endpoint
        return completeUrl
    }

    // MARK: - Get

    func fetch(fromUrl: String, params: [String : Any]? = nil, headers: [String : String]? = nil, type: WebServiceType) {
        Alamofire.request(fromUrl, method: HTTPMethod.get, parameters: params, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (response) in
            switch response.result {
            case .success(let value):
                self.delegate?.webService(self, didFetch: value, type: type)
            case .failure(let error):
                self.delegate?.webService(self, didErr: error, type: type)
            }
        }
    }

    // MARK: - Post

    func post(fromUrl: String, params: [String : Any]? = nil, headers: [String : String]? = nil, type: WebServiceType) {
        Alamofire.request(fromUrl, method: HTTPMethod.post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            switch response.result {
            case .success(let value):
                self.delegate?.webService(self, didPost: value, type: type)
            case .failure(let error):
                self.delegate?.webService(self, didErr: error, type: type)
            }
        }
    }

    // MARK: - Patch

    func patch() {

    }

    // MARK: - Delete

    func delete() {
        
    }

    // MARK: - Auth

}

// MARK: - Realm Object Server

struct WebServiceConfigurations {

    private static let baseUrl = "52.14.43.212"

    struct endpoint {
        static let frontpage = "/posts/frontpage"
        static let usersub = "/posts/usersub"
    }

}

// MARK: - Web URL String

struct ExternalWebServiceUrlString {
    static let Trello = "https://trello.com/b/8fgpP9ZL/multitask-ios-client"
    static let TrelloApp = ""
    static let FAQ = "https://www.reddit.com/r/StarfishApp/"
    static let FAQRedditApp = ""
    static let Terms = "https://github.com/jinhedev/MultiTask/blob/develop/LICENSE.md"
    static let Test = "https://www.apple.com"
}
