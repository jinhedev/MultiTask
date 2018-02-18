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
 WebServiceType is a user-define enum that specifies what type of data response the user expect to get for response.
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
