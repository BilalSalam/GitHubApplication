//
//  FollowerListViewModelTests.swift
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

class FollowerListViewModelTests: XCTestCase {
    
    var viewModel: FollowerListViewModel!
    var disposeBag: DisposeBag!
    var testScheduler: TestScheduler!

    override func setUpWithError() throws {
        try super.setUpWithError()
        disposeBag = DisposeBag()
        
        // Initialize the test scheduler
        testScheduler = TestScheduler(initialClock: 0)

        // Create a mock GitHubAPIManager for testing
        GitHubAPIManager.setMockingEnabled(true)
        
        viewModel = FollowerListViewModel()
    }
    
    override func tearDownWithError() throws {
        GitHubAPIManager.setMockingEnabled(false)
        
        viewModel = nil
        disposeBag = nil
        try super.tearDownWithError()
    }
    
    // Helper function to create a mocked Alamofire DataResponse
    private func createMockedDataResponse<T: Encodable>(_ value: T) -> DataResponse<Any> {
        let jsonEncoder = JSONEncoder()
        let data = try! jsonEncoder.encode(value)
        
        let url = URL(string: "https://example.com")!
        let httpResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        
        return DataResponse(request: nil, response: httpResponse, data: data, result: .success(data))
    }
    
    func testFetchFollowers_Success() {
        // Prepare mock data
        let mockFollowers: [GitHubUser] = [
            GitHubUser(username: "user1", avatarURL: URL(string: "https://example.com/avatar1.png")!),
            GitHubUser(username: "user2", avatarURL: URL(string: "https://example.com/avatar2.png")!)
        ]
        let mockResponse = createMockedDataResponse(mockFollowers)
        GitHubAPIManager.setMockResponse(response: mockResponse)

        // Print the mock data
        print("Mock data:")
        for follower in mockFollowers {
            print("Login: \(follower.login), Avatar URL: \(follower.avatarUrl)")
        }

        // Setup test observer
        let followersObserver = testScheduler.createObserver([GitHubUser].self)
        viewModel.followers
            .bind(to: followersObserver)
            .disposed(by: disposeBag)

        // Trigger fetch followers
        viewModel.username.accept("testuser")
        viewModel.fetchFollowers(for: "testuser", type: "Followers", page: 1, perPage: 10)

        // Run the test scheduler
        testScheduler.start()

        // Get the actual emitted events
        let actualEvents = followersObserver.events

        // Extract the actual followers data from the emitted events
        guard let actualFollowers = actualEvents.last?.value.element else {
            XCTFail("No followers data emitted")
            return
        }

        // Validate the mocked data and the API result
        print("Actual Followers:")
        for follower in actualFollowers {
            print("LoginZ: \(follower.login), Avatar URL: \(follower.avatarUrl)")
        }
        
        // Validate the mocked data and the API result
        XCTAssertEqual(actualFollowers, mockFollowers)
    }
}
