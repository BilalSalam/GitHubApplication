//
//  GFFollowerItemVC.swift
//  GitHubApplication
//
//  Created by Bilal on 8/14/23.
//

import UIKit

protocol GFFollowerItemVCDelegate: class {
    func didTapGetFollowers(for user: User, type: ItemInfoType)
}

class GFFollowerItemVC: GFItemInfoVC {
    
    weak var delegate: GFFollowerItemVCDelegate!
    var type: ItemInfoType = .followers
    
    init(user: User, type: ItemInfoType, delegate: GFFollowerItemVCDelegate) {
        super.init(user: user)
        self.delegate = delegate
        self.type = type
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureItems()
    }
    
    private func configureItems() {
        
        switch type {
        case .followers:
            itemInfoViewOne.set(itemInfoType: .followers, withCount: user.followers)
            actionButton.set(backgroundColor: .systemGreen, title: "Get Followers")
            
        case .following:
            itemInfoViewOne.set(itemInfoType: .following, withCount: user.following)
            actionButton.set(backgroundColor: .systemCyan, title: "Get Following")
            
        default:
            return
        }
    }
    
    override func actionButtonTapped() {
        delegate.didTapGetFollowers(for: user, type: type)
    }
}
