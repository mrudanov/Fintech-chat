//
//  RoundedImageView.swift
//  Fintech Chat
//
//  Created by Mikhail Rudanov on 29/09/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import UIKit

class RoundedImageView: UIImageView {

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var masksToBounds: Bool = true {
        didSet {
            self.layer.masksToBounds = masksToBounds
        }
    }
}
