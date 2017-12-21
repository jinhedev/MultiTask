//
//  SketchEditorViewController.swift
//  MultiTask
//
//  Created by rightmeow on 12/21/17.
//  Copyright © 2017 Duckensburg. All rights reserved.
//

import UIKit

class SketchEditorViewController: BaseViewController {

    // MARK: - API

    var sketch: Sketch?

    static let storyboard_id = String(describing: SketchEditorViewController.self)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
    }

}
