//
//  UserFilesManager.swift
//  MultiTask
//
//  Created by rightmeow on 8/12/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit
import AWSMobileHubHelper

class UserFileManager: NSObject {

    private func uploadWithData(data: Data, forKey key: String) {
        let manager = AWSUserFileManager.defaultUserFileManager()
        let localContent = manager.localContent(with: data, key: key)
        localContent.uploadWithPin(
            onCompletion: false,
            progressBlock: {[weak self](content: AWSLocalContent, progress: Progress) -> Void in
                guard let strongSelf = self else { return }
                /* Show progress in UI. */

            },
            completionHandler: {[weak self](content: AWSLocalContent?, error: Error?) -> Void in
                guard let strongSelf = self else { return }
                
                if let error = error {
                    print("Failed to upload an object. \(error)")
                } else {
                    print("Object upload complete.")
                }
        })
    }

    private func downloadContent(content: AWSContent, pinOnCompletion: Bool) {
        content.download(
            with: .ifNewerExists,
            pinOnCompletion: pinOnCompletion,
            progressBlock: {[weak self](content: AWSContent, progress: Progress) -> Void in
                guard let strongSelf = self else { return }
                /* Show progress in UI. */

            },
            completionHandler: {[weak self](content: AWSContent?, data: Data?, error: Error?) -> Void in
                guard let strongSelf = self else { return }

                if let error = error {
                    print("Failed to download a content from a server. \(error)")
                    return
                }
                print("Object download complete.")
        })
    }

}
