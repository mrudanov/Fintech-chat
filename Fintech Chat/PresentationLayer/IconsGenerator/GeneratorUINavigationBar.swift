//
//  GeneratorNavigationBar.swift
//  Fintech Chat
//
//  Created by Mikhail Rudanov on 28/11/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import Foundation
import UIKit

class GeneratorNavigationBar: UINavigationBar {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let generator = IconsGenerator.generator
        generator.setTarget(view: self)
        if let firstTouch = touches.first {
            generator.startGenerating(from: firstTouch.location(in: self))
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let generator = IconsGenerator.generator
        if let firstTouch = touches.first {
            generator.setGeneratePosition(firstTouch.location(in: self))
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let generator = IconsGenerator.generator
        generator.stopGenerating()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        let generator = IconsGenerator.generator
        generator.stopGenerating()
    }
}
