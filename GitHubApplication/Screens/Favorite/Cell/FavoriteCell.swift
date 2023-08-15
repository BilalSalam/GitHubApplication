//
//  FavoriteCell.swift
//  GitHubApplication
//
//  Created by Bilal on 8/14/23.
//

import UIKit
import Alamofire

class FavoriteCell: UITableViewCell {
    
    static let reusableID = "FavoriteCell"
    
    let avatarImageView = GFAvatarImageVIew(frame: .zero)
    let usernameLabel = GFTitleLabel(textAlignment: .left, fontSize: 26)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(favorite: Follower) {
        loadAvatarImage(from: URL(string: favorite.avatarUrl))
        usernameLabel.text = favorite.login
    }
    
    private func loadAvatarImage(from url: URL?) {
        if let imageUrl = url {
            Alamofire.request(imageUrl)
                .validate()
                .responseData { response in
                    switch response.result {
                    case .success(let data):
                        self.avatarImageView.image = UIImage(data: data)
                    case .failure(let error):
                        print("Failed to load avatar image: \(error)")
                    }
                }
        }
    }
    
    private func configure() {
        addSubviews(avatarImageView, usernameLabel)
        
        accessoryType = .disclosureIndicator
        let padding: CGFloat = 12
        
        NSLayoutConstraint.activate([
            avatarImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            avatarImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: padding),
            avatarImageView.heightAnchor.constraint(equalToConstant: 60),
            avatarImageView.widthAnchor.constraint(equalToConstant: 60),
            
            usernameLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            usernameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 24),
            usernameLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -padding),
            usernameLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
}
