//
//  UserInfoViewController.swift
//  GitHubApplication
//
//  Created by Bilal on 8/14/23.
//

import UIKit
import RxSwift
import RxCocoa

protocol UserInfoVCDelegate: class {
    func didRequestFollowers(for username: String, type: ItemInfoType)
}

class UserInfoViewController: UIViewController {
    
    let scrollView = UIScrollView()
    let contentView = UIView()
    
    let headerView = UIView()
    let itemViewOne = UIView()
    let itemViewTwo = UIView()
    let itemViewThree = UIView()
    var itemViews = [UIView]()
    let dateLabel = GFBodyLabel(textAlignment: .center)
    
    var username: String!
    weak var delegate: UserInfoVCDelegate!
    let viewModel: UserInfoViewModel
    private let disposeBag = DisposeBag()
    
    init(username: String) {
        self.username = username
        self.viewModel = UserInfoViewModel(username: username)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewController()
        configureScrollView()
        layoutUI()
        getUserInfo()
    }
    
    func configureViewController() {
        view.backgroundColor = .systemBackground
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissVC))
        navigationItem.rightBarButtonItem = doneButton
    }
    
    func configureScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.pinToEdges(of: view)
        contentView.pinToEdges(of: scrollView)
        
        NSLayoutConstraint.activate([
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.heightAnchor.constraint(equalToConstant: 800)
        ])
    }
    
    func getUserInfo() {
        viewModel.user
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] user in
                DispatchQueue.main.async { self?.configureUIElements(with: user) }
            })
            .disposed(by: disposeBag)
        
        viewModel.error
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] error in
                self?.presentGFAlertOnMainThread(title: "Something went wrong", message: "Unable to complete your request. Please check your internet connection.", buttonTitle: "Ok")
            })
            .disposed(by: disposeBag)
    }
    
    func configureUIElements(with user: User) {
        
        // Check if the user is stored in Core Data
        if let storedUser = CoreDataManager.shared.fetchUserInfo(login: user.login) {
            // Update UI with stored user data
            self.add(childVC: GFRepoItemVC(user: user, delegate: self), to: self.itemViewOne)
            self.add(childVC: GFFollowerItemVC(user: user, type: .followers, delegate: self), to: self.itemViewTwo)
            self.add(childVC: GFFollowerItemVC(user: user, type: .following, delegate: self), to: self.itemViewThree)
            self.add(childVC: GFUserInfoHeaderVC(user: user), to: self.headerView)
            
            self.dateLabel.text = "GitHub since \(user.createdAt.convertToMonthYearFormat())"
            
            // Show the date when the stored user was fetched
            //            dateLabel.text = "Fetched from Core Data: \(storedUser.createdAt.convertToMonthYearFormat())"
        } else {
            // The user is not stored in Core Data, update UI with API-fetched data
            self.add(childVC: GFRepoItemVC(user: user, delegate: self), to: self.itemViewOne)
            self.add(childVC: GFFollowerItemVC(user: user, type: .followers, delegate: self), to: self.itemViewTwo)
            self.add(childVC: GFFollowerItemVC(user: user, type: .following, delegate: self), to: self.itemViewThree)
            self.add(childVC: GFUserInfoHeaderVC(user: user), to: self.headerView)
            self.dateLabel.text = "GitHub since \(user.createdAt.convertToMonthYearFormat())"
        }
        
    }
    
    func layoutUI() {
        let padding: CGFloat = 20
        let itemHeight: CGFloat = 140
        itemViews = [headerView, itemViewOne, itemViewTwo, itemViewThree, dateLabel]
        
        for itemView in itemViews {
            contentView.addSubview(itemView)
            itemView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                itemView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
                itemView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            ])
        }
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 210),
            
            itemViewOne.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: padding),
            itemViewOne.heightAnchor.constraint(equalToConstant: itemHeight),
            
            itemViewTwo.topAnchor.constraint(equalTo: itemViewOne.bottomAnchor, constant: padding),
            itemViewTwo.heightAnchor.constraint(equalToConstant: itemHeight),
            
            itemViewThree.topAnchor.constraint(equalTo: itemViewTwo.bottomAnchor, constant: padding),
            itemViewThree.heightAnchor.constraint(equalToConstant: itemHeight),
            
            dateLabel.topAnchor.constraint(equalTo: itemViewThree.bottomAnchor, constant: padding),
            dateLabel.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func add(childVC: UIViewController, to containerView: UIView) {
        addChild(childVC)
        containerView.addSubview(childVC.view)
        childVC.view.frame = containerView.bounds
        childVC.didMove(toParent: self)
    }
    
    @objc func dismissVC() {
        dismiss(animated: true, completion: nil)
    }
}

extension UserInfoViewController: GFRepoItemVCDelegate {
    func didTapGitHubProfile(for user: User) {
        guard let url = URL(string: user.htmlUrl) else {
            presentGFAlertOnMainThread(title: "Invalid URL", message: "The url attached to this user is invalid.", buttonTitle: "Ok")
            return
        }
        presentSafariVC(with: url)
    }
}

//MARK: GFFollowerItemVCDelegate
extension UserInfoViewController: GFFollowerItemVCDelegate {
    func didTapGetFollowers(for user: User, type: ItemInfoType) {
        
        if type == .followers && user.followers == 0  {
            presentGFAlertOnMainThread(title: "No Followers", message: "This user has no followers", buttonTitle: "Ok")
            return
        }
        
        if type == .following && user.following == 0 {
            presentGFAlertOnMainThread(title: "No Following", message: "This user has no following", buttonTitle: "Ok")
            return
        }
        
        delegate.didRequestFollowers(for: user.login, type: type)
        dismissVC()
    }
}
