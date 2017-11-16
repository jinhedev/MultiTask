//
//  BaseViewController.swift
//  MultiTask
//
//  Created by rightmeow on 11/9/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit
import AVFoundation

class BaseViewController: UIViewController {

    private func setupView() {
        self.view.backgroundColor = Color.inkBlack
    }

    // MARK: - Application sound notification

    var avaPlayer: AVAudioPlayer?

    enum AlertSoundType: String {
        case error = "Error"
        case success = "Success"
    }

    func playAlertSound(type: AlertSoundType) {
        guard let sound = NSDataAsset(name: type.rawValue) else {
            print(trace(file: #file, function: #function, line: #line))
            return
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            avaPlayer = try AVAudioPlayer(data: sound.data, fileTypeHint: AVFileTypeWAVE)
            DispatchQueue.main.async {
                guard let player = self.avaPlayer else { return }
                player.play()
            }
        } catch let err {
            print(trace(file: #file, function: #function, line: #line))
            print(err.localizedDescription)
        }
    }

    // MARK: - 3D touch

    func is3DTouchAvailable() -> Bool {
        // FIXME: this logic seems to be off
        return self.traitCollection.forceTouchCapability == UIForceTouchCapability.available
    }

    // MARK: - Navigation prompt
    
    var timer: Timer?
    
    func scheduleNavigationPrompt(with message: String, duration: TimeInterval) {
        if let navigationController = self.navigationController as? BaseNavigationController {
            UIView.animate(withDuration: 0.3) {
                navigationController.navigationItem.prompt = message
            }
            DispatchQueue.main.async {
                self.timer = Timer.scheduledTimer(timeInterval: duration,
                                                  target: self,
                                                  selector: #selector(self.removePrompt),
                                                  userInfo: nil,
                                                  repeats: false)
                self.timer?.tolerance = 5
            }
        }
    }
    
    @objc private func removePrompt() {
        if let navigationController = self.navigationController as? BaseNavigationController {
            if navigationController.navigationItem.prompt  != nil {
                DispatchQueue.main.async {
                    navigationController.navigationItem.prompt = nil
                }
            }
        }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

}


















