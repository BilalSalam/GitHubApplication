//
//  UITableViewExtension.swift
//  GitHubApplication
//
//  Created by Bilal on 8/14/23.
//

import UIKit

extension UITableView {
    func reloadDataOnMainThread() {
        DispatchQueue.main.async { self.reloadData() }
    }
    
    func removeExcessCells() {
        tableFooterView = UIView(frame: .zero)
    }
}
