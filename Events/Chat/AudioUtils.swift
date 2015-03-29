//
//  AudioUtils.swift
//  Heyz
//
//  Created by Jay Yu on 2015-03-28.
//  Copyright (c) 2015 Teknowledge Software. All rights reserved.
//

import Foundation
import AVFoundation

class AudioUtils: NSObject, AVAudioPlayerDelegate{
    
    let recorder: AVAudioRecorder!
    let recordURL: NSURL!
    
    var player: AVAudioPlayer?
    var playCompletion: (() -> ())?
    
    override init() {
        
        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord, error: nil)
        
        let recordSettings = NSDictionary(objectsAndKeys:
            8000.0, AVSampleRateKey,
            kAudioFormatMPEG4AAC, AVFormatIDKey,
            1, AVNumberOfChannelsKey,
            16, AVLinearPCMBitDepthKey,
            AVAudioQuality.Min.rawValue, AVEncoderAudioQualityKey,
            AVAudioQuality.Min.rawValue, AVSampleRateConverterAudioQualityKey
        )
        
        let path = NSTemporaryDirectory().stringByAppendingPathComponent("record.caf")
        recordURL = NSURL(fileURLWithPath: path)
        recorder = AVAudioRecorder(URL: recordURL, settings: recordSettings, error: nil)
        
        recorder.prepareToRecord()
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        if (self.playCompletion != nil) {
            self.playCompletion!()
        }
    }
    
    func playData(data: NSData, completion: () -> ()) {
        playWithPlayer(AVAudioPlayer(data: data, error: nil), completion: completion)
    }
    
    func playWithPlayer(player: AVAudioPlayer, completion: () -> ()){
        if self.player != nil {
            if self.player!.playing {
                self.player!.stop()
                self.playCompletion!()
            }
        }
        
        self.playCompletion = completion
        
        self.player = player
        self.player!.delegate = self
        
        self.player!.play()
    }
    
    func startRecord(recordingView: UIViewController) {
        let hud = MBProgressHUD.showHUDAddedTo(recordingView.view, animated: true)
        hud.mode = MBProgressHUDMode.Indeterminate
        hud.labelText = "Recording"
        recorder.record()
        
    }
    
    func stopRecord(recordingView: UIViewController, onAfterSuccess: (NSURL, NSTimeInterval) -> (), onAfterFailure: () -> ()) {
        
        let time = recorder.currentTime
        recorder.stop()
        
        MBProgressHUD.hideAllHUDsForView(recordingView.view, animated: true)
        
        if time < 1 {
            onAfterFailure()
            
            let hud = MBProgressHUD.showHUDAddedTo(recordingView.view, animated: true)
            hud.mode = MBProgressHUDMode.Text
            hud.labelText = "Time too short"

            let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC)))
            dispatch_after(popTime, dispatch_get_main_queue()) {
                MBProgressHUD.hideAllHUDsForView(recordingView.view, animated: true)
                return
            }
            
        } else {
            onAfterSuccess(recordURL, time)
            
        }
    }
    
    
    class var sharedUtils: AudioUtils{
        
        struct Static {
            static var instance: AudioUtils?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token){
            Static.instance = AudioUtils()
        }
        
        return Static.instance!
    }
}
