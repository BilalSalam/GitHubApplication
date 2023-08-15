//
//  UserInfo+CoreDataProperties.swift
//  
//
//  Created by Bilal on 8/14/23.
//
//

import Foundation
import CoreData

extension UserInfo {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserInfo> {
        return NSFetchRequest<UserInfo>(entityName: "UserInfo")
    }
    
    @NSManaged public var login: String?
    @NSManaged public var avatarUrl: String?
    @NSManaged public var name: String?
    @NSManaged public var location: String?
    @NSManaged public var bio: String?
    @NSManaged public var publicRepos: Int64
    @NSManaged public var publicGists: Int64
    @NSManaged public var htmlUrl: String?
    @NSManaged public var following: Int64
    @NSManaged public var followers: Int64
    @NSManaged public var createdAt: Date?
    
}
