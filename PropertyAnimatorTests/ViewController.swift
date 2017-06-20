//
//  ViewController.swift
//  PropertyAnimatorTests
//
//  Created by Worth Baker on 6/20/17.
//  Copyright © 2017 HouseCanary. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let normalDuration: TimeInterval = 4
    lazy var circleAnimator: UIViewPropertyAnimator = {
        return self.createAnimation()
    }()
    
    lazy var animatingView: UIView = {
        let av = UIView(frame: .zero)
        av.backgroundColor = .red
        
        return av
    }()
    
    var viewCenter = CGPoint.zero

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        animatingView.frame = CGRect(x: 24, y: view.bounds.height / 2.0, width: 150, height: 150)
        view.addSubview(animatingView)
        
        animatingView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(didPan)))
    }
    
    func createAnimation() -> UIViewPropertyAnimator {
        return UIViewPropertyAnimator(duration: normalDuration, curve: .easeInOut, animations: {
            self.animatingView.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
        })
    }
    
    func didPan(gesture: UIPanGestureRecognizer) {
        guard let target = gesture.view else { return }
        
        switch gesture.state {
        case .began, .ended:
            viewCenter = target.center
            
            let durationFactor = circleAnimator.fractionComplete
            
            // reset to inactive state
            circleAnimator.stopAnimation(true)
            
            if gesture.state == .began {
                circleAnimator.addAnimations {
                    target.backgroundColor = .blue
                    target.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
                }
            } else {
                circleAnimator.addAnimations {
                    target.backgroundColor = .red
                    target.transform = CGAffineTransform.identity
                }
            }
            
            circleAnimator.startAnimation()
            circleAnimator.pauseAnimation()
            circleAnimator.continueAnimation(withTimingParameters: nil, durationFactor: durationFactor)
        case .changed:
            let trans = gesture.translation(in: self.view)
            target.center = CGPoint(x: viewCenter.x + trans.x, y: viewCenter.y + trans.y)
        default:
            break
        }
    }

}
