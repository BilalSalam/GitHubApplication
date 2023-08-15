//
//  UserInfoViewModel.swift
//  GitHubApplication
//
//  Created by Bilal on 8/14/23.
//

import Foundation
import RxSwift
import RxCocoa

class UserInfoViewModel {
    
    private let userSubject = BehaviorRelay<User?>(value: nil)
    var user: Observable<User> {
        return userSubject.compactMap { $0 }
    }
    
    private let errorSubject = PublishSubject<Error>()
    
    private let disposeBag = DisposeBag()
    
    init(username: String) {
        let cachedUser = CoreDataManager.shared.fetchUserInfo(login: username)
        
        if let cachedUser = cachedUser {
            userSubject.accept(cachedUser)
        } else {
            GitHubAPIManager.fetchUserInfo(for: username)
                .do(onNext: { [weak self] user in
                    CoreDataManager.shared.saveUserInfo(user: user)
                    self?.userSubject.accept(user)
                }, onError: { [weak self] error in
                    self?.errorSubject.onNext(error)
                })
                .subscribe()
                .disposed(by: disposeBag)
        }
    }
    
    var error: Observable<Error> {
        return errorSubject.asObservable()
    }
}
