//
//  ViewController.swift
//  PropertyAnimatorTests
//
//  Created by Worth Baker on 6/20/17.
//  Copyright © 2017 HouseCanary. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var circleCenter = CGPoint.zero
    
    var circleAnimator: UIViewPropertyAnimator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let circle = UIView(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
        circle.center = view.center
        circle.layer.cornerRadius = 75
        circle.backgroundColor = .green
        
        circle.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(dragCircle)))
        view.addSubview(circle)
        
        circleAnimator = UIViewPropertyAnimator(duration: 1.0, curve: .linear, animations: { 
            circle.transform = CGAffineTransform(scaleX: 3.0, y: 3.0)
        })
        
        circleAnimator?.addAnimations({
            circle.backgroundColor = UIColor.blue
        }, delayFactor: 0.75)
    }
    
    func dragCircle(gesture: UIPanGestureRecognizer) {
        guard let target = gesture.view else { return }
        
        switch gesture.state {
        case .began:
            circleCenter = target.center
        case .changed:
            let translation = gesture.translation(in: view)
            target.center = CGPoint(x: circleCenter.x + translation.x, y: circleCenter.y + translation.y)
            
            circleAnimator?.fractionComplete = target.center.y / view.frame.height
        default:
            break
        }
    }

}
