//
//  GitHubUser.swift
//  GitHubApplication
//
//  Created by Bilal on 8/14/23.
//

import Foundation

struct GitHubUser: Codable {
    
    var login: String
    let avatarUrl: URL
    
    init(username: String, avatarURL: URL) {
        self.login = username
        self.avatarUrl = avatarURL
    }
}

extension GitHubUser: Equatable {
    static func == (lhs: GitHubUser, rhs: GitHubUser) -> Bool {
        return lhs.login == rhs.login && lhs.avatarUrl.absoluteString == rhs.avatarUrl.absoluteString
    }
}
