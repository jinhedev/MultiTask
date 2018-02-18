//
//  WebServiceConfigurations.swift
//  MultiTask
//
//  Created by sudofluff on 2/17/18.
//  Copyright © 2018 Duckensburg. All rights reserved.
//

import Foundation

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
