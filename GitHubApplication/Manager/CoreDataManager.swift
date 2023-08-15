//
//  CoreDataManager.swift
//  GitHubApplication
//
//  Created by Bilal on 8/14/23.
//

import Foundation
import CoreData

class CoreDataManager {
    
    static let shared = CoreDataManager()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "GitHubApplication")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func saveUserInfo(user: User) {
        let userInfo = UserInfo(context: context)
        userInfo.login = user.login
        userInfo.avatarUrl = user.avatarUrl
        userInfo.name = user.name
        userInfo.location = user.location
        userInfo.bio = user.bio
        userInfo.publicRepos = Int64(user.publicRepos)
        userInfo.publicGists = Int64(user.publicGists)
        userInfo.htmlUrl = user.htmlUrl
        userInfo.following = Int64(user.following)
        userInfo.followers = Int64(user.followers)
        userInfo.createdAt = user.createdAt
        
        saveContext()
    }
    
    func fetchUserInfo(login: String) -> User? {
        let fetchRequest: NSFetchRequest<UserInfo> = UserInfo.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "login == %@", login)
        fetchRequest.fetchLimit = 1
        
        do {
            let userInfo = try context.fetch(fetchRequest).first
            if let userInfo = userInfo {
                let user = User(login: userInfo.login ?? "",
                                avatarUrl: userInfo.avatarUrl ?? "",
                                publicRepos: Int(userInfo.publicRepos),
                                publicGists: Int(userInfo.publicGists),
                                htmlUrl: userInfo.htmlUrl ?? "",
                                following: Int(userInfo.following),
                                followers: Int(userInfo.followers),
                                createdAt: userInfo.createdAt ?? Date())
                return user
            }
        } catch {
            print("Error fetching user info: \(error)")
        }
        
        return nil
    }
}
