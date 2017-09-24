//
//  ProfileViewController.swift
//  Fintech Chat
//
//  Created by Mikhail Rudanov on 24/09/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var avatarImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.avatarImage.layer.cornerRadius = self.avatarImage.frame.size.width / 2
        self.avatarImage.clipsToBounds = true
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - View lifecycle methods

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("Profile ViewController is going to appear. Called func: \(#function)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("Profile ViewController has appeared. Called func: \(#function)")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        print("Profile ViewController is going to layout it's subviews. Called func: \(#function)")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("Profile ViewController has finished subviews layout. Called func: \(#function)")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("Profile ViewController is going to disappear. Called func: \(#function)")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("Profile ViewController has disappeared. Called func: \(#function)")
    }
}
