//
//  GeneratorUITableView.swift
//  Fintech Chat
//
//  Created by Mikhail Rudanov on 28/11/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import Foundation
import UIKit

class GeneratorTableView: UITableView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let generator = IconsGenerator.generator
        generator.setTarget(view: self)
        if let firstTouch = touches.first {
            generator.startGenerating(from: firstTouch.location(in: self))
        }
        
        super.touchesBegan(touches, with: event)
        self.next?.touchesBegan(touches, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let generator = IconsGenerator.generator
        if let firstTouch = touches.first {
            generator.setGeneratePosition(firstTouch.location(in: self))
        }
        
        super.touchesMoved(touches, with: event)
        self.next?.touchesMoved(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let generator = IconsGenerator.generator
        generator.stopGenerating()
        
        super.touchesEnded(touches, with: event)
        self.next?.touchesEnded(touches, with: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        let generator = IconsGenerator.generator
        generator.stopGenerating()
        
        super.touchesCancelled(touches, with: event)
        self.next?.touchesCancelled(touches, with: event)
    }
}
