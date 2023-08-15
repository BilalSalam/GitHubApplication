//
//  SearchViewController.swift
//  GitHubApplication
//
//  Created by Bilal on 8/14/23.
//

import UIKit
import RxSwift
import RxCocoa

class SearchViewController: UIViewController {
    
    //MARK: Outlet
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var usernameTextField: GFTextField!
    @IBOutlet weak var getFollowersButton: GFButton!
    
    private let viewModel = SearchViewModel()
    private let disposeBag = DisposeBag()
    var isUsernameEntered: Bool { return !usernameTextField.text!.isEmpty }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        usernameTextField.delegate = self
        getFollowersButton.set(backgroundColor: .systemGreen, title: "Get Followers")
        setupBindings()
        createDismissKeyboardTapGesture()
    }
    
    func setupBindings() {
        let usernameText = usernameTextField.rx.text.orEmpty
        
        usernameText
            .map { !$0.isEmpty }
            .bind(to: getFollowersButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        getFollowersButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.pushFollowerListVC()
            })
            .disposed(by: disposeBag)
    }
    
    func createDismissKeyboardTapGesture() {
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:)))
        view.addGestureRecognizer(tap)
    }
    
    @objc func pushFollowerListVC() {
        guard isUsernameEntered else {
            presentGFAlertOnMainThread(title: "Empty Username", message: "Please enter a username. We need to know who to look for 😀", buttonTitle: "Ok")
            return
        }
        
        usernameTextField.resignFirstResponder()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let followerListVC = storyboard.instantiateViewController(withIdentifier: "FollowerListViewController") as? FollowerListViewController else {
            return
        }
        guard let navigationController = navigationController else {
            return
        }
        
        followerListVC.viewModel.username.accept(usernameTextField.text)
        followerListVC.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(followerListVC, animated: true)
    }
}

//MARK: UITextFieldDelegate
extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        pushFollowerListVC()
        return true
    }
}
