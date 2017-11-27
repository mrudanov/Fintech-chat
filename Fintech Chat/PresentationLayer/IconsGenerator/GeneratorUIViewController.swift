//
//  GeneratorUIViewController.swift
//  Fintech Chat
//
//  Created by Mikhail Rudanov on 28/11/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import Foundation
import UIKit

class GeneratorViwController: UIViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let generator = IconsGenerator.generator
        generator.setTarget(view: view)
        if let firstTouch = touches.first {
            generator.startGenerating(from: firstTouch.location(in: view))
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let generator = IconsGenerator.generator
        if let firstTouch = touches.first {
            generator.setGeneratePosition(firstTouch.location(in: view))
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
