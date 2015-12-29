//
//  ViewController.swift
//  CameraTest
//
//  Created by yu yamashiro on 2015/12/29.
//  Copyright © 2015年 yuyamashiro. All rights reserved.
//

import UIKit
import AVFoundation

class CaneraViewController: UIViewController {
    
    // セッション.
    var mySession : AVCaptureSession!
    // デバイス.
    var myDevice : AVCaptureDevice!
    // 画像のアウトプット.
    var myImageOutput : AVCaptureStillImageOutput!
    
    // camera variables
    var isRequireTakePhoto: Bool = false
    var isProcessing: Bool = false
    var isFrontMode: Bool = false
    var isFlashMode: Bool = false
    var bitmap: Void?
    //　画像のアウトプット
    var videoOutput: AVCaptureVideoDataOutput!
    var captureInput: AVCaptureInput!
    //　セッション
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer?
    var imageBuffer: UIImage?
    var preView: UIView?
    var zoom: CGFloat = 1.0
    var queue: dispatch_queue_t?
    
    // buttons
    var shutterButton: UIButton?
    var frontButton: UIButton?
    var flashButton: UIButton?
    
    // label
    var flashLabel: UILabel?
    // container
    var buttonContainer: UIView?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        zoom = 1.0
        isFlashMode = false
        isFrontMode = false
        isProcessing = false
        isRequireTakePhoto = false
        /*var width = self.view.frame.size.width//640
        var height = self.view.frame.size.height//480
        var captureSize = width * height * 4
        //bitmap = malloc(captureSize)
        var colorSpace = CGColorSpaceCreateDeviceRGB()
        //var dataProviderRef = CGDataProviderCreateWithData(NULL, bitmap, captureSize, NULL)
        //var bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst
        //var cgImage = CGImageCreate(width, height, 8, 32, width * 4, colorSpace, bitmapInfo, dataProviderRef, NULL, 0, kCGRenderingIntentDefault)
        //var tes = CGImageCreate(<#T##width: Int##Int#>, <#T##height: Int##Int#>, <#T##bitsPerComponent: Int##Int#>, <#T##bitsPerPixel: Int##Int#>, <#T##bytesPerRow: Int##Int#>, <#T##space: CGColorSpace?##CGColorSpace?#>, <#T##bitmapInfo: CGBitmapInfo##CGBitmapInfo#>, <#T##provider: CGDataProvider?##CGDataProvider?#>, <#T##decode: UnsafePointer<CGFloat>##UnsafePointer<CGFloat>#>, <#T##shouldInterpolate: Bool##Bool#>, <#T##intent: CGColorRenderingIntent##CGColorRenderingIntent#>)
        */
        
        /****************************************************/
        
        // セッションの作成.
        mySession = AVCaptureSession()
        
        // デバイス一覧の取得.
        let devices = AVCaptureDevice.devices()
        
        // バックカメラをmyDeviceに格納.
        for device in devices{
            if(device.position == AVCaptureDevicePosition.Back){
                myDevice = device as! AVCaptureDevice
            }
        }
        
        // バックカメラからVideoInputを取得.
        
        var videoInput:AVCaptureDeviceInput = AVCaptureDeviceInput()
        
        do{
            videoInput = try AVCaptureDeviceInput(device: myDevice)
        }catch{
            print("error video input")
        }
        
        // セッションに追加.
        mySession.addInput(videoInput)
        
        // 出力先を生成.
        myImageOutput = AVCaptureStillImageOutput()
        
        // セッションに追加.
        mySession.addOutput(myImageOutput)
        
        // 画像を表示するレイヤーを生成.
        let myVideoLayer = AVCaptureVideoPreviewLayer(session: mySession)
        let width = self.view.bounds.width
        let height = self.view.bounds.height
        let barheight = self.navigationController?.navigationBar.frame.height
        let statusBarheight = UIApplication.sharedApplication().statusBarFrame.size.height
        
