//
//  GeneratorUICollectionView.swift
//  Fintech Chat
//
//  Created by Mikhail Rudanov on 28/11/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import Foundation
import UIKit

class GeneretorUICollectionVeiw: UICollectionView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.next?.touchesBegan(touches, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.touchesMoved(touches, with: event)
        
        super.touchesMoved(touches, with: event)
        self.next?.touchesMoved(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.touchesEnded(touches, with: event)
        
        super.touchesEnded(touches, with: event)
        self.next?.touchesEnded(touches, with: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.touchesCancelled(touches, with: event)
        
        super.touchesCancelled(touches, with: event)
        self.next?.touchesCancelled(touches, with: event)
    }
}
