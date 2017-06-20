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
    }
    
    func dragCircle(gesture: UIPanGestureRecognizer) {
        guard let target = gesture.view else { return }
        
        switch gesture.state {
        case .began:
            if let animator = circleAnimator, animator.isRunning {
                animator.stopAnimation(false)
            }
            
            circleCenter = target.center
        case .changed:
            let translation = gesture.translation(in: view)
            target.center = CGPoint(x: circleCenter.x + translation.x, y: circleCenter.y + translation.y)
        case .ended:
            let velocity = gesture.velocity(in: target)
            let vector = CGVector(dx: velocity.x / 500, dy: velocity.y / 500)
            let params = UISpringTimingParameters(mass: 2.5, stiffness: 70, damping: 55, initialVelocity: vector)
            circleAnimator = UIViewPropertyAnimator(duration: 0, timingParameters: params)
            
            circleAnimator?.addAnimations {
                target.center = self.view.center
            }
            
            circleAnimator?.startAnimation()
        default:
            break
        }
    }

}
