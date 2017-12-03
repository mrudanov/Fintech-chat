//
//  GeneratorUIWindow.swift
//  Fintech Chat
//
//  Created by Mikhail Rudanov on 03/12/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import Foundation
import UIKit

class GeneratorUIWindow: UIWindow {
    private var emitterLayer: CAEmitterLayer = CAEmitterLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        emitterLayer.emitterShape = kCAEmitterLayerLine
        emitterLayer.emitterSize = CGSize(width: 1, height: 1)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sendEvent(_ event: UIEvent) {
        super.sendEvent(event)
        
        switch event.type {
        case .touches:
            let touches = event.allTouches
            if let firstTouch = touches?.first {
                if firstTouch.phase == .cancelled || firstTouch.phase == .ended {
                    emitterLayer.removeFromSuperlayer()
                } else {
                    emitterLayer.emitterPosition = firstTouch.location(in: self)
                    emitterLayer.emitterCells = [IconsCAEmitterCell()]
                    self.layer.addSublayer(emitterLayer)
                }
            }
            return
        default:
            return
        }
    }
}
