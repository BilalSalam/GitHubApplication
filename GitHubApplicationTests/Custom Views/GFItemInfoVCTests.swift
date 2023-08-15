//
//  GFItemInfoVCTests.swift
//  GitHubApplicationTests
//
//  Created by Bilal on 8/15/23.
//

import XCTest
@testable import GitHubApplication

class GFItemInfoVCTests: XCTestCase {

    var itemInfoVC: GFItemInfoVC!
    
    override func setUpWithError() throws {
        itemInfoVC = GFItemInfoVC(user: User(login: "username",
                                             avatarUrl: "https://example.com/avatar.png",
                                             publicRepos: 2,
                                             publicGists: 2,
                                             htmlUrl: "htmlUrl",
                                             following: 5,
                                             followers:6,
                                             createdAt: Date()))
        itemInfoVC.loadViewIfNeeded()
    }

    override func tearDownWithError() throws {
        itemInfoVC = nil
    }

    func testInitWithUser() {
        // Then
        XCTAssertEqual(itemInfoVC.user.login, "username")
    }
    
    func testConfigureBackgroundView() {
        // Then
        XCTAssertEqual(itemInfoVC.view.layer.cornerRadius, 18)
        XCTAssertEqual(itemInfoVC.view.backgroundColor, .secondarySystemBackground)
    }
    
    func testConfigureStackView() {
        // Then
        XCTAssertEqual(itemInfoVC.stackView.axis, .horizontal)
        XCTAssertEqual(itemInfoVC.stackView.distribution, .equalSpacing)
        XCTAssertEqual(itemInfoVC.stackView.arrangedSubviews.count, 2)
    }
    
    func testConfigureActionButton() {
        // When
        let target = itemInfoVC.actionButton.actions(forTarget: itemInfoVC, forControlEvent: .touchUpInside)
        
        // Then
        XCTAssertTrue(target?.contains("actionButtonTapped") ?? false)
    }
}

