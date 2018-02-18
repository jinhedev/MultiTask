//
//  SoundEffectManager.swift
//  MultiTask
//
//  Created by rightmeow on 11/29/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit
import AVFoundation
import Amplitude

enum SoundEffect: String {
    case Bing
    case Tap
    case Click
    case Coin
    case Notification
}

/**
 SoundEffectManager handles and play custom sound assets in protocol orientated way.
 - remark: To use this class, make sure to set its delegate and conform to the SoundEffectDelegate methods.
 */
class SoundEffectManager: NSObject {

    static let shared = SoundEffectManager()
    var player: AVAudioPlayer?

    func play(soundEffect: SoundEffect) {
        if let url = Bundle.main.url(forResource: soundEffect.rawValue, withExtension: "wav") {
            do {
                let sound = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
                self.player = sound
                sound.numberOfLoops = 0 // play once
                sound.prepareToPlay()
                sound.volume = 0.93
                sound.play()
            } catch let err {
                print(err.localizedDescription)
                Amplitude.instance().logEvent(LogEventType.pathError)
            }
        } else {
            print("When modifying asset files in the project directory, please match their name by the SoundEffect enum to avoid crash.")
            Amplitude.instance().logEvent(LogEventType.pathError)
            fatalError("Incorrect name to .wav asset.")
        }
    }

}
