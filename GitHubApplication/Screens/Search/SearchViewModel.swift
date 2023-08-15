//
//  SearchViewModel.swift
//  GitHubApplication
//
//  Created by Bilal on 8/14/23.
//

import Foundation
import RxSwift
import RxCocoa

class SearchViewModel {
    
    let username = BehaviorRelay<String?>(value: nil)
    
    private let disposeBag = DisposeBag()
}