        myVideoLayer.frame = CGRectMake(0, barheight! + statusBarheight, width, height * 0.6)
        myVideoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        // Viewに追加.
        self.view.layer.addSublayer(myVideoLayer)
        
        // セッション開始.
        mySession.startRunning()
        
        //buttonをおくContainerを作成
        buttonContainer = UIView(frame: CGRectMake(0, self.view.frame.size.height * 0.82, self.view.frame.size.width, self.view.frame.size.height * 0.18))
        buttonContainer?.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        self.view.addSubview(buttonContainer!)
        
        ///buttons
        shutterButton = UIButton(type: .Custom)
        shutterButton?.frame = CGRectMake(0, 0, 64, 64)
        shutterButton?.center = CGPointMake(buttonContainer!.frame.size.width * 0.5, buttonContainer!.frame.size.height * 0.55)
        shutterButton!.setImage(UIImage(named: "CameraButton"), forState: .Normal)
        shutterButton?.addTarget(self, action: "onClickMyButton:", forControlEvents: .TouchUpInside)
        buttonContainer!.addSubview(shutterButton!)
        
        flashButton = UIButton(type: .Custom)
        flashButton!.frame = CGRectMake(0, 0, 26, 26)
        flashButton!.center = CGPointMake(buttonContainer!.frame.size.width * 0.9, buttonContainer!.frame.size.height * 0.74)
        flashButton!.setImage(UIImage(named: "flash"), forState: .Normal)
        flashButton!.addTarget(self, action: "flashButtonTouchUpInside:", forControlEvents:.TouchUpInside)
        buttonContainer!.addSubview(flashButton!)
        
        frontButton = UIButton(type: .Custom)
        frontButton!.frame = CGRectMake(0, 0, 26, 26)
        frontButton!.center = CGPointMake(buttonContainer!.frame.size.width * 0.9, buttonContainer!.frame.size.height * 0.40)
        frontButton!.setImage(UIImage(named: "changeCamera"), forState: .Normal)
        frontButton!.addTarget(self, action: "frontButtonTouchUpInside:", forControlEvents:.TouchUpInside)
        buttonContainer!.addSubview(frontButton!)

        //label
        flashLabel = UILabel(frame: CGRectMake(0, 0, 30, 20))
        flashLabel!.text = "OFF"
        flashLabel!.center = CGPointMake(flashButton!.center.x - 30, flashButton!.center.y)
        flashLabel!.font = UIFont.boldSystemFontOfSize(12)
        flashLabel!.textAlignment = .Right
        flashLabel!.textColor = UIColor.whiteColor()
        buttonContainer!.addSubview(flashLabel!)

        
    }
    
    // ボタンイベント.
    func onClickMyButton(sender: UIButton){
        
        // ビデオ出力に接続.
        let myVideoConnection = myImageOutput.connectionWithMediaType(AVMediaTypeVideo)
        
        // 接続から画像を取得.
        self.myImageOutput.captureStillImageAsynchronouslyFromConnection(myVideoConnection, completionHandler: { (imageDataBuffer, error) -> Void in
            
            
            // 取得したImageのDataBufferをJpegに変換.
            let myImageData : NSData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataBuffer)
            
            // JpegからUIIMageを作成.
            // let myImage : UIImage = UIImage(data: myImageData)!
            var myImage = UIImage(data: myImageData)!
            //切り取る範囲を決定
            let rect = CGRectMake(myImage.size.width*0.5 - myImage.size.width*(1.0/self.zoom)*0.5,
                myImage.size.height*0.5  - myImage.size.height*(1.0/self.zoom)*0.5,
                myImage.size.width*(1.0/self.zoom),
                myImage.size.height*(1.0/self.zoom))
            
            // アルバムに追加.
            UIImageWriteToSavedPhotosAlbum(myImage, self, nil, nil)
            
        })
    }
    
    //MARK: -Camera
    func captureOutput -> AVCaptureOutput{
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}