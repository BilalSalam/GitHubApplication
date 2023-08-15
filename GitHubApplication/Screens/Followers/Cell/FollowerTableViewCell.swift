//
//  FollowerTableViewCell.swift
//  GitHubApplication
//
//  Created by Bilal on 8/14/23.
//

import UIKit
import Alamofire

class FollowerTableViewCell: UITableViewCell {
    
    static let nibName = "FollowerTableViewCell"
    
    //MARK: Outlet
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var userImageView: GFAvatarImageVIew!
    @IBOutlet weak var userNameLabel: GFTitleLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.containerView.backgroundColor = .secondarySystemBackground
        self.containerView.layer.cornerRadius = 12
        self.userImageView.asCircle()
    }
    
    func configure(with user: GitHubUser) {
        self.userNameLabel.text = user.login
        self.loadAvatarImage(from: user.avatarUrl)
    }
    
    private func loadAvatarImage(from url: URL) {
        Alamofire.request(url)
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    self.userImageView.image = UIImage(data: data)
                case .failure(let error):
                    print("Failed to load avatar image: \(error)")
                }
            }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.userImageView.image = nil
    }
}
