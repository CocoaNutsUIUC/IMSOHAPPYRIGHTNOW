//
//  FaceView.swift
//  IMSOHAPPYRIGHTNOW
//
//  Created by Justin Loew on 9/22/15.
//  Copyright © 2015 Justin Loew. All rights reserved.
//

import UIKit

protocol FaceViewDataSource {
	func happinessAmountForFaceView(sender: FaceView) -> CGFloat
}

class FaceView: UIView {
	
	var happinessDataSource: FaceViewDataSource!
	var scale: CGFloat = 0.90 {
		// didSet is called every time the scale is set (after it has the new value)
		didSet {
			// don't allow zero scale
			if scale == 0 {
				scale = 0.90
			}
			// any time our scale changes, call for a redraw
			setNeedsDisplay()
		}
	}
	
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
		let context = UIGraphicsGetCurrentContext()!
		
		// get the center of the face to draw
		let midpoint = CGPoint(x: self.bounds.origin.x + self.bounds.size.width/2, y: self.bounds.origin.y + self.bounds.size.height/2)
		
		// get the size of the face to draw
		let faceSize: CGFloat
		if self.bounds.size.width < self.bounds.size.height {
			faceSize = self.bounds.size.width / 2 * scale
		} else {
			faceSize = self.bounds.size.height / 2 * scale
		}
		
		// we want to draw a blue line of width 5
		CGContextSetLineWidth(context, 5)
		UIColor.blueColor().setStroke()
		
		// draw a circle for the head
		drawCircleAtPoint(midpoint, withRadius: faceSize, inContext: context)
		
		// draw the eyes
		let eyeH: CGFloat = 0.35 // horizontal scale
		let eyeV: CGFloat = 0.35 // vertical scale
		let eyeR: CGFloat = 0.10 // radius
		
		let leftEyePoint = CGPoint(x: midpoint.x - faceSize * eyeH, y: midpoint.y - faceSize * eyeV)
		let rightEyePoint = CGPoint(x: midpoint.x + faceSize * eyeH, y: midpoint.y - faceSize * eyeV)
		drawCircleAtPoint(leftEyePoint, withRadius: faceSize * eyeR, inContext: context)
		drawCircleAtPoint(rightEyePoint, withRadius: faceSize * eyeR, inContext: context)
		
		// draw the mouth
		let mouthH: CGFloat = 0.45
		let mouthV: CGFloat = 0.40
		let mouthSmile: CGFloat = 0.25
		// ask how happy we should make it
		var smile = happinessDataSource.happinessAmountForFaceView(self)
		// constrain the size of the smile to the range -1...1
		if smile < -1 {
			smile = -1
		} else if smile > 1 {
			smile = 1
		}
		// apply the given amount of happiness to the size of our smile
		let smileOffset: CGFloat = mouthSmile * faceSize * smile
		
		// prepare all the points we'll need to draw the mouth
		let mouthStartPoint = CGPoint(x: midpoint.x - mouthH * faceSize, y: midpoint.y + mouthV * faceSize)
		let mouthEndPoint = CGPoint(x: mouthStartPoint.x + mouthH*faceSize*2, y: mouthStartPoint.y)
		let mouthCornerPoint1 = CGPoint(x: mouthStartPoint.x + mouthH*faceSize*2/3, y: mouthStartPoint.y + smileOffset)
		let mouthCornerPoint2 = CGPoint(x: mouthEndPoint.x - mouthH*faceSize*2/3, y: mouthEndPoint.y + smileOffset)
		
		// actually draw the mouth
		CGContextBeginPath(context)
		CGContextMoveToPoint(context, mouthStartPoint.x, mouthStartPoint.y)
		CGContextAddCurveToPoint(context, mouthCornerPoint1.x, mouthCornerPoint1.y,
			mouthCornerPoint2.x, mouthCornerPoint2.y,
			mouthEndPoint.x, mouthEndPoint.y)
		CGContextStrokePath(context)
    }
	
	func pinch(gesture: UIPinchGestureRecognizer) {
		if gesture.state == .Changed || gesture.state == .Ended {
			scale *= gesture.scale // adjust our scale
			gesture.scale = 1 // reset the gesture's scale to 1 (so future changes are incremental, not cumulative)
		}
	}
	
	private func drawCircleAtPoint(p: CGPoint, withRadius r: CGFloat, inContext context: CGContext) {
		UIGraphicsPushContext(context) // save the graphics settings before we draw our circle
		
		// draw the circle
		CGContextBeginPath(context)
		CGContextAddArc(context, p.x, p.y, r, 0, CGFloat(2*M_PI), 1) // 1 means true
		CGContextStrokePath(context)
		
		UIGraphicsPopContext() // restore the graphics settings we started with
	}
	
}
