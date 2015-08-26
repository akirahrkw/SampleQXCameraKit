//
//  AFTouchView.swift
//  SampleQXCameraKit
//
//  Created by Hirakawa Akira on 17/12/14.
//  Copyright (c) 2014 akirahrkw. All rights reserved.
//

import UIKit
import QXCameraKit

class AFTouchView: UIView {

    weak var manager:QXAPIManager?

    var isTapLongPressed:Bool?
    
    override func awakeFromNib() {
        self.isTapLongPressed = false
        let gesture = UILongPressGestureRecognizer(target:self, action:"didTapLongPressed:")
        
        self.addGestureRecognizer(gesture)
    }
    
    func didTapLongPressed(gestureRecognizer:UILongPressGestureRecognizer) {

        if (gestureRecognizer.state == UIGestureRecognizerState.Began) {
            if(self.isTapLongPressed!) {
                self.isTapLongPressed = true
                
                self.manager?.api?.actHalfPressShutter({ (json:NSDictionary, result:Bool) in
                    NSLog("actHalfPressShutterWithAPIResponseBlock: %@", json);
                })
            }
        } else if(gestureRecognizer.state == UIGestureRecognizerState.Ended) {
            self.manager?.api?.cancelHalfPressShutter({ [unowned self] (json:NSDictionary, result:Bool) in
                self.isTapLongPressed = false
                NSLog("cancelHalfPressShutterWithAPIResponseBlock: %@", json);
            })
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {

        let point = touches.first!.locationInView(self)
        let base = UIScreen.mainScreen().bounds.size.width

        // in this view
        var x:CGFloat = point.x / base;
        var y:CGFloat = point.y / base;
        
        // in live view
        let baseWidth:CGFloat = 480.0;
        let liveX:CGFloat = 480.0;
        let liveY:CGFloat = 640.0;
        
        x = ((x * baseWidth) +  0) / liveX * 100;
        y = ((y * baseWidth) + 80) / liveY * 100;
        
        //change
        NSLog("x:\(point.x) y:\(point.y)");
        NSLog("\(x) \(y)");

        self.manager?.api?.setTouchAFPosition(x, y:y, closure:{ (json:NSDictionary, result:Bool) in
            NSLog("actHalfPressShutterWithAPIResponseBlock: %@", json);
        })
    }
}
