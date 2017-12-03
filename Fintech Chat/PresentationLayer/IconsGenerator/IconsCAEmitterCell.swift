//
//  IconsCAEmitterCell.swift
//  Fintech Chat
//
//  Created by Mikhail Rudanov on 02/12/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import Foundation
import UIKit


class IconsCAEmitterCell: CAEmitterCell {
    override init() {
        super.init()
        self.birthRate = 3.0
        self.lifetime = 2
        self.lifetimeRange = 0
        
        self.alphaSpeed = -1.0 / lifetime
        
        self.scaleRange = 0.08
        self.scale = 0.1
        self.scaleSpeed = -0.01
        
        self.velocity = 100
        self.velocityRange = 30
        
        self.emissionLongitude = 0
        self.emissionRange = CGFloat.pi * 2
        
        self.spin = 2
        self.spinRange = 2
        
        self.contents = UIImage(named: "Tinkoff Logo")?.cgImage
    }
    
    private func getRandomInt(min: Int,max: Int) -> Int {
        return min + Int(arc4random_uniform(UInt32(max - min)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
