//
//  IconsGenerator.swift
//  Fintech Chat
//
//  Created by Mikhail Rudanov on 27/11/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import Foundation
import UIKit

class IconsGenerator {
    static var generator = IconsGenerator()
    
    private let maxYmove: UInt32 = 250
    private let maxXmove: UInt32 = 250
    private let minSize: Int = 50
    private let maxSize: Int = 120
    
    weak var view: UIView?
    private var currentPosition: CGPoint = CGPoint()
    private var imageViews: [UIImageView] = []
    private var timer: Timer = Timer()
    
    func setTarget(view : UIView?) {
        self.view = view
    }
    
    deinit {
        timer.invalidate()
    }
    
    func startGenerating(from point: CGPoint) {
        currentPosition = point
        timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true, block: addNewLogo)
        addNewLogo(timer: timer)
    }
    
    func stopGenerating() {
        timer.invalidate()
    }
    
    func setGeneratePosition(_ point: CGPoint) {
        currentPosition = point
    }
    
    private func addNewLogo(timer: Timer) {
        let image: UIImage = #imageLiteral(resourceName: "Tinkoff Logo")
        let imageView = UIImageView(image: image)
        let size = getRandomInt(min: minSize, max: minSize)
        imageView.frame = CGRect(x: 0, y: 0, width: size, height: size)
        imageView.contentMode = .scaleAspectFit
        imageView.center = currentPosition
        imageViews.append(imageView)
        view?.addSubview(imageView)
        animateImageView(imageView)
    }
    
    private func animateImageView(_ imageView: UIImageView) {
        UIView.animate(withDuration: 1.2, animations: {
            imageView.frame.origin.x += self.getRandomCGFloat(self.maxXmove)
            imageView.frame.origin.y += self.getRandomCGFloat(self.maxYmove)
            imageView.alpha = 0.0
        }) { finished in
            imageView.removeFromSuperview()
            if let index = self.imageViews.index(of: imageView) {
                self.imageViews.remove(at: index)
            }
        }
    }
    
    private func getRandomCGFloat(_ max: UInt32) -> CGFloat {
        let base = CGFloat(arc4random_uniform(max))
        if arc4random_uniform(2) == 0 {
            return base
        } else {
            return -base
        }
    }
    
    private func getRandomInt(min: Int,max: Int) -> Int {
        return min + Int(arc4random_uniform(UInt32(max)))
    }
}
