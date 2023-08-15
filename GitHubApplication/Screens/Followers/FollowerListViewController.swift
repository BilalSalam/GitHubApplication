//
//  FollowerListViewController.swift
//  GitHubApplication
//
//  Created by Bilal on 8/14/23.
//

import UIKit
import RxSwift
import RxCocoa

class FollowerListViewController: UIViewController {
    
    //MARK: Outlet
    @IBOutlet weak var followerTableView: UITableView! {
        didSet {
            self.followerTableView.delegate = self
        }
    }
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var viewModel = FollowerListViewModel()
    private let disposeBag = DisposeBag()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureViewController()
        self.configureTableView()
        self.bindViewModel()
        
        if let username = viewModel.username.value {
            // Set the title for this view controller
            self.title = username
            activityIndicator.startAnimating()
            activityIndicator.isHidden = false
            viewModel.fetchFollowers(for: username, type: viewModel.pageType, page: 1, perPage: 10)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    private func configureViewController() {
        view.backgroundColor = .systemBackground
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.tintColor = .systemGreen
        
        let favoriteImage = UIImage(systemName: "star")
        let favoriteBarButton = UIBarButtonItem(image: favoriteImage, style: .plain, target: self, action: #selector(addToFavouriteButtonTapped))
        navigationItem.rightBarButtonItem = favoriteBarButton
    }
    
    //Cell View ReuseIdentifier
    private func configureTableView() {
        
        let followerTableViewCell = UINib(nibName: FollowerTableViewCell.nibName, bundle: nil)
        followerTableView.register(followerTableViewCell, forCellReuseIdentifier: FollowerTableViewCell.nibName)
        
        // Create and configure the activity indicator
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.frame = CGRect(x: 0, y: 0, width: followerTableView.bounds.width, height: 44)
        
        // Set the activity indicator as the table view's footer view
        followerTableView.tableFooterView = activityIndicator
    }
    
    func bindViewModel() {
        
        viewModel.followers
            .observe(on: MainScheduler.instance)
            .bind(to: followerTableView.rx.items(cellIdentifier: FollowerTableViewCell.nibName, cellType: FollowerTableViewCell.self)) { _, user, cell in
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                cell.configure(with: user)
                cell.selectionStyle = .none
            }
            .disposed(by: disposeBag)
        
        viewModel.isFetchingObservable
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isFetching in
                if isFetching {
                    self?.activityIndicator.stopAnimating()
                    self?.activityIndicator.isHidden = true
                    self?.followerTableView.tableFooterView?.isHidden = false
                    if let activityIndicator = self?.followerTableView.tableFooterView as? UIActivityIndicatorView {
                        activityIndicator.startAnimating()
                    }
                } else {
                    if let activityIndicator = self?.followerTableView.tableFooterView as? UIActivityIndicatorView {
                        activityIndicator.stopAnimating()
                    }
                    self?.followerTableView.tableFooterView?.isHidden = true
                }
            })
            .disposed(by: disposeBag)
        
        
        viewModel.isLoadingObservable
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isLoading in
                if isLoading {
                    self?.activityIndicator.startAnimating()
                    self?.activityIndicator.isHidden = false
                } else {
                    self?.activityIndicator.stopAnimating()
                    self?.activityIndicator.isHidden = true
                    
                    if self?.viewModel.followers.value.isEmpty ?? true {
                        let message = "This user doesn't have any followers. Go follow them 😀."
                        DispatchQueue.main.async { self?.showEmptyStateView(with: message, in: self?.view ?? UIView()) }
                    }
                }
            })
            .disposed(by: disposeBag)
        
        followerTableView.rx.modelSelected(GitHubUser.self)
            .subscribe(onNext: { [weak self] selectedUser in
                
                let destVC = UserInfoViewController(username: selectedUser.login)
                destVC.username = selectedUser.login
                destVC.delegate = self
                
                let navController = UINavigationController(rootViewController: destVC)
                self?.present(navController, animated: true, completion: nil)
                
            })
            .disposed(by: disposeBag)
    }
    
    func showEmptyStateView(with message: String, in view: UIView) {
        let emptyStateView = GFEmptyStateView(message: message)
        emptyStateView.frame = view.bounds
        view.addSubview(emptyStateView)
    }
    
    @objc func addToFavouriteButtonTapped() {
        
        if let userName = viewModel.username.value {
            
            viewModel.fetchUserInfo(username: userName)
                .subscribe(onNext: { [weak self] user in
                    // Handle fetched user info, navigate to user details, etc.
                    print("Fetched user info: \(user)")
                    self?.addUserToFavorites(user: user)
                    
                }, onError: { [weak self] error in
                    // Handle the error and display an alert
                    self?.presentGFAlertOnMainThread(title: "Something went wrong", message: GFError.unableToFavorite.rawValue, buttonTitle: "Ok")
                })
                .disposed(by: disposeBag)
        }
    }
    
    func addUserToFavorites(user: User) {
        let favorite = Follower(login: user.login, avatarUrl: user.avatarUrl)
        
        PersistanceManager.updateWith(favorite: favorite, actionType: .add) { [weak self](error) in
            guard let self = self else { return }
            
            guard let error = error else {
                self.presentGFAlertOnMainThread(title: "Success!", message: "You have successfully favorited this user.", buttonTitle: "Ok")
                return
            }
            
            self.presentGFAlertOnMainThread(title: "Something went wrong", message: error.rawValue, buttonTitle: "Ok")
        }
    }
}

//MARK: UITableViewDelegate
extension FollowerListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastSection = tableView.numberOfSections - 1
        let lastRow = tableView.numberOfRows(inSection: lastSection) - 1
        
        if indexPath.section == lastSection && indexPath.row == lastRow && !viewModel.isFetching {
            viewModel.fetchNextPage()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 106
    }
}

extension FollowerListViewController: UserInfoVCDelegate {
    
    func didRequestFollowers(for username: String, type: ItemInfoType) {
        
        if type == .following {
            self.viewModel.pageType = "Followings"
        } else {
            self.viewModel.pageType = "Followers"
        }
        
        
        self.viewModel.followers.accept([])
        self.viewModel.username.accept(username)
        
        self.title = "\(username) \(self.viewModel.pageType)"
    }
}

