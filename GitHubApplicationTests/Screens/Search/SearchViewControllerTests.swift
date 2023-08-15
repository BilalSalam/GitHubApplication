//
//  SearchViewControllerTests.swift
//  GitHubApplicationTests
//
//  Created by Bilal on 8/14/23.
//

import XCTest
import RxSwift
import RxCocoa
import RxTest
@testable import GitHubApplication

class SearchViewControllerTests: XCTestCase {

    var sut: SearchViewController!
    var disposeBag: DisposeBag!

    override func setUp() {
        super.setUp()

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tabBarController = storyboard.instantiateInitialViewController() as? UITabBarController
        let navigationController = tabBarController?.viewControllers?.first as? UINavigationController
        sut = navigationController?.topViewController as? SearchViewController
        sut.loadViewIfNeeded()
        disposeBag = DisposeBag()
    }

    override func tearDown() {
        sut = nil
        disposeBag = nil

        super.tearDown()
    }

    // Test if the getFollowersButton is enabled when the usernameTextField is not empty
    func testGetFollowersButtonEnabled() {
        // Given
        let username = "BilalSalam"
        sut.usernameTextField.text = username

        // When
        sut.setupBindings()

        // Then
        XCTAssertTrue(sut.getFollowersButton.isEnabled)
    }

    // Test if the getFollowersButton is disabled when the usernameTextField is empty
    func testGetFollowersButtonDisabled() {
        // Given
        sut.usernameTextField.text = ""

        // When
        sut.setupBindings()

        // Then
        XCTAssertFalse(sut.getFollowersButton.isEnabled)
    }

    // Test if pushFollowerListVC is called when the getFollowersButton is tapped
    func testPushFollowerListVC() {
        // Given
        let mockNavigationController = MockNavigationController(rootViewController: sut)
        UIApplication.shared.keyWindow?.rootViewController = mockNavigationController

        // When
        sut.pushFollowerListVC()

        // Then
        XCTAssertTrue(mockNavigationController.pushedViewController is FollowerListViewController)
    }
}

// Helper class to mock a navigation controller
class MockNavigationController: UINavigationController {

    var pushedViewController: UIViewController?

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        pushedViewController = viewController
        super.pushViewController(viewController, animated: animated)
    }
}
