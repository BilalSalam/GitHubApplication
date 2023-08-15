//
//  GFEmptyStateViewTests.swift
//  GitHubApplicationTests
//
//  Created by Bilal on 8/15/23.
//

import XCTest
@testable import GitHubApplication

class GFEmptyStateViewTests: XCTestCase {

    var emptyStateView: GFEmptyStateView!
    
    override func setUpWithError() throws {
        emptyStateView = GFEmptyStateView(message: "No data available")
    }

    override func tearDownWithError() throws {
        emptyStateView = nil
    }

    func testInitWithMessage() {
        // Given
        let message = "No data available"
        
        // Then
        XCTAssertEqual(emptyStateView.backgroundColor, .systemBackground)
        XCTAssertEqual(emptyStateView.messageLabel.text, message)
    }
    
    func testConfigureMessageLabel() {
        // Then
        XCTAssertEqual(emptyStateView.messageLabel.numberOfLines, 3)
        XCTAssertEqual(emptyStateView.messageLabel.textColor, .secondaryLabel)
    }
    
    func testConfigureLogoImageView() {
        // Then
        XCTAssertEqual(emptyStateView.logoImageView.image, Images.emptyStateLogo)
        XCTAssertFalse(emptyStateView.logoImageView.translatesAutoresizingMaskIntoConstraints)
    }    
}
