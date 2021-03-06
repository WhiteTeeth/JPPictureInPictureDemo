//
//  JPPlayerViewController.swift
//  JPPictureInPictureDemo
//
//  Created by 周健平 on 2020/6/25.
//

import UIKit
import AVKit

var playerVC_ : JPPlayerViewController?

class JPPlayerViewController: UIViewController {
    
    var videoPath: String!
    var playerView : JPPlayerView!
    
    var pipCtr : AVPictureInPictureController?
    fileprivate var stopPipComplete : (()->())?
    
    weak var navCtr : UINavigationController?
    
    let backBtn : UIButton = {
        let backBtn = UIButton(type: .system)
        backBtn.setImage(UIImage(named: "com_left_white_icon"), for: .normal)
        backBtn.frame = CGRect(x: 0, y: jp_statusBarH_, width: jp_navBarH_, height: jp_navBarH_)
        backBtn.tintColor = .white
        return backBtn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.clipsToBounds = true
        backBtn.addTarget(self, action: #selector(__backAction), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.addSubview(backBtn)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
        navCtr = navigationController
        
        if playerVC_ == self {
            pipCtr?.stopPictureInPicture()
        }
    }
    
    @objc private func __backAction() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK:- API
extension JPPlayerViewController {
    func createPlayerView(_ frame: CGRect, videoURL: URL) {
        playerView = JPPlayerView(frame: frame)
        
        if AVPictureInPictureController.isPictureInPictureSupported() == true {
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback)
                try AVAudioSession.sharedInstance().setActive(true, options: [])
            } catch {
                print("AVAudioSession发生错误")
            }
            
            pipCtr = AVPictureInPictureController(playerLayer: playerView.playerLayer)
            pipCtr?.delegate = self
        }
        
        playerView.setupVideoURL(videoURL, pipCtr: pipCtr)
    }
    
    func stopPictureInPicture(_ complete: (()->())?) {
        if let pipCtr = pipCtr, pipCtr.isPictureInPictureActive == true {
            stopPipComplete = complete
            pipCtr.stopPictureInPicture()
        } else {
            stopPipComplete = nil
        }
    }
}

// MARK:- <AVPictureInPictureControllerDelegate>
extension JPPlayerViewController : AVPictureInPictureControllerDelegate {
    /**
        @method        pictureInPictureControllerWillStartPictureInPicture:
        @param        pictureInPictureController
                    The Picture in Picture controller.
        @abstract    Delegate can implement this method to be notified when Picture in Picture will start.
     */
    func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("pictureInPictureControllerWillStartPictureInPicture")
        playerVC_ = self
        navigationController?.popViewController(animated: true)
    }

    
    /**
        @method        pictureInPictureControllerDidStartPictureInPicture:
        @param        pictureInPictureController
                    The Picture in Picture controller.
        @abstract    Delegate can implement this method to be notified when Picture in Picture did start.
     */
    func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("pictureInPictureControllerDidStartPictureInPicture")
    }

    
    /**
        @method        pictureInPictureController:failedToStartPictureInPictureWithError:
        @param        pictureInPictureController
                    The Picture in Picture controller.
        @param        error
                    An error describing why it failed.
        @abstract    Delegate can implement this method to be notified when Picture in Picture failed to start.
     */
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, failedToStartPictureInPictureWithError error: Error) {
        print("failedToStartPictureInPictureWithError")
    }

    
    /**
        @method        pictureInPictureControllerWillStopPictureInPicture:
        @param        pictureInPictureController
                    The Picture in Picture controller.
        @abstract    Delegate can implement this method to be notified when Picture in Picture will stop.
     */
    func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("pictureInPictureControllerWillStopPictureInPicture")
    }

    
    /**
        @method        pictureInPictureControllerDidStopPictureInPicture:
        @param        pictureInPictureController
                    The Picture in Picture controller.
        @abstract    Delegate can implement this method to be notified when Picture in Picture did stop.
     */
    func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("pictureInPictureControllerDidStopPictureInPicture")
        playerVC_ = nil
        if let complete = stopPipComplete { complete() }
        stopPipComplete = nil
    }

    
    /**
        @method        pictureInPictureController:restoreUserInterfaceForPictureInPictureStopWithCompletionHandler:
        @param        pictureInPictureController
                    The Picture in Picture controller.
        @param        completionHandler
                    The completion handler the delegate needs to call after restore.
        @abstract    Delegate can implement this method to restore the user interface before Picture in Picture stops.
     */
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        print("restoreUserInterfaceForPictureInPictureStopWithCompletionHandler")
        
        if stopPipComplete == nil,
           let navCtr = navCtr,
           navCtr.viewControllers.contains(self) != true {
            
            playerVC_ = nil
            navCtr.pushViewController(self, animated: true)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.15) {
                completionHandler(true)
            }
            return
        }
        
        completionHandler(true)
    }
}
