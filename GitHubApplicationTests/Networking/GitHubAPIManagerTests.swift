//
//  GitHubAPIManagerTests.swift
//  GitHubApplicationTests
//
//  Created by Bilal on 8/15/23.
//

import XCTest
import RxSwift
import RxCocoa
import RxTest
import Alamofire
@testable import GitHubApplication

class GitHubAPIManagerTests: XCTestCase {
    
    var disposeBag: DisposeBag!
    
    override func setUp() {
        super.setUp()
        disposeBag = DisposeBag()
    }
    
    override func tearDown() {
        disposeBag = nil
        super.tearDown()
    }
    
    func testFetchFollowers() {
        let username = "BilalSalam"
        let page = 1
        let perPage = 10
        
        let expectation = XCTestExpectation(description: "Fetch followers")
        
        // Mock Alamofire request with a response
        GitHubAPIManager.fetchFollowers(for: username, page: page, perPage: perPage)
            .subscribe(onNext: { followers in
                // Check if followers array is not empty
                XCTAssertFalse(followers.isEmpty)
                expectation.fulfill()
            }, onError: { error in
                XCTFail("Error: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testFetchFollowing() {
        let username = "BilalSalam"
        let page = 1
        let perPage = 10
        
        let expectation = XCTestExpectation(description: "Fetch following")
        
        // Mock Alamofire request with a response
        GitHubAPIManager.fetchFollowing(for: username, page: page, perPage: perPage)
            .subscribe(onNext: { following in
                
                // Check if following array is not empty
                XCTAssertFalse(following.isEmpty, "Following array is empty")
                
                expectation.fulfill()
            }, onError: { error in
                XCTFail("Error: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    
    func testFetchUserInfo() {
        let username = "BilalSalam"
        
        let expectation = XCTestExpectation(description: "Fetch user info")
        
        // Mock Alamofire request with a response
        GitHubAPIManager.fetchUserInfo(for: username)
            .subscribe(onNext: { user in
                // Check if user object is not nil
                XCTAssertNotNil(user)
                expectation.fulfill()
            }, onError: { error in
                XCTFail("Error: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 5.0)
    }
}
