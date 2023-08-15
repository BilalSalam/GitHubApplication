//
//  FollowerListViewModel.swift
//  GitHubApplication
//
//  Created by Bilal on 8/15/23.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire

class FollowerListViewModel {
    
    let username = BehaviorRelay<String?>(value: nil)
    var followers = BehaviorRelay<[GitHubUser]>(value: [])
    let isLoadingSubject = BehaviorRelay<Bool>(value: false)
    
    let perPage = 10
    var currentPage = 1
    var isFetching = false
    var pageType = "Followers"
    
    var isFetchingObservable: Observable<Bool> {
        return Observable.just(isFetching)
    }
    
    var isLoading: Bool {
        return isLoadingSubject.value
    }
    
    var isLoadingObservable: Observable<Bool> {
        return isLoadingSubject.asObservable()
    }
    
    private let disposeBag = DisposeBag()
    
    init() {
        setupBindings()
    }
    
    func setupBindings() {
        isLoadingSubject.accept(true)
        
        username
            .filter { $0 != nil }
            .flatMapLatest { username in
                self.fetchFollowers(for: username!, type: self.pageType, page: self.currentPage, perPage: self.perPage)
                    .observe(on: MainScheduler.instance)
                    .catchAndReturn([])
                    .do(onNext: { _ in
                        self.isLoadingSubject.accept(false)
                    })
            }
            .subscribe(onNext: { [weak self] newFollowers in
                self?.followers.accept(newFollowers)
            })
            .disposed(by: disposeBag)
    }
    
    func fetchNextPage() {
        guard let username = username.value, !isFetching else { return }
        isFetching = true
        
        fetchFollowers(for: username, type: pageType, page: currentPage + 1, perPage: perPage)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] newFollowers in
                guard let self = self else { return }
                
                if newFollowers.isEmpty {
                    self.isFetching = false
                    self.isLoadingSubject.accept(false) // Stop loading
                    return
                }
                
                self.currentPage += 1
                self.followers.accept(self.followers.value + newFollowers)
                self.isFetching = false
            }, onError: { [weak self] error in
                self?.isFetching = false
                print("Error fetching followers: \(error)")
            })
            .disposed(by: disposeBag)
    }
    
    func fetchFollowers(for username: String, type: String, page: Int, perPage: Int) -> Observable<[GitHubUser]> {
        
        if pageType == "Followers" {
            return GitHubAPIManager.fetchFollowers(for: username, page: page, perPage: perPage)
            
        } else {
            return GitHubAPIManager.fetchFollowing(for: username, page: page, perPage: perPage)
        }
    }
    
    func fetchUserInfo(username: String) -> Observable<User> {
        return GitHubAPIManager.fetchUserInfo(for: username)
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] user in
                // Save user info to Core Data if needed
            })
            .catch { error in
                // Handle the error as needed, you can also propagate the error
                return Observable.error(error)
            }
    }
}
