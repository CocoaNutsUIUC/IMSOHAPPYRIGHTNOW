//
//  ViewController.swift
//  IMSOHAPPYRIGHTNOW
//
//  Created by Justin Loew on 9/22/15.
//  Copyright © 2015 Justin Loew. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	
	// 0 for sad, 100 for happy
	var happiness: Int = 0 {
		didSet {
			faceView.setNeedsDisplay()
		}
	}
	@IBOutlet weak var faceView: FaceView! {
		didSet {
			faceView.happinessDataSource = self
			
			// enable pinch gestures in the FaceView using its pinch() handler
			faceView.addGestureRecognizer(UIPinchGestureRecognizer(target: faceView, action: "pinch:"))
			
			// make it so when we drag up and down, the smile changes
			faceView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "handleHappinessChange:"))
		}
	}
	
	func handleHappinessChange(gesture: UIPanGestureRecognizer) {
		if gesture.state == .Changed || gesture.state == .Ended {
			// move the smile up and down based on how far the user drags
			let translationAmount: CGPoint = gesture.translationInView(faceView)
			happiness += Int(translationAmount.y / 2)
			// constrain happiness to the range 0...100
			if happiness < 0 {
				happiness = 0
			} else if happiness > 100 {
				happiness = 100
			}
			
			gesture.setTranslation(CGPointZero, inView: faceView)
		}
	}
	
	override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
		faceView.setNeedsDisplay()
	}
}

extension ViewController: FaceViewDataSource {
	func happinessAmountForFaceView(sender: FaceView) -> CGFloat {
		// happiness is 0-100. Smile range is -1 to 1.
		return CGFloat(happiness - 50) / 50
	}
}
