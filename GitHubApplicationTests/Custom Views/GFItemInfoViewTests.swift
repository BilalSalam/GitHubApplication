//
//  GFItemInfoViewTests.swift
//  GitHubApplicationTests
//
//  Created by Bilal on 8/15/23.
//

import XCTest
@testable import GitHubApplication

class GFItemInfoViewTests: XCTestCase {
    
    var itemInfoView: GFItemInfoView!
    
    override func setUpWithError() throws {
        itemInfoView = GFItemInfoView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    }

    override func tearDownWithError() throws {
        itemInfoView = nil
    }

    func testSetReposItemInfo() {
        // Given
        let count = 10
        
        // When
        itemInfoView.set(itemInfoType: .repos, withCount: count)
        
        // Then
        XCTAssertEqual(itemInfoView.symbolImageView.image, SFSymbols.repos)
        XCTAssertEqual(itemInfoView.titleLabel.text, "Public Repos")
        XCTAssertEqual(itemInfoView.countLabel.text, String(count))
    }
    
    func testSetGistsItemInfo() {
        // Given
        let count = 5
        
        // When
        itemInfoView.set(itemInfoType: .gists, withCount: count)
        
        // Then
        XCTAssertEqual(itemInfoView.symbolImageView.image, SFSymbols.gists)
        XCTAssertEqual(itemInfoView.titleLabel.text, "Public Gists")
        XCTAssertEqual(itemInfoView.countLabel.text, String(count))
    }
    
    func testSetFollowersItemInfo() {
        // Given
        let count = 100
        
        // When
        itemInfoView.set(itemInfoType: .followers, withCount: count)
        
        // Then
        XCTAssertEqual(itemInfoView.symbolImageView.image, SFSymbols.followers)
        XCTAssertEqual(itemInfoView.titleLabel.text, "Followers")
        XCTAssertEqual(itemInfoView.countLabel.text, String(count))
    }
    
    func testSetFollowingItemInfo() {
        // Given
        let count = 50
        
        // When
        itemInfoView.set(itemInfoType: .following, withCount: count)
        
        // Then
        XCTAssertEqual(itemInfoView.symbolImageView.image, SFSymbols.following)
        XCTAssertEqual(itemInfoView.titleLabel.text, "Following")
        XCTAssertEqual(itemInfoView.countLabel.text, String(count))
    }
}
