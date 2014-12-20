//
//  CameraViewController.swift
//  SampleQXCameraKit
//
//  Created by Hirakawa Akira on 14/12/14.
//  Copyright (c) 2014 akirahrkw. All rights reserved.
//

import UIKit
import QXCameraKit

class CameraViewController: UIViewController, UIActionSheetDelegate {

    @IBOutlet var zoomInButton:UIButton?
    
    @IBOutlet var zoomOutButton:UIButton?
    
    @IBOutlet var touchView:AFTouchView?
    
    @IBOutlet var liveImageView:UIImageView?
    
    var manager:QXAPIManager
    
    var isCameraMode:Bool
    
    var options:NSArray?
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(){
        manager = QXAPIManager()
        isCameraMode = false
        super.init(nibName:"CameraViewController", bundle:nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.touchView!.manager = self.manager
        self.liveImageView!.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2));
        self.touchView!.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2));
        
        var btn = UIBarButtonItem(barButtonSystemItem:UIBarButtonSystemItem.Camera, target:self, action:"changeIsoSpeed:")
        self.navigationItem.leftBarButtonItem = btn
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        var gestureZoomIn = UILongPressGestureRecognizer(target:self, action:"didTapLongPressedZoomIn:")
        var gestureZoomOut = UILongPressGestureRecognizer(target:self, action:"didTapLongPressedZoomOut:")
        self.zoomInButton?.addGestureRecognizer(gestureZoomIn)
        self.zoomOutButton?.addGestureRecognizer(gestureZoomOut)
        
        NSThread.detachNewThreadSelector("openConnection", toTarget:self, withObject:nil)
    }

    @IBAction func takePicture(sender:AnyObject) {

        self.manager.takePicture({ [unowned self] (json:NSDictionary, isSucceeded:Bool) in
            
            var image = self.manager.didTakePicture(json) as UIImage?
            if(image == nil) {
                return
            }
            
            var height = CGImageGetHeight(image!.CGImage)
            var width = CGImageGetWidth(image!.CGImage)

            var x = CGFloat((width - height) / 2)
            var cropRect = CGRectMake( x, 0, 1080, 1080)
        
            var imageRef = CGImageCreateWithImageInRect(image!.CGImage, cropRect)
            var croppedImage = UIImage(CGImage:imageRef)
            
            
            width = CGImageGetWidth(croppedImage!.CGImage)
            height = CGImageGetHeight(croppedImage!.CGImage)
            
            var clockwise = false
            var size = croppedImage!.size
            
            UIGraphicsBeginImageContext(CGSizeMake(size.height, size.width))
            
            var orientation = clockwise ? UIImageOrientation.Right : UIImageOrientation.Left
            
            var newImage = UIImage(CGImage:croppedImage!.CGImage, scale:1.0, orientation:orientation)
            
            newImage?.drawInRect(CGRectMake(0,0,size.height ,size.width))
            
            var rotatedImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            UIImageWriteToSavedPhotosAlbum(rotatedImage,nil,nil,nil);
        })
    }
    
    func openConnection() {

        self.manager.openConnection({[unowned self] (result:Bool, error:NSError?) -> () in
            if(result) {
                self.manager.startLiveImage({ [unowned self] (image:UIImage, error:NSError?) -> () in
                  
                    var height = CGImageGetHeight(image.CGImage)
                    var width = CGImageGetWidth(image.CGImage)
                    
                    var x = CGFloat((width - height) / 2)
                    var cropRect = CGRectMake(x, 0, 480, 480)
                    
                    var imageRef = CGImageCreateWithImageInRect(image.CGImage, cropRect)
                    var croppedImage = UIImage(CGImage:imageRef)
                    
                    self.synchronized(self) {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.liveImageView!.image = croppedImage
                        })
                    }
                })
            }
            else {
                var alertView = UIAlertView(title:"failed to connect", message:nil, delegate:nil, cancelButtonTitle:"OK")
                alertView.show()
            }
        })
    }

    // MARK: - Callback
    func didTapLongPressedZoomIn(gestureRecognizer:UILongPressGestureRecognizer) {
        switch(gestureRecognizer.state){
            case UIGestureRecognizerState.Began:
                self.manager.api?.startZoomIn({ [unowned self] (json:NSDictionary, isSucceeded:Bool) in
                    NSLog("%@", json)
                })
                break
            case UIGestureRecognizerState.Ended:
                self.manager.api?.stopZoomIn({ [unowned self] (json:NSDictionary, isSucceeded:Bool) in
                    NSLog("%@", json)
                })
                break
            default:
                break
        }
    }

    func didTapLongPressedZoomOut(gestureRecognizer:UILongPressGestureRecognizer) {
        switch(gestureRecognizer.state){
        case UIGestureRecognizerState.Began:
            self.manager.api?.startZoomOut({ [unowned self] (json:NSDictionary, isSucceeded:Bool) in
                NSLog("%@", json)
            })
            break
        case UIGestureRecognizerState.Ended:
            self.manager.api?.stopZoomOut({ [unowned self] (json:NSDictionary, isSucceeded:Bool) in
                NSLog("%@", json)
            })
            break
        default:
            break
        }
    }
    
    func changeIsoSpeed(id:AnyObject) {
        if(self.isCameraMode == false) {
            self.isCameraMode = true
            self.manager.api!.getAvailableIsoSpeedRate({[unowned self] (json:NSDictionary, isSucceeded:Bool) in
                self.isCameraMode = false;
                NSLog("%@", json);
                var array = json.objectForKey("result") as NSArray
                self.showIsoSpeed(array[0] as NSString, availables:array[1] as NSArray)
            })
        }
    }
    
    func showIsoSpeed(current:NSString, availables:NSArray) {
        self.options = availables
        
        var sheet = UIActionSheet(title:"ISO", delegate:self, cancelButtonTitle:"Cancel", destructiveButtonTitle:nil)
        for val in availables {
            sheet.addButtonWithTitle(val as NSString)
        }
        sheet.showInView(self.view)
    }
    
    // the implementation of @synchronized in swift
    func synchronized(obj: AnyObject, closure:() -> ()) {
        objc_sync_enter(obj)
        closure()
        objc_sync_exit(obj)
    }
}
