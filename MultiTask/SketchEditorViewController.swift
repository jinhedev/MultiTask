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
    var lastPoint = CGPoint.zero
    var red: CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue: CGFloat = 0.0
    var brushWidth: CGFloat = 10.0
    var opacity: CGFloat = 1.0
    var swiped = false

    var saveButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: #imageLiteral(resourceName: "FloppyDisk"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(handleSave(_:)))
        return button
    }()

    static let storyboard_id = String(describing: SketchEditorViewController.self)

    @IBOutlet weak var materialToolBar: UIToolbar!
    @IBOutlet weak var dividerView: UIView!
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var tempImageView: UIImageView!

    func drawLineFrom(_ fromPoint: CGPoint, toPoint: CGPoint) {
        // 1
        UIGraphicsBeginImageContext(view.frame.size)
        let context = UIGraphicsGetCurrentContext()
        tempImageView.image?.draw(in: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        // 2
        context?.move(to: fromPoint)
        context?.addLine(to: toPoint)
        // 3
        context?.setLineCap(CGLineCap.round)
        context?.setLineWidth(brushWidth)
        context?.setStrokeColor(Color.white.cgColor)
        context?.setBlendMode(CGBlendMode.normal)
        // 4
        context?.strokePath()
        // 5
        tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        tempImageView.alpha = opacity
        UIGraphicsEndImageContext()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped = true
        if let touch = touches.first {
            let currentPoint = touch.location(in: view)
            drawLineFrom(lastPoint, toPoint: currentPoint)
            lastPoint = currentPoint
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped = false
        if let touch = touches.first {
            lastPoint = touch.location(in: view)
        }
    }

    // MARK: - UIToolBar

    private func setupMaterialToolBar() {
        self.materialToolBar.tintColor = Color.mandarinOrange
        self.materialToolBar.barTintColor = Color.midNightBlack
        self.materialToolBar.barStyle = .black
        self.materialToolBar.isTranslucent = false
    }

    private func setupDividerView() {
        self.dividerView.backgroundColor = Color.darkGray
    }

    // MARK: - UINavigationBar

    private func setupUINavigationBar() {
        navigationItem.rightBarButtonItem = saveButton
    }

    @objc func handleSave(_ sender: UIBarButtonItem) {
        print(123)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUINavigationBar()
        self.setupDividerView()
        self.setupMaterialToolBar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
    }

}
