//
//  ViewController.swift
//  PropertyAnimatorTests
//
//  Created by Worth Baker on 6/20/17.
//  Copyright © 2017 HouseCanary. All rights reserved.
//

import UIKit

enum State {
    case expanded, minimized
}

class ViewController: UIViewController {
    
    var runningAnimators = [Int: UIViewPropertyAnimator]()
    var progressWhenInterrupted: CGFloat = 0
    
    lazy var width: CGFloat = { return self.view.frame.width - 8 }()
    lazy var topFrame: CGRect = { return CGRect(x: 4, y: 100, width: self.width, height: self.view.frame.height) }()
    lazy var bottomFrame: CGRect = { return CGRect(x: 4, y: self.view.frame.height - 100, width: self.width, height: self.view.frame.height) }()
    lazy var totalVerticalDistance: CGFloat = { self.bottomFrame.minY - self.topFrame.minY }()
    
    var viewState: State = .minimized
    lazy var bottomView: UIView = {
        let bv = UIView(frame: .zero)
        bv.backgroundColor = .red
        bv.layer.cornerRadius = 4
        
        return bv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bottomView.frame = bottomFrame
        view.addSubview(bottomView)
        
        bottomView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bottomViewTapped)))
        bottomView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(bottomViewPanned)))
    }
    
    func animateTransitionIfNeeded(state: State, duration: TimeInterval) {
        if runningAnimators.isEmpty {
            let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                switch state {
                case .minimized:
                    self.bottomView.frame = self.topFrame
                case .expanded:
                    self.bottomView.frame = self.bottomFrame
                }
            }
            
            let identifier = frameAnimator.hash
            frameAnimator.addCompletion { position in
                self.cleanup(animatorWithId: identifier, at: position)
            }
            
            frameAnimator.startAnimation()
            runningAnimators[identifier] = frameAnimator
        }
    }
    
    func bottomViewPanned(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: bottomView)
        let verticalTranslation = viewState == .minimized ? -translation.y : translation.y
        let fraction = (verticalTranslation / totalVerticalDistance) + progressWhenInterrupted
        
        switch gesture.state {
        case .began:
            animateTransitionIfNeeded(state: viewState, duration: 0.5)
            
            runningAnimators.forEach { $1.pauseAnimation() }
            progressWhenInterrupted = runningAnimators.first?.value.fractionComplete ?? 0
        case .changed:
            runningAnimators.forEach { $1.fractionComplete = fraction }
        case .ended:
            let velocity = gesture.velocity(in: bottomView)
            
            switch viewState {
            case .minimized:
                if velocity.y > -500 && fraction < 0.5 {
                    runningAnimators.forEach { $1.isReversed = !$1.isReversed }
                }
            case .expanded:
                if velocity.y < 500 && fraction < 0.5 {
                    runningAnimators.forEach { $1.isReversed = !$1.isReversed }
                }
            }
            
            runningAnimators.forEach { $1.continueAnimation(withTimingParameters: nil, durationFactor: 1) }
        default:
            break
        }
    }
    
    func bottomViewTapped(gesture: UITapGestureRecognizer) {
        if runningAnimators.isEmpty {
            animateTransitionIfNeeded(state: viewState, duration: 0.5)
        } else {
            runningAnimators.forEach { $1.isReversed = !$1.isReversed }
        }
    }
    
    func cleanup(animatorWithId identifier: Int, at position: UIViewAnimatingPosition) {
        if position == .end {
            switch self.bottomView.frame {
            case self.bottomFrame:
                self.viewState = .minimized
            case self.topFrame:
                self.viewState = .expanded
            default:
                break
            }
        }
        
        self.runningAnimators.removeValue(forKey: identifier)
    }

}
