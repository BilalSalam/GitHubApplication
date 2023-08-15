//
//  GitHubAPIManager.swift
//  GitHubApplication
//
//  Created by Bilal on 8/14/23.
//

import Foundation
import RxSwift
import Alamofire
import UIKit

class GitHubAPIManager {
    
    // Mocking properties
    private static var isMockingEnabled = false
    private static var mockResponse: DataResponse<Any>?
    
    static func setMockingEnabled(_ isEnabled: Bool) {
        isMockingEnabled = isEnabled
    }
    
    static func setMockResponse(response: DataResponse<Any>?) {
        mockResponse = response
    }
    
    
    static func fetchFollowers(for username: String, page: Int, perPage: Int) -> Observable<[GitHubUser]> {
        
        // Check if mocking is enabled and return the mock response if available
        if isMockingEnabled, let mockResponse = mockResponse {
            return Observable.create { observer in
                observer.onNext(mockResponse.result.value as? [GitHubUser] ?? [])
                observer.onCompleted()
                return Disposables.create()
            }
        }
        
        return Observable.create { observer in
            let url = "https://api.github.com/users/\(username)/followers"
            let parameters: Parameters = [
                "page": page,
                "per_page": perPage
            ]
            Alamofire.request(url, parameters: parameters)
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .success(let value):
                        if let jsonArray = value as? [[String: Any]] {
                            let followers = jsonArray.compactMap { json -> GitHubUser? in
                                guard let followerUsername = json["login"] as? String,
                                      let avatarURLString = json["avatar_url"] as? String,
                                      let avatarURL = URL(string: avatarURLString) else {
                                    return nil
                                }
                                return GitHubUser(username: followerUsername, avatarURL: avatarURL)
                            }
                            observer.onNext(followers)
                        }
                    case .failure(let error):
                        observer.onError(error)
                    }
                }
            
            return Disposables.create()
        }
    }
    
    static func fetchFollowing(for username: String, page: Int, perPage: Int) -> Observable<[GitHubUser]> {
        return Observable.create { observer in
            let url = "https://api.github.com/users/\(username)/following"
            let parameters: Parameters = [
                "page": page,
                "per_page": perPage
            ]
            
            print("url: \(url)")
            Alamofire.request(url, parameters: parameters)
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .success(let value):
                        print("Response JSON: \(value)")
                        
                        if let jsonArray = value as? [[String: Any]] {
                            let followers = jsonArray.compactMap { json -> GitHubUser? in
                                guard let followerUsername = json["login"] as? String,
                                      let avatarURLString = json["avatar_url"] as? String,
                                      let avatarURL = URL(string: avatarURLString) else {
                                    return nil
                                }
                                return GitHubUser(username: followerUsername, avatarURL: avatarURL)
                            }
                            observer.onNext(followers)
                        }
                    case .failure(let error):
                        observer.onError(error)
                    }
                }
            
            return Disposables.create()
        }
    }
    
    
    static func fetchUserInfo(for username: String) -> Observable<User> {
        return Observable.create { observer in
            let endpoint = "https://api.github.com/users/\(username)"
            Alamofire.request(endpoint)
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .success(let value):
                        if let json = value as? [String: Any] {
                            do {
                                let data = try JSONSerialization.data(withJSONObject: json)
                                let decoder = JSONDecoder()
                                decoder.keyDecodingStrategy = .convertFromSnakeCase
                                decoder.dateDecodingStrategy = .iso8601
                                let user = try decoder.decode(User.self, from: data)
                                observer.onNext(user)
                            } catch {
                                observer.onError(error)
                            }
                        }
                    case .failure(let error):
                        observer.onError(error)
                    }
                }
            
            return Disposables.create()
        }
    }
}
