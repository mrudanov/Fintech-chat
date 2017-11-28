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
    private let minMove: UInt32 = 30
    private let maxMove: UInt32 = 250
    private let minSize: Int = 30
    private let maxSize: Int = 100
    
    weak var view: UIView?
    private var currentPosition: CGPoint = CGPoint()
    private var imageViews: [UIImageView] = []
    private var timer: Timer = Timer()
    
    deinit {
        timer.invalidate()
    }
    
    func setTarget(view : UIView?) {
        self.view = view
    }
    
    func startGenerating(from point: CGPoint) {
        print("Started generating")
        currentPosition = point
        timer.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true, block: addNewLogo)
        addNewLogo(timer: timer)
    }
    
    func stopGenerating() {
        print("Stopen generating")
        timer.invalidate()
    }
    
    func setGeneratePosition(_ point: CGPoint) {
        currentPosition = point
    }
    
    private func addNewLogo(timer: Timer) {
        let image: UIImage = #imageLiteral(resourceName: "Tinkoff Logo")
        let imageView = UIImageView(image: image)
        let size = getRandomInt(min: minSize, max: maxSize)
        imageView.frame = CGRect(x: 0, y: 0, width: size, height: size)
        imageView.contentMode = .scaleAspectFit
        imageView.center = currentPosition
        imageViews.append(imageView)
        view?.addSubview(imageView)
        animateImageView(imageView)
    }
    
    private func animateImageView(_ imageView: UIImageView) {
        UIView.animate(withDuration: 1.2, animations: {
            imageView.frame.origin.x += self.getRandomCGFloat(min: self.minMove, max: self.maxMove)
            imageView.frame.origin.y += self.getRandomCGFloat(min: self.minMove, max: self.maxMove)
            imageView.alpha = 0.0
        }) { finished in
            imageView.removeFromSuperview()
            if let index = self.imageViews.index(of: imageView) {
                self.imageViews.remove(at: index)
            }
        }
    }
    
    private func getRandomCGFloat(min: UInt32, max: UInt32) -> CGFloat {
        let base = CGFloat(arc4random_uniform(max - min))
        if arc4random_uniform(2) == 0 {
            return base + CGFloat(min)
        } else {
            return -(base + CGFloat(min))
        }
    }
    
    private func getRandomInt(min: Int,max: Int) -> Int {
        return min + Int(arc4random_uniform(UInt32(max - min)))
    }
}
