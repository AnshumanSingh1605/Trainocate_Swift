//
//  DataVC.swift
//  Trainocate-swift
//
//  Created by 大空太陽 on 5/10/21.
//

import UIKit

class DataVC: UIViewController {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblBody: UILabel!
    @IBOutlet weak var lblPostID: UILabel!
    
    func configure(data : Post) {
        self.title = "Post ID: \(data.id)"

        lblTitle.text = data.title
        lblBody.text = data.body
        lblPostID.text = "Post ID: \(data.id)"
    }
}

