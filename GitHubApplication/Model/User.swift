//
//  User.swift
//  GitHubApplication
//
//  Created by Bilal on 8/14/23.
//

import Foundation

struct User: Codable {
    
    let login: String
    let avatarUrl: String
    var name: String?
    var location: String?
    var bio: String?
    let publicRepos: Int
    let publicGists: Int
    let htmlUrl: String
    let following: Int
    let followers: Int
    let createdAt: Date
    
    init(login: String, avatarUrl: String, name: String? = nil, location: String? = nil, bio: String? = nil, publicRepos: Int, publicGists: Int, htmlUrl: String, following: Int, followers: Int, createdAt: Date) {
        self.login = login
        self.avatarUrl = avatarUrl
        self.name = name
        self.location = location
        self.bio = bio
        self.publicRepos = publicRepos
        self.publicGists = publicGists
        self.htmlUrl = htmlUrl
        self.following = following
        self.followers = followers
        self.createdAt = createdAt
    }
}
